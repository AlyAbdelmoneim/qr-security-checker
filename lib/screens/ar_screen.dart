import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:security_checker/screens/safety_checker.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ARScreen extends StatefulWidget {
  final VoidCallback onRestart;

  const ARScreen({Key? key, required this.onRestart}) : super(key: key);

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  ArCoreController? arCoreController;
  bool isControllerDisposed = false;
  Color objectColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluateSafety());
  }

  Future<void> _evaluateSafety() async {
    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final scannedCode = args?['scannedCode'] as String?;
      if (scannedCode != null) {
        final result = await SafetyChecker.checkUrlSafety(scannedCode);
        setState(() {
          objectColor = result == 'The URL is safe' ? Colors.green : Colors.red;
        });
        _add3DObject();
      }
    } catch (e) {
      print('Error during safety evaluation: $e');
    }
  }

  void _add3DObject() {
    try {
      if (arCoreController != null && !isControllerDisposed) {
        _removeAllNodes();
        final material = ArCoreMaterial(color: objectColor);
        final sphere = ArCoreSphere(materials: [material], radius: 0.2);
        final node = ArCoreNode(
          shape: sphere,
          position: vm.Vector3(0, 0, -1.5),
          name: 'uniqueNode',
        );
        arCoreController?.addArCoreNode(node);
      }
    } catch (e) {
      print('Error adding 3D object: $e');
    }
  }

  void _removeAllNodes() {
    try {
      if (arCoreController != null && !isControllerDisposed) {
        arCoreController?.removeNode(nodeName: 'uniqueNode');
      }
    } catch (e) {
      print('Error removing AR nodes: $e');
    }
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    isControllerDisposed = false;
  }

  void _disposeArController() {
    try {
      if (arCoreController != null && !isControllerDisposed) {
        _removeAllNodes();
        arCoreController?.dispose();
        isControllerDisposed = true;
      }
    } catch (e) {
      print('Error disposing ARCoreController: $e');
    }
  }

  @override
  void dispose() {
    _disposeArController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _disposeArController();
              widget.onRestart();
            },
          ),
        ],
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
      ),
    );
  }
}
