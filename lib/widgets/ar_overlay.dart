import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../services/safety_checker.dart';
import 'dart:async';

class AROverlay extends StatefulWidget {
  @override
  _AROverlayState createState() => _AROverlayState();
}

class _AROverlayState extends State<AROverlay> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'AROverlayQR');
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  QRViewController? qrController;
  String scannedResult = 'Place a QR code in front of the camera';
  Timer? qrUpdateTimer;

  @override
  void initState() {
    super.initState();
    _checkPermissions();

    // Timer to periodically refresh QR scanning
    qrUpdateTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (qrController != null) {
        qrController!.resumeCamera();
        Future.delayed(const Duration(milliseconds: 4000), () {
          qrController!.pauseCamera(); // Pause after a brief scan period
        });
      }
    });
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
      appBar: AppBar(title: const Text("AR QR Checker")),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: _onARViewCreated,
          ),
          Positioned(
            bottom: 50,
            left: 50,
            right: 50,
            child: SizedBox(
              height: 250,
              width: 250,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.blue,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 250,
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
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
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        setState(() {
          scannedResult = scanData.code!;
        });
        print('Scanned QR Code: ${scanData.code}');

        // Validate the QR code as a URL
        final isValidUrl = scanData.code!.startsWith('http://') || scanData.code!.startsWith('https://');
        if (!isValidUrl) {
          print('Invalid QR code format: ${scanData.code}');
          _addTextNode("Invalid QR code");
          return;
        }

        // Pass the scanned URL to the SafetyChecker
        final safetyResult = await SafetyChecker.checkUrlSafety(scanData.code!);
        if (safetyResult != null) {
          print('Safety check result: $safetyResult');
          _addTextNode(safetyResult);
        } else {
          print('URL is safe: ${scanData.code}');
          _addTextNode("URL is safe");
        }
      } else {
        print('No QR code detected.');
      }
    });
  }

  Future<void> _addTextNode(String safetyResult) async {
    setState(() {
      scannedResult = safetyResult; // Update overlay text
    });
  }

  @override
  void dispose() {
    arSessionManager.dispose();
    qrController?.dispose();
    qrUpdateTimer?.cancel(); // Cancel the periodic timer
    super.dispose();
  }
}
