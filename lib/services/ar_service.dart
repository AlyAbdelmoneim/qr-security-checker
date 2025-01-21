import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:ui';

class ARService {
  late ArCoreController arCoreController;

  void onARCreated(ArCoreController controller) {
    arCoreController = controller;

    // Optionally, add an object on creation
    addARObject();
  }

  void addARObject() {
    final node = ArCoreNode(
      shape: ArCoreSphere(
        materials: [ArCoreMaterial(color: const Color.fromRGBO(0, 255, 0, 1))],
        radius: 0.1,
      ),
      position: vector.Vector3(0, 0, -1), // 1 meter in front of the user
    );
    arCoreController.addArCoreNode(node);
  }

  void dispose() {
    arCoreController.dispose();
  }
}
