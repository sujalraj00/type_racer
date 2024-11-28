import 'package:flutter/material.dart';
import 'package:type_racer/models/game_state.dart';

class GameStateProvider  extends ChangeNotifier{
  GameState _gameState = GameState(id: '', players: [], isJoin: true, isOver: false, words: [], shortCode: '' );

  Map<String, dynamic> get gameState => _gameState.toJson();

  void updateGameState({
    required id, 
    required players, 
    required isJoin, 
    required isOver, 
    required words,
    required shortCode
    }) {
      _gameState = GameState(
        id: id, 
        players: players, 
        isJoin: isJoin, 
        isOver: isOver, 
        words: words, 
        shortCode: shortCode.toString()
        );

        notifyListeners();

    }

}