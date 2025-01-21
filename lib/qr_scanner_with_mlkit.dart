import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class QRScannerWithMLKit extends StatefulWidget {
  @override
  _QRScannerWithMLKitState createState() => _QRScannerWithMLKitState();
}

class _QRScannerWithMLKitState extends State<QRScannerWithMLKit> {
  late CameraController _cameraController;
  late BarcodeScanner _barcodeScanner;
  bool _isProcessing = false;
  String _scannedResult = 'Place a QR code in front of the camera';
  late InputImageRotation _rotation;

  @override
  void initState() {
    super.initState();
    _initializeBarcodeScanner();
    _initializeCamera();
  }

  Future<void> _initializeBarcodeScanner() async {
    _barcodeScanner = GoogleMlKit.vision.barcodeScanner();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _rotation = _rotationForCamera(camera);

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    await _cameraController.initialize();

    _cameraController.startImageStream((image) {
      if (!_isProcessing) {
        _isProcessing = true;
        _processImage(image);
      }
    });

    setState(() {});
  }

  InputImageRotation _rotationForCamera(CameraDescription camera) {
    switch (camera.sensorOrientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final inputImage = _convertCameraImageToInputImage(image);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      for (final barcode in barcodes) {
        final displayValue = barcode.displayValue;

        if (displayValue != null) {
          // Check if the displayValue is a valid URL
          final isValidUrl = displayValue.startsWith('http://') || displayValue.startsWith('https://');
          if (isValidUrl) {
            setState(() {
              _scannedResult = displayValue; // Display the URL if valid
            });
            print('Scanned QR Code (Valid URL): $displayValue');
          } else {
            setState(() {
              _scannedResult = 'Invalid URL: $displayValue'; // Mark as invalid if not a URL
            });
            print('Scanned QR Code (Invalid URL): $displayValue');
          }
        } else {
          print('No display value found in the barcode.');
        }
      }
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      _isProcessing = false; // Reset processing flag
    }
  }

  InputImage _convertCameraImageToInputImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: _rotation,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner with Google ML Kit')),
      body: Stack(
        children: [
          if (_cameraController.value.isInitialized)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateZ(3.14159 / 2), // Rotate 90 degrees counterclockwise
              child: CameraPreview(_cameraController),
            )
          else
            Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.black54,
              child: Text(
                _scannedResult,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
