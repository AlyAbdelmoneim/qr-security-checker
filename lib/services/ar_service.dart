import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/material.dart';

class ARService {
  // Method to process the scanned QR code
  String processQRCode(String? scannedData) {
    if (scannedData == null || scannedData.isEmpty) {
      return 'Invalid QR Code';
    }

    // Validate the scanned data as a URL
    final isValidUrl = scannedData.startsWith('http://') || scannedData.startsWith('https://');
    return isValidUrl ? scannedData : 'Invalid URL: $scannedData';
  }
}
