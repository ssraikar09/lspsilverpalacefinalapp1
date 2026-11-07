import 'package:flutter_test/flutter_test.dart';
import 'package:lsp_silver_app/models/category_model.dart';

void main() {
  group('CategoryModel Tests', () {
    test('instantiates with all required fields', () {
      final category = CategoryModel(
        id: 'cat-001',
        name: 'Payal / Anklets',
        description: 'Exquisite silver payals and traditional anklets',
        imagePath: 'https://example.com/payal.jpg',
      );

      expect(category.id, 'cat-001');
      expect(category.name, 'Payal / Anklets');
      expect(category.description, 'Exquisite silver payals and traditional anklets');
      expect(category.imagePath, 'https://example.com/payal.jpg');
    });

    test('serializes to and from JSON with image_url correctly', () {
      final jsonMap = {
        'id': 'cat-002',
        'name': 'Kadas & Bangles',
        'description': 'Handcrafted kadas for men and women',
        'image_url': 'https://example.com/kada.jpg',
      };

      final category = CategoryModel.fromJson(jsonMap);

      expect(category.id, 'cat-002');
      expect(category.name, 'Kadas & Bangles');
      expect(category.description, 'Handcrafted kadas for men and women');
      expect(category.imagePath, 'https://example.com/kada.jpg');

      final serialized = category.toJson();
      expect(serialized['id'], 'cat-002');
      expect(serialized['name'], 'Kadas & Bangles');
      expect(serialized['description'], 'Handcrafted kadas for men and women');
      expect(serialized['image_url'], 'https://example.com/kada.jpg');
    });

    test('supports fallback imagePath JSON key', () {
      final jsonMap = {
        'id': 'cat-003',
        'name': 'Silver Idols',
        'description': 'Deity idols crafted in pure silver',
        'imagePath': 'assets/images/idols.jpg',
      };

      final category = CategoryModel.fromJson(jsonMap);

      expect(category.imagePath, 'assets/images/idols.jpg');
    });

    test('handles missing description and missing image gracefully with default empty strings', () {
      final jsonMap = {
        'id': 'cat-004',
        'name': 'Pooja Articles',
      };

      final category = CategoryModel.fromJson(jsonMap);

      expect(category.id, 'cat-004');
      expect(category.name, 'Pooja Articles');
      expect(category.description, isEmpty);
      expect(category.imagePath, isEmpty);
    });
  });
}
