import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerInitial extends StatefulWidget {
  const QRScannerInitial({Key? key}) : super(key: key);

  @override
  State<QRScannerInitial> createState() => _QRScannerInitialState();
}

class _QRScannerInitialState extends State<QRScannerInitial> {
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
          '/arInitial',
          arguments: {'scannedCode': scanData.code},
        );
        qrController?.dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Initial QR Scanner')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }
}
