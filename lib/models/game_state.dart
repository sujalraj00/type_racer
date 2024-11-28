class GameState{
  final String id;
  final List players;
  final bool isJoin;
  final bool isOver;
  final List words;
  final String shortCode;

  GameState({required this.id, required this.players, required this.isJoin, required this.isOver, required this.words, required this.shortCode});

  Map<String, dynamic> toJson() =>{
    'id' : id,
    'players' : players,
    'isJoin' : isJoin,
    'words' : words,
    'isOver' : isOver ,
    'shortCode' : shortCode
  };  
}