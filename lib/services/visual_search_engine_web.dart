import 'package:flutter/foundation.dart';

class VisualSearchEngine {
  bool get isInitialized => false;

  Future<void> initialize() async {
    debugPrint('### VISUAL SEARCH ENGINE: WEB ###');
  }

  Future<List<double>> extractFeatureVectorFromBytes(Uint8List imageBytes) async {
    throw Exception('On-device visual AI matching is currently supported on Android.');
  }

  Future<List<double>> extractFeatureVectorFromFile(String filePath) async {
    throw Exception('On-device visual AI matching is currently supported on Android.');
  }

  double cosineSimilarity(List<double> vecA, List<double> vecB) => 0.0;
}
