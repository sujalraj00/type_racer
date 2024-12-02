// imports
const express = require("express");
const mongoose = require("mongoose");
const http = require("http");
const Game = require('./model/Game');
const getSentence = require("./api/getSentence");
require('dotenv').config(); 
//const deleteOldFinishedGames = require('./utils/game_cleanup');
   
//const exp = require("constants");


// EVERYTHING IN JAVASCRIPT IS AN OBJECT

// create a server
const app = express();
const port = process.env.PORT || 3000;
var server = http.createServer(app);



var io = require('socket.io')(server ,  {
    cors: {
      origin: "*", // Replace "*" with specific domains if needed
      methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"], // Add all desired HTTP methods here
      allowedHeaders: ["Content-Type", "Authorization"], // Add allowed headers if needed
      credentials: true // Allow credentials if necessary
    }
  });

// FRONTEND -> MIDDLEWARE -> BACKEND

// middleware
app.use(express.json());

// connect to mongodb
const DB = process.env.MONGO_URI;

const generateShortCode = () => {
  return Math.random().toString(36).substring(2, 8).toUpperCase();
};


// listening to socket io events from the client (flutter code)
io.on("connection", (socket) => {
   // console.log(socket.id);
    
    socket.on("create-game", async ({nickname}) =>{
        console.log("create-game event triggered with nickname:", nickname);
        try {
            console.log('entered the try block');
            let game = new Game();
            console.log("Initial Game Object:", game);
            const sentence = await getSentence();
            console.log("Sentence fetched:", sentence);
            game.words = sentence;

              // Generate unique short code
                        let shortCode;
                        let isUnique = false;
                        let attempts = 0;
                        while (!isUnique && attempts < 10) {
                          shortCode = generateShortCode();
                            console.log(`Attempt ${attempts + 1}: Generated Shortcode`, shortCode);
                            const existingGame = await Game.findOne({ shortCode });
                            console.log("Existing Game with this Shortcode:", existingGame);
                          if (!existingGame) {
                            isUnique = true;
                          }  attempts++;
                        }
                        if (!isUnique) {
                          console.error("Could not generate unique shortcode after 10 attempts");
                          socket.emit("error", "Could not create game. Please try again.");
                          return;
                        }
                       game.shortCode = shortCode;
console.log("Final Game Object before save:", game);
            let player = {
                socketID : socket.id,
                nickname,
                isPartyLeader : true
            };
            console.log("Player object:", player);
            game.players.push(player);
            //game.shortCode.push(shortcode);

            game = await game.save();
            const gameId = game._id.toString();
            socket.join(gameId);

             // Emit both game ID and short code
                        socket.emit("gameCreated", {
                          gameId,
                          shortCode
                        });


            io.to(gameId).emit("updateGame", game);            

            console.log('exiting try block');
        } catch (error) {
            console.log(error);
        }
    });

    socket.on("join-game", async ({nickname, shortCode}) => {
        try {
//            if (!gameId.match(/^[0-9a-fA-F]{24}$/)) {
//                socket.emit("notCorrectGame", "Please enter a valid game ID");
//                return;
//
//            }

             // Find game by short code instead of ID
             let game = await Game.findOne({ shortCode: shortCode});
             if (!game) {
                socket.emit("notCorrectGame", "Game not found. Check the code and try again.");
                return;
            }
            console.log(game);
           // let game = await Game.findById(gameId);
            if (game.isJoin) {
                const id = game._id.toString();
                let player = {
                    nickname,
                    socketID : socket.id
                };
                socket.join(id);
                game.players.push(player);
                game = await game.save();
                io.to(id).emit("updateGame", game);
            }  
            else {
                
                socket.emit(
                    'notCorrectGame',
                    "The game is in progress, please try again later!"
                );

                console.log('game under progress');
            }

        } catch (error) {
            console.log(error);
        }
    } );


    socket.on("userInput", async ({ userInput, gameID }) => {
        let game = await Game.findById(gameID);
        if (!game.isJoin && !game.isOver) {
          let player = game.players.find(
            (playerr) => playerr.socketID === socket.id
          );
    
          if (game.words[player.currentWordIndex] === userInput.trim()) {
            player.currentWordIndex = player.currentWordIndex + 1;
            if (player.currentWordIndex !== game.words.length) {
              game = await game.save();
              io.to(gameID).emit("updateGame", game);
            } else{
                let endTime = new Date().getTime();
                let {startTime} = game;
                player.WPM = calculateWPM(endTime, startTime ,player);
                game  = await game.save();
                socket.emit('done');
                io.to(gameID).emit("updateGame", game); 
            }
          }
        }
      });

    // timer listener
  socket.on("timer", async ({ playerId, gameID , shortCode}) => {
    let countDown = 5;
    let game = await Game.findById(gameID);
    let player = game.players.id(playerId);

    if (player.isPartyLeader) {
      let timerId = setInterval(async () => {
        if (countDown >= 0) {
          io.to(gameID).emit("timer", {
            countDown,
            msg: "Game Starting",
          });
          console.log(countDown);
          countDown--;
        } else {
          game.isJoin = false;
          game = await game.save();
          io.to(gameID).emit("updateGame", game);
          startGameClock(gameID);
          clearInterval(timerId);
        }
      }, 1000);
    }
  });
});

