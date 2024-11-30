import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:type_racer/providers/client_state_provider.dart';
import 'package:type_racer/providers/game_state_provider.dart';
import 'package:type_racer/utils/socket_method.dart';
import 'package:type_racer/widgets/game_text_field.dart';
import 'package:type_racer/widgets/qr_code_dialog.dart';
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

  // Method to show QR code dialog
  void _showQRCodeDialog(
      BuildContext context, String shortCode, String siteUrl) {
    final qrData = "www.google.com";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Invitation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR Code Generation
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
              // Optional: Customize QR code appearance
            ),
            const SizedBox(height: 16),

            // Display Short Code
            Text(
              'Game Code: $shortCode',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // Copy Code Button
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: shortCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code Copied to Clipboard')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy Code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
                height: 300,
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
                                            'www.google.com', // custom link of data
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
