import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARService {
  late ArCoreController arCoreController;

  // Initializes the ARCore Controller
  void onARCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneDetected = (planes) {
      // Handle AR plane detection
    };
  }

  // Load a 3D object into AR
  void addARObject(ArCoreController controller) {
    final node = ArCoreNode(
      shape: ArCoreSphere(
        radius: 0.1,
        materials: [ArCoreMaterial(color: Colors.red)],
      ),
      position: vector.Vector3(0, 0, -1), // Place in front of the camera
    );
    controller.addArCoreNodeWithAnchor(node);
  }
}
