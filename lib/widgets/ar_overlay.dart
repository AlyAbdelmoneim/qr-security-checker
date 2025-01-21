import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import '../services/ar_service.dart';

class AROverlay extends StatefulWidget {
  @override
  _AROverlayState createState() => _AROverlayState();
}

class _AROverlayState extends State<AROverlay> {
  late ArCoreController _arCoreController;
  final ARService _arService = ARService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AR Safety Checker")),
      body: ArCoreView(
        onArCoreViewCreated: (controller) {
          _arCoreController = controller;
          _arService.onARCreated(controller);
        },
        enableTapRecognizer: true, // Enable taps if needed
      ),
    );
  }

  @override
  void dispose() {
    _arService.dispose();
    super.dispose();
  }
}
