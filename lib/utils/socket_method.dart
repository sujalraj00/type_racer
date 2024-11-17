import 'package:type_racer/utils/socket_client.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;

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
  
}