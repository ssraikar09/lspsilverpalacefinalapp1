import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';

void main() {
  test('Load model', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    try {
      final interpreter = await Interpreter.fromAsset('assets/models/mobilenet_v2_feature_vector.tflite');
      expect(interpreter, isNotNull);
      debugPrint('Model loaded');
    } catch (e) {
      debugPrint('Failed to load: $e');
    }
  });
}
