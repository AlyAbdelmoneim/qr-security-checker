import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart'; // Added for permission handling

class AROverlay extends StatefulWidget {
  @override
  _AROverlayState createState() => _AROverlayState();
}

class _AROverlayState extends State<AROverlay> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'AROverlayQR');
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  QRViewController? qrController;

  @override
  void initState() {
    super.initState();
    _checkPermissions(); // Request camera permissions on initialization
  }

  Future<void> _checkPermissions() async {
    if (await Permission.camera.request().isDenied) {
      print('Camera permission denied.');
    }
  }

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
    qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        print('Scanned QR Code: ${scanData.code}'); // Print the QR code to the console
      } else {
        print('No QR code detected.');
      }
    });
  }

  @override
  void dispose() {
    arSessionManager.dispose();
    qrController?.dispose();
    super.dispose();
  }
}
