import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient{
  IO.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket = IO.io('http://100.100.8.117:3000', <String, dynamic>{
      'transports' : ["websocket"],
      'autoConnect' : false,
    });

      socket!.onConnect((_) {
      print("Connected to server: ${socket!.id}");
    });


socket!.onConnectError((error) {
      print("Connection error: $error");
    });

     socket!.onDisconnect((_) {
      print("Disconnected from server");
    });

 socket!.connect();
  }

 

  static SocketClient get instance{
     
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}