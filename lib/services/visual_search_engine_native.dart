import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
class VisualSearchEngine {
  Interpreter? _interpreter;
  bool _isInitialized = false;

  final int _inputSize = 224; // MobileNetV2 standard

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    debugPrint('### VISUAL SEARCH ENGINE: NATIVE ANDROID ###');
    if (_isInitialized) return;
    if (kIsWeb) return; // Not supported on web currently
    
    try {
      debugPrint('VISUAL_AI: MODEL = assets/models/mobilenet_v2_feature_vector.tflite');
      _interpreter = await Interpreter.fromAsset('assets/models/mobilenet_v2_feature_vector.tflite');
      _isInitialized = true;
      debugPrint('VISUAL_AI: MODEL LOAD = SUCCESS');
      
      var inputTensor = _interpreter!.getInputTensor(0);
      var outputTensor = _interpreter!.getOutputTensor(0);
      debugPrint('VISUAL_AI: MODEL INPUT SHAPE = ${inputTensor.shape}');
      debugPrint('VISUAL_AI: MODEL INPUT TYPE = ${inputTensor.type}');
      debugPrint('VISUAL_AI: MODEL OUTPUT SHAPE = ${outputTensor.shape}');
      debugPrint('VISUAL_AI: MODEL OUTPUT TYPE = ${outputTensor.type}');
      
    } catch (e, stackTrace) {
      debugPrint('VISUAL_AI: ERROR = $e\n$stackTrace');
      throw Exception('TFLite initialization failed: $e');
    }
  }

  Future<List<double>> extractFeatureVectorFromBytes(Uint8List imageBytes) async {
    if (!_isInitialized || _interpreter == null) {
      throw Exception('Engine not initialized');
    }

    // Decode and resize
    img.Image? decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      throw Exception('Failed to decode image');
    }
    
    img.Image resizedImage = img.copyResize(decodedImage, width: _inputSize, height: _inputSize);

    // Preprocess to [-1, 1] for MobileNetV2
    var input = List.generate(1, (i) => List.generate(_inputSize, (y) => List.generate(_inputSize, (x) => List.filled(3, 0.0))));
    
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        img.Pixel pixel = resizedImage.getPixelSafe(x, y);
        input[0][y][x][0] = (pixel.r / 127.5) - 1.0;
        input[0][y][x][1] = (pixel.g / 127.5) - 1.0;
        input[0][y][x][2] = (pixel.b / 127.5) - 1.0;
      }
    }

    // Output tensor for MobileNetV2 Feature Vector is typically [1, 1280]
    // Wait, let's look at the actual model shape and adjust dynamically if possible.
    // For now, we still allocate a flat list, but we can use the exact length.
    var outputTensor = _interpreter!.getOutputTensor(0);
    int outLen = outputTensor.shape.fold(1, (p, e) => p * e);
    var output = List.filled(outLen, 0.0).reshape(outputTensor.shape);

    // Run inference
    _interpreter!.run(input, output);

    // Flatten and return
    List<double> featureVector;
    if (outputTensor.shape.length == 2) {
      featureVector = List<double>.from(output[0]);
    } else {
      featureVector = List<double>.from(output.expand((x) => x));
    }
    
    debugPrint('VISUAL_AI: USER EMBEDDING SUCCESS = true');
    debugPrint('VISUAL_AI: USER EMBEDDING LENGTH = ${featureVector.length}');
    
    return _normalizeVector(featureVector);
  }

  Future<List<double>> extractFeatureVectorFromFile(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return extractFeatureVectorFromBytes(bytes);
  }

  // L2 Normalization for Cosine Similarity
  List<double> _normalizeVector(List<double> vector) {
    double sum = 0.0;
    for (var v in vector) {
      sum += v * v;
    }
    double magnitude = sqrt(sum);
    if (magnitude == 0) return vector;
    return vector.map((v) => v / magnitude).toList();
  }

  double cosineSimilarity(List<double> vecA, List<double> vecB) {
    if (vecA.length != vecB.length) return 0.0;
    
    double dotProduct = 0.0;
    for (int i = 0; i < vecA.length; i++) {
      dotProduct += vecA[i] * vecB[i];
    }
    // Since vectors are L2 normalized, dot product is cosine similarity
    return dotProduct;
  }
}
