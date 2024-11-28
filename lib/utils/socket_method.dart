import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:type_racer/providers/client_state_provider.dart';
import 'package:type_racer/providers/game_state_provider.dart';
import 'package:type_racer/utils/socket_client.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;
  bool _isPlaying = false;

  //create game
  createGame(String nickname){
    if (nickname.isNotEmpty) {
      _socketClient.emit("create-game", {
        'nickname' : nickname,
              });
    }else {
    print('Nickname is empty, not emitting.');
  }
  }
  
// join game
joinGame(String shortCode ,String nickname){
    if (nickname.isNotEmpty && shortCode.isNotEmpty) {
      _socketClient.emit("join-game", {
        'nickname' : nickname,
        'gameId' : shortCode
              });
    }
  }

    sendUserInput(String value, String gameID) {
    _socketClient.emit('userInput', {
      'userInput': value,
      'gameID': gameID,
    });
  }

// listeners
  updateGameListener(BuildContext context){
    _socketClient.on('updateGame', (data) {
        print('Received game update data: $data'); // Add this line to debug
      final gameStateProvider = 
      Provider.of<GameStateProvider>(context,listen: false).updateGameState(
        id: data['_id'], 
        players: data['players'], 
        isJoin: data['isJoin'], 
        isOver: data['isOver'], 
        words: data['words'],
        shortCode: data['shortCode'] ?? ''
        );


       if (data['_id'].isNotEmpty && !_isPlaying) {
         Navigator.pushNamed(context, '/game-screen');
         _isPlaying = true;
       }

    });
  }

  startTimer(playerId, gameID){
    _socketClient.emit(
      'timer',
      {
        'playerId' : playerId,
        'gameID' : gameID
      }
    );
  }

  notCorrectGameListener(BuildContext context){
    _socketClient.on("notCorrectGame", (data) => 
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data),),),);
      }

  updateTimer(BuildContext context){
    final clientStateProvider = 
    Provider.of<ClientStateProvider>(context, listen:  false);
    _socketClient.on('timer', (data) {
      clientStateProvider.setClientState(data);
    });
  }

    updateGame(BuildContext context) {
    _socketClient.on('updateGame', (data) {
      final gameStateProvider =
          Provider.of<GameStateProvider>(context, listen: false)
              .updateGameState(
        id: data['_id'],
        players: data['players'],
        isJoin: data['isJoin'],
        words: data['words'],
        isOver: data['isOver'],
        shortCode: data['shortCode']
      );
    });
  }


  gameFinishedListener() {
    _socketClient.on('done', (data) => _socketClient.off('timer'));
  }
  
}