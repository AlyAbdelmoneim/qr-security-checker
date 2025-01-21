
import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARService {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;

  // Initialize AR session and object manager
  void onARCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    // Initialize AR session
    arSessionManager.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      customPlaneTexturePath: "assets/plane_texture.png", // Optional
      showWorldOrigin: true,
    );

    // Initialize AR object manager
    arObjectManager.onInitialize();
    addARObject();
  }

  // Add AR object
  void addARObject() async {
    final node = ARNode(
      type: NodeType.webGLB,
      uri: "https://example.com/3d_model.glb", // Replace with your model URL
      position: vector.Vector3(0, 0, -1), // 1 meter in front of the user
      scale: vector.Vector3(0.2, 0.2, 0.2), // Adjust scale as needed
    );
    await arObjectManager.addNode(node);
  }

  // Dispose resources
  void dispose() {
    arSessionManager.dispose(); // ARSessionManager handles cleanup
    // No need to explicitly dispose arObjectManager
  }
}
