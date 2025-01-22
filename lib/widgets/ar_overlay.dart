import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/safety_checker.dart';

class AROverlay extends StatefulWidget {
  @override
  _AROverlayState createState() => _AROverlayState();
}

class _AROverlayState extends State<AROverlay> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QRScanner');
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  QRViewController? qrController;
  String scannedResult = 'Point the camera at a QR code';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.camera.request().isDenied) {
      print('Camera permission denied.');
      setState(() {
        scannedResult = 'Camera permission denied';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // QR Scanner Fullscreen
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.blue,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
          // AR Elements Layer
          Positioned.fill(
            child: GestureDetector(
              onTapUp: (details) => _onARTap(details.localPosition),
              child: Container(
                color: Colors.transparent,
                child: CustomPaint(
                  painter: AROverlayPainter(scannedResult),
                ),
              ),
            ),
          ),
          // Scanned Result Overlay
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.black54,
              child: Text(
                scannedResult,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        setState(() {
          scannedResult = scanData.code!;
        });
        print('Scanned QR Code: ${scanData.code}');

        // Validate the QR code as a URL
        final isValidUrl = scanData.code!.startsWith('http://') || scanData.code!.startsWith('https://');
        if (!isValidUrl) {
          setState(() {
            scannedResult = 'Invalid QR code';
          });
          return;
        }

        // Pass the scanned URL to the SafetyChecker
        final safetyResult = await SafetyChecker.checkUrlSafety(scanData.code!);
        setState(() {
          scannedResult = safetyResult ?? 'The URL is safe';
        });
      } else {
        print('No QR code detected.');
      }
    });
  }

  void _onARTap(Offset position) {
    print('Tapped AR layer at: $position');
    // Handle AR tap interactions here (if needed)
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }
}

class AROverlayPainter extends CustomPainter {
  final String result;

  AROverlayPainter(this.result);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: result,
        style: const TextStyle(color: Colors.red, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final offset = Offset(size.width / 2 - textPainter.width / 2, size.height / 4);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Redraw when result changes
  }
}
