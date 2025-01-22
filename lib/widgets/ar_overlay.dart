import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../services/safety_checker.dart'; // Import your SafetyChecker class

class AROverlay extends StatefulWidget {
  @override
  _AROverlayState createState() => _AROverlayState();
}

class _AROverlayState extends State<AROverlay> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QRScanner');
  QRViewController? qrController;
  ArCoreController? arCoreController;

  bool showARView = false; // Toggle between AR view and QR scanner
  String scannedResult = 'Scan a QR code';
  bool isSafe = false; // Whether the QR code is "safe"

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.camera.request().isDenied) {
      setState(() {
        scannedResult = 'Camera permission denied';
      });
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        setState(() {
          scannedResult = scanData.code!;
        });
        // Use SafetyChecker to validate the QR code
        String safetyResult = await SafetyChecker.checkUrlSafety(scanData.code!);
        setState(() {
          isSafe = safetyResult == 'The URL is safe';
          scannedResult = safetyResult;
          showARView = true; // Switch to AR view
        });
        qrController?.pauseCamera(); // Pause the QR scanner
      }
    });
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    _addCube(isSafe); // Add a cube based on the safety result
  }

  void _addCube(bool safe) {
    final color = safe ? Colors.green : Colors.red; // Set cube color
    final material = ArCoreMaterial(color: color);

    final shape = ArCoreCube(
      materials: [material],
      size: vm.Vector3(0.2, 0.2, 0.2), // Cube size
    );

    final node = ArCoreNode(
      shape: shape,
      position: vm.Vector3(0, 0, -1), // Position the cube 1 meter in front of the camera
    );

    arCoreController?.addArCoreNode(node);
  }

  void _rescanQRCode() {
    setState(() {
      showARView = false; // Switch back to QR scanner
      scannedResult = 'Scan a QR code';
    });
    qrController?.resumeCamera(); // Resume the QR scanner
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (!showARView)
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
            )
          else
            ArCoreView(
              onArCoreViewCreated: _onArCoreViewCreated,
            ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.black54,
                  child: Text(
                    scannedResult,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (showARView)
                  ElevatedButton(
                    onPressed: _rescanQRCode,
                    child: Text('Rescan QR Code'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    qrController?.dispose();
    arCoreController?.dispose();
    super.dispose();
  }
}
