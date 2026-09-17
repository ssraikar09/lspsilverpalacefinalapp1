
import 'package:flutter/foundation.dart';

class VisualSearchEngine {
  bool get isInitialized => false;
  Future<void> initialize() async {
    debugPrint('### VISUAL SEARCH ENGINE: STUB ###');
  }
  Future<List<double>> extractFeatureVectorFromBytes(Uint8List imageBytes) async => [];
  Future<List<double>> extractFeatureVectorFromFile(String filePath) async => [];
  double cosineSimilarity(List<double> vecA, List<double> vecB) => 0.0;
}
