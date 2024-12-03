import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:type_racer/providers/client_state_provider.dart';
import 'package:type_racer/providers/game_state_provider.dart';
import 'package:type_racer/utils/socket_method.dart';
import 'package:type_racer/widgets/game_text_field.dart';
import 'package:type_racer/widgets/sentence_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    super.initState();
    _socketMethods.updateTimer(context);
    _socketMethods.updateGame(context);
    _socketMethods.gameFinishedListener();
  }



  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameStateProvider>(context);
    final clientStateProvider = Provider.of<ClientStateProvider>(context);

    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          children: [
            Chip(
              label: Text(
                clientStateProvider.clientState['timer']['msg'].toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Text(
              clientStateProvider.clientState['timer']['countDown'].toString(),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SentenceGame(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SizedBox(
                height: 350,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: game.gameState['players'].length ?? 0,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Chip(
                              label: Text(
                                game.gameState['players'][index]['nickname'],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            Slider(
                                value: game.gameState['players'][index]
                                        ['currentWordIndex'] /
                                    game.gameState['words'].length,
                                onChanged: (val) {})
                          ],
                        ),
                      );
                    }),
              ),
            ),
            game.gameState['isJoin']
                ? Container(
                    padding: EdgeInsets.all(10),
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('scan to join'),
                              content: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      width: 130,
                                      child: QrImageView(
                                        data:
                                            'https://type-racer-ivory.vercel.app/join/${game.gameState['shortCode']}', 
                                        version: QrVersions.auto,
                                        size: 150.0,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    
                                    OutlinedButton.icon(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text:
                                                  game.gameState['shortCode']));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Copied to clipboard')),
                                          );
                                        },
                                        icon: const Icon(Icons.copy),
                                        label: Text("${game.gameState['shortCode']}"))
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('show game code')),
                  )
                : SizedBox(),
          ],
        ),
      )),
      bottomNavigationBar: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: const GameTextField()),
    );
  }
}
