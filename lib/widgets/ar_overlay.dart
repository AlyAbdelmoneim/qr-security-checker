import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../services/safety_checker.dart';

class AROverlay extends StatefulWidget {
  @override
  _AROverlayState createState() => _AROverlayState();
}

class _AROverlayState extends State<AROverlay> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QRScanner');
  QRViewController? qrController;
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  bool showARView = false; // Start with QR scanner
  String scannedResult = 'Scan a QR code';
  String objectToDisplay = ''; // Path to the AR object to display

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
        final isSafe = await _validateQRCode(scanData.code!);
        setState(() {
          showARView = true;
          objectToDisplay = isSafe ? 'assets/safe_object.glb' : 'assets/unsafe_object.glb';
        });
        qrController?.pauseCamera();
      }
    });
  }

  Future<bool> _validateQRCode(String code) async {
    final isValidUrl = code.startsWith('http://') || code.startsWith('https://');
    if (!isValidUrl) {
      return false;
    }
    final safetyResult = await SafetyChecker.checkUrlSafety(code);
    return safetyResult == 'The URL is safe';
  }

  void _onARViewCreated(
      ARSessionManager sessionManager, ARObjectManager objectManager) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    sessionManager.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      showWorldOrigin: false,
    );
    objectManager.onInitialize();

    // Add AR object
    if (objectToDisplay.isNotEmpty) {
      _addARObject(objectToDisplay);
    }
  }

  Future<void> _addARObject(String uri) async {
    try {
      ARNode node = ARNode(
        type: NodeType.localGLTF2,
        uri: uri,
        scale: vm.Vector3(0.5, 0.5, 0.5),
        position: vm.Vector3(0, -0.5, -1.5),
        rotation: vm.Vector4(0, 0, 0, 1),
      );
      bool? added = await arObjectManager?.addNode(node);
      if (added == true) {
        print('Node added successfully.');
      } else {
        print('Failed to add node.');
      }
    } catch (e) {
      print('Error adding AR node: $e');
    }
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
            ARView(
              onARViewCreated: (sessionManager, objectManager, anchorManager, locationManager) {
                _onARViewCreated(sessionManager, objectManager);
              },
            ),
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

  @override
  void dispose() {
    qrController?.dispose();
    arSessionManager?.dispose();
    super.dispose();
  }
}
