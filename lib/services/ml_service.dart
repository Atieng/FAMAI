import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('plant_disease_model.tflite');
      final labelsData = await rootBundle.loadString('assets/ml/labels.txt');
      _labels = labelsData.split('\n');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<String?> runInference(String imagePath) async {
    if (_interpreter == null || _labels == null) {
      print('Model not loaded');
      return null;
    }

    final imageData = await rootBundle.load(imagePath);
    final image = img.decodeImage(imageData.buffer.asUint8List())!;
    final resizedImage = img.copyResize(image, width: 224, height: 224);

    final input = _preprocessImage(resizedImage);
    final output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);

    _interpreter!.run(input, output);

    final topResultIndex = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));
    return _labels![topResultIndex];
  }

  Uint8List _preprocessImage(img.Image image) {
    return image.getBytes(order: img.ChannelOrder.rgb);
  }

  void dispose() {
    _interpreter?.close();
  }
}
