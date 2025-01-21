
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import '../services/ar_service.dart';

class AROverlay extends StatefulWidget {
  @override
  _AROverlayState createState() => _AROverlayState();
}

class _AROverlayState extends State<AROverlay> {
  final ARService _arService = ARService();
  late ARSessionManager _arSessionManager;
  late ARObjectManager _arObjectManager;
  late ARAnchorManager _arAnchorManager;
  late ARLocationManager _arLocationManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AR Safety Checker")),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: _onARViewCreated,
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
    _arSessionManager = sessionManager;
    _arObjectManager = objectManager;
    _arAnchorManager = anchorManager;
    _arLocationManager = locationManager;

    // Initialize AR Services
    _arService.onARCreated(sessionManager, objectManager);
  }

  @override
  void dispose() {
    _arService.dispose();
    super.dispose();
  }
}
