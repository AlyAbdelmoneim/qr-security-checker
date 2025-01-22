import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vm; // Correct import for vector_math_64

class ARCoreView extends StatefulWidget {
  @override
  _ARCoreViewState createState() => _ARCoreViewState();
}

class _ARCoreViewState extends State<ARCoreView> {
  late ArCoreController arCoreController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ARCore Example'),
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true, // Enable tap interactions
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;

    // Add a built-in sphere to the AR scene
    _addSphere();
    _addCube(); // Add a cube for variety
  }

  void _addSphere() {
    final material = ArCoreMaterial(
      color: Colors.red, // Explicitly use Colors from material.dart
    );
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.1, // Set the sphere radius
    );
    final node = ArCoreNode(
      shape: sphere,
      position: vm.Vector3(0, 0, -1), // Correct usage of vm.Vector3
    );
    arCoreController.addArCoreNode(node);
  }

  void _addCube() {
    final material = ArCoreMaterial(
      color: Colors.blue, // Use a different color for the cube
    );
    final cube = ArCoreCube(
      materials: [material],
      size: vm.Vector3(0.2, 0.2, 0.2), // Define cube dimensions
    );
    final node = ArCoreNode(
      shape: cube,
      position: vm.Vector3(0.3, 0, -1), // Position to the right of the sphere
    );
    arCoreController.addArCoreNode(node);
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}
