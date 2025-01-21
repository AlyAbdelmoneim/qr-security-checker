import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../services/safety_checker.dart';

class ARTextOverlay extends StatefulWidget {
  @override
  _ARTextOverlayState createState() => _ARTextOverlayState();
}

class _ARTextOverlayState extends State<ARTextOverlay> {
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();
  String? _detectedLink;
  String _validationResult = '';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Text Detection & Safety Checker")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing) const CircularProgressIndicator(),
            if (!_isProcessing && _detectedLink == null)
              ElevatedButton(
                onPressed: _detectTextAndExtractLink,
                child: const Text("Start Text Detection"),
              ),
            if (_detectedLink != null)
              Column(
                children: [
                  Text("Detected Link: $_detectedLink"),
                  ElevatedButton(
                    onPressed: _validateLink,
                    child: const Text("Validate Link"),
                  ),
                ],
              ),
            if (_validationResult.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Validation Result: $_validationResult",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _detectTextAndExtractLink() async {
    setState(() => _isProcessing = true);

    // Replace this with your camera feed or AR-generated image
    final InputImage inputImage = InputImage.fromFilePath('path_to_image.jpg');

    try {
      final RecognizedText recognizedText =
      await _textRecognizer.processImage(inputImage);

      // Use regex to extract links
      final RegExp linkRegex = RegExp(r'(https?:\/\/[^\s]+)');
      final matches =
      linkRegex.allMatches(recognizedText.text).map((m) => m.group(0)).toList();

      if (matches.isNotEmpty) {
        setState(() {
          _detectedLink = matches.first; // Take the first detected link
        });
      } else {
        setState(() {
          _detectedLink = null;
          _validationResult = "No links detected.";
        });
      }
    } catch (e) {
      setState(() => _validationResult = "Error detecting text: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _validateLink() async {
    if (_detectedLink != null) {
      final result = await SafetyChecker.checkUrlSafety(_detectedLink!);
      setState(() {
        _validationResult =
        result == null ? "The link is safe." : "Warning: $result detected!";
      });
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }
}
