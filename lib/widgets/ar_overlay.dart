import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../services/safety_checker.dart';

class AROverlay extends StatefulWidget {
  @override
  _AROverlayState createState() => _AROverlayState();
}

class _AROverlayState extends State<AROverlay> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? scannedUrl;
  String validationResult = 'Scan a QR code to check its safety';
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AR QR Checker")),
      body: Stack(
        children: [
          // AR View
          ARView(
            onARViewCreated: _onARViewCreated,
          ),
          // QR Code Scanner Overlay
          Positioned(
            bottom: 50,
            left: 50,
            right: 50,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          // Text Overlay for Validation Result
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Text(
              validationResult,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager,
      ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    sessionManager.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      customPlaneTexturePath: null,
      showWorldOrigin: true,
    );

    objectManager.onInitialize();
  }

  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && Uri.tryParse(scanData.code!)?.hasAbsolutePath == true) {
        setState(() {
          scannedUrl = scanData.code; // Extracted URL
        });

        // Validate the URL using the SafetyChecker
        final result = await SafetyChecker.checkUrlSafety(scannedUrl!);
        setState(() {
          validationResult = result == null
              ? 'The URL is safe'
              : 'Warning: $result detected!';
        });

        // Stop scanning after the first scan
        controller.pauseCamera();
      } else {
        setState(() {
          validationResult = 'Invalid QR code or URL';
        });
      }
    });
  }

  @override
  void dispose() {
    arSessionManager.dispose();
    super.dispose();
  }
}
