const Game = require("F:/NEW APPS/New folder (2)/type_racer/server/model/Game");
//import Game from ".server/model/Game"
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

module.exports = deleteOldFinishedGames;