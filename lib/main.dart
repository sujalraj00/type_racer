import 'package:flutter/material.dart';
import 'package:type_racer/screens/create_roomscreen.dart';
import 'package:type_racer/screens/home_screen.dart';
import 'package:type_racer/screens/join_room_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Type Racer',
      theme: ThemeData(
   primarySwatch: Colors.blue      ),
      initialRoute: '/',
      routes: {
        '/' : (context) => const HomeScreen(),
        '/create-room' :(context) =>const CreateRoomScreen(),
        '/join-room' :(context) =>const JoinRoomScreen()
      },
    );
  }
}

