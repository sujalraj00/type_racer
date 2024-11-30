import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeDialog extends StatelessWidget {
  final String shortCode;
  final String siteUrl;

  const QrCodeDialog({Key? key, required this.shortCode, required this.siteUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qrData = "$siteUrl/join?code=$shortCode"; // Encoded data for QR
    return AlertDialog(
      title: const Text('Share Game Room'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Short Code: $shortCode',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: shortCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
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
    );
  }
}





//  // Method to show QR code dialog
//   void showQRCodeDialog(BuildContext context, String shortCode, String siteUrl) {
//     final qrData = "www.google.com";
  
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Game Invitation'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // QR Code Generation
//             QrImageView(
//               data: qrData,
//               version: QrVersions.auto,
//               size: 200.0,
//               // Optional: Customize QR code appearance
//             ),
//             const SizedBox(height: 16),
            
//             // Display Short Code
//             Text(
//               'Game Code: $shortCode',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Copy Code Button
//             ElevatedButton.icon(
//               onPressed: () {
//                 Clipboard.setData(ClipboardData(text: shortCode));
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Code Copied to Clipboard')),
//                 );
//               },
//               icon: const Icon(Icons.copy),
//               label: const Text('Copy Code'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
  