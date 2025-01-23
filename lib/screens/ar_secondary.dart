import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:security_checker/screens/safety_checker.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ARScreenSecondary extends StatefulWidget {
  const ARScreenSecondary({Key? key}) : super(key: key);

  @override
  State<ARScreenSecondary> createState() => _ARScreenSecondaryState();
}

class _ARScreenSecondaryState extends State<ARScreenSecondary> {
  ArCoreController? arCoreController;
  String? scannedCode;
  String safetyStatus = 'Checking...';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String?>;
    scannedCode = args['scannedCode'];
    _checkSafety();
  }

  Future<void> _checkSafety() async {
    if (scannedCode != null) {
      String result = await SafetyChecker.checkUrlSafety(scannedCode!);
      setState(() {
        safetyStatus = result.contains('Safe') ? 'Safe' : 'Unsafe';
        _add3DObject();
      });
    }
  }

  void _add3DObject() {
    final material = ArCoreMaterial(color: safetyStatus == 'Safe' ? Colors.green : Colors.red);
    final cube = ArCoreCube(materials: [material], size: vm.Vector3(0.2, 0.2, 0.2));
    final node = ArCoreNode(
      shape: cube,
      position: vm.Vector3(0, 0, -1), // 1 meter in front
    );
    arCoreController?.addArCoreNode(node);
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
  }

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Visualization (Secondary)')),
      body: Stack(
        children: [
          ArCoreView(onArCoreViewCreated: _onArCoreViewCreated),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/qrSecondary');
              },
              child: const Text('Rescan'),
            ),
          ),
        ],
      ),
    );
  }
}