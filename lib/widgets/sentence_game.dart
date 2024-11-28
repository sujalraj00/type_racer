import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:type_racer/providers/game_state_provider.dart';
import 'package:type_racer/utils/socket_client.dart';
import 'package:type_racer/utils/socket_method.dart';
import 'package:type_racer/widgets/score_board.dart';

class SentenceGame extends StatefulWidget {
  const SentenceGame({super.key});

  @override
  State<SentenceGame> createState() => _SentenceGameState();
}

class _SentenceGameState extends State<SentenceGame> {
  
  var playerMe =null;
  final SocketMethods _socketMethod = SocketMethods();

  @override
  void initState() {
    super.initState();
     _socketMethod.updateGame(context);
  }

   findplayerMe(GameStateProvider game){
    game.gameState['players'].forEach((player) {
      if (player['socketID'] == SocketClient.instance.socket!.id) {
        playerMe = player;
      }
    });
  }
  
  Widget getTypedWords(words, player){
    var tempWords = words.sublist(0,player['currentWordIndex']);
    String typedWord = tempWords.join(' ');
    return Text(
      typedWord,
      style: const TextStyle(
        color: Color.fromRGBO(52, 235, 119, 1),
      fontSize: 20
      ),
    );
  }

  
  Widget getCurrentWords(words, player){
    return Text(
      words[player['currentWordIndex']],
      style: const TextStyle(
        decoration: TextDecoration.underline,
        fontSize: 20
      ),
    );
  }

  
  Widget getWordsToBeTyped(words, player){
    var tempWords = words.sublist(player['currentWordIndex']+1, words.length);
    String WordstoBeTyped = tempWords.join(' ');
    return Text(
      WordstoBeTyped,
      style: const TextStyle(
        color:Colors.grey,
        fontSize: 20
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameStateProvider>(context);
    findplayerMe(game);

    if (game.gameState['words'].length > playerMe['currentWordIndex']) {
      // ignore: prefer_const_constructors
      return Padding(padding: EdgeInsets.symmetric(horizontal: 20),
    child: Wrap(
      textDirection: TextDirection.ltr,
      children: [
        // typed word
        getTypedWords(game.gameState['words'], playerMe),

        // current word
        getCurrentWords(game.gameState['words'], playerMe),
        // word to be typed
        getWordsToBeTyped(game.gameState['words'], playerMe)
      ],
    ),
    );
    }

    return const ScoreBoard();

    
  }
}