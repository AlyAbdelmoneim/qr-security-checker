import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerSecondary extends StatefulWidget {
  const QRScannerSecondary({Key? key}) : super(key: key);

  @override
  State<QRScannerSecondary> createState() => _QRScannerSecondaryState();
}

class _QRScannerSecondaryState extends State<QRScannerSecondary> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QRScanner');
  QRViewController? qrController;

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        Navigator.pushNamed(
          context,
          '/arSecondary',
          arguments: {'scannedCode': scanData.code},
        );
        qrController?.dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secondary QR Scanner')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }
}
