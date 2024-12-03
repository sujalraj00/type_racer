import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:type_racer/providers/client_state_provider.dart';
import 'package:type_racer/providers/game_state_provider.dart';
import 'package:type_racer/screens/create_roomscreen.dart';
import 'package:type_racer/screens/game_screen.dart';
import 'package:uni_links3/uni_links.dart';
import 'package:type_racer/screens/home_screen.dart';
import 'package:type_racer/screens/join_room_screen.dart';
import 'package:flutter/services.dart' show PlatformException;



// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void setupDeepLinks() async {
  try {
    String? initialLink = await getInitialLink();
    if (initialLink != null) {
      handleInitialLink(initialLink);
    }

    linkStream.listen((String? link) {
      if (link != null) {
        handleInitialLink(link);
      }
    }, onError: (err) {
      print('Deep link error: $err');
    });
  } on PlatformException {
    // Handle exception
  }
}

void handleInitialLink(String link) {
  Uri uri = Uri.parse(link);
  if (uri.pathSegments.isNotEmpty) {
    final shortCode = uri.pathSegments.last;
    
    // Navigate to Join Room screen with pre-filled game ID
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) => JoinRoomScreen(initialGameId: shortCode)
      )
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDeepLinks();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of  application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameStateProvider()),
        ChangeNotifierProvider(create: (context) => ClientStateProvider())
      ],
      child: MaterialApp( navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Type Racer',
        theme: ThemeData(
         primarySwatch: Colors.blue      ),
        initialRoute: '/',
        routes: {
          '/' : (context) => const HomeScreen(),
          '/create-room' :(context) =>const CreateRoomScreen(),
          '/join-room' :(context) =>const JoinRoomScreen(),
          '/game-screen' :(context) => const GameScreen()
        },
      ),
    );
  }
}