const startGameClock = async (gameID) => {
  let game = await Game.findById(gameID);
  game.startTime = new Date().getTime();
  game = await game.save();

  let time = 120;

  let timerId = setInterval(
    (function gameIntervalFunc() {
      if (time >= 0) {
        const timeFormat = calculateTime(time);
        io.to(gameID).emit("timer", {
          countDown: timeFormat,
          msg: "Time Remaining",
        });
        console.log(time);
        time--;
      } else {
        (async () => {
          try {
            let endTime = new Date().getTime();
            let game = await Game.findById(gameID);
            let { startTime } = game;
            game.isOver = true;
            game.players.forEach((player, index) => {
              if (player.WPM === -1) {
                game.players[index].WPM = calculateWPM(
                  endTime,
                  startTime,
                  player
                );
              }
            });
            game = await game.save();
            io.to(gameID).emit("updateGame", game);
            clearInterval(timerId);
          } catch (e) {
            console.log(e);
          }
        })();
      }
      return gameIntervalFunc;
    })(),
    1000
  );
};


  const calculateTime = (time) => {
    let min = Math.floor(time / 60);
    let sec = time % 60;
    return `${min}:${sec < 10 ? "0" + sec : sec}`;
  };

  const calculateWPM= (endTime, startTime, player) => {
    const timeTakenInSec = (endTime - startTime)/1000;
    const timeTaken = timeTakenInSec/60;
    let wordsTyped = player.currentWordIndex;
    const WPM = Math.floor(wordsTyped / timeTaken );
    return WPM;
  }

  const deleteOldFinishedGames = async ()  => {
    try {
        const oneHrAgo = Date.now() - (60*60*1000);
        const result = await Game.deleteMany(
            {
                isOver : true,
                startTime : {$lt: oneHrAgo}
            }
        );

        console.log(`Deleted ${result.deletedCount} finished games older than one hour`);
    } catch (error) {
        console.error('Error deleting old finished games:', error); 
    }
};


mongoose.connect(DB).then(() => {
    console.log("connection successful!");

     // Start periodic cleanup
     setInterval(deleteOldFinishedGames, 60 * 60 * 1000); // Runs every hour
}).catch((e) => {
    console.log(e);

});





// listen to the server
server.listen(port, "0.0.0.0", () =>{
    console.log(`Server started and running on port ${port}` );
});




// io is used to send message globally
// socket makes sure that we send it to a client wich is ourself
// to prevent it so sending to whole app we use io.to(gameid  ) so whoever has joined the gameid will only get the message