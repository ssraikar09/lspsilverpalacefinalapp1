import 'package:flutter_test/flutter_test.dart';
import 'package:lsp_silver_app/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('instantiates with all required fields', () {
      const product = Product(
        id: 'prod-001',
        name: 'Silver Antique Kada',
        productCode: 'PRD-KAD-01',
        category: 'Bangles & Kadas',
        purity: '92.5',
        description: 'Handcrafted solid 92.5 silver antique kada with floral carvings.',
        imageUrls: ['https://example.com/kada1.jpg', 'https://example.com/kada2.jpg'],
      );

      expect(product.id, 'prod-001');
      expect(product.name, 'Silver Antique Kada');
      expect(product.productCode, 'PRD-KAD-01');
      expect(product.category, 'Bangles & Kadas');
      expect(product.purity, '92.5');
      expect(product.description, contains('floral carvings'));
      expect(product.imageUrls.length, 2);
      expect(product.availability, 'In Stock');
      expect(product.material, isNull);
      expect(product.featured, false);
      expect(product.newArrival, false);
      expect(product.tags, isEmpty);
    });

    test('serializes to and from complete JSON correctly', () {
      final jsonMap = {
        'id': 'prod-002',
        'name': 'Ghungroo Payal',
        'product_code': 'PRD-PAY-02',
        'category': 'Anklets & Payal',
        'subcategory': 'Bridal Payal',
        'weight': '85g',
        'size': '10.5 inch',
        'purity': '925 Fine Silver',
        'finish': 'Oxidised',
        'material': '925 Pure Silver',
        'stone_details': 'None',
        'description': 'Traditional bridal payal with rhythmic silver bells.',
        'image_urls': ['https://example.com/payal.jpg'],
        'tags': ['bridal', 'traditional', 'wedding'],
        'availability': 'Available on Order',
        'is_featured': true,
        'is_new_arrival': true,
      };

      final product = Product.fromJson(jsonMap);

      expect(product.id, 'prod-002');
      expect(product.name, 'Ghungroo Payal');
      expect(product.productCode, 'PRD-PAY-02');
      expect(product.subcategory, 'Bridal Payal');
      expect(product.weight, '85g');
      expect(product.size, '10.5 inch');
      expect(product.material, '925 Pure Silver');
      expect(product.featured, true);
      expect(product.newArrival, true);
      expect(product.tags, contains('bridal'));

      final serialized = product.toJson();
      expect(serialized['id'], 'prod-002');
      expect(serialized['name'], 'Ghungroo Payal');
      expect(serialized['product_code'], 'PRD-PAY-02');
      expect(serialized['category'], 'Anklets & Payal');
      expect(serialized['is_featured'], true);
      expect(serialized['is_new_arrival'], true);
    });

    test('handles legacy / alternate JSON key naming conventions', () {
      final jsonMap = {
        'id': 'prod-003',
        'name': 'Silver Challa',
        'productCode': 'PRD-CHA-03',
        'category': 'Earrings & Challa',
        'purity': '92.5',
        'description': 'Ornate waist challa keychain.',
        'imageUrls': ['https://example.com/challa.jpg'],
        'stoneDetails': 'Ruby Cubic Zirconia',
        'featured': true,
        'newArrival': false,
      };

      final product = Product.fromJson(jsonMap);

      expect(product.productCode, 'PRD-CHA-03');
      expect(product.stoneDetails, 'Ruby Cubic Zirconia');
      expect(product.featured, true);
      expect(product.imageUrls, contains('https://example.com/challa.jpg'));
    });

    test('handles empty or missing optional fields gracefully with defaults', () {
      final jsonMap = {
        'id': 'prod-004',
        'name': 'Plain Toe Ring',
        'product_code': 'PRD-TOE-04',
        'category': 'Rings & Toe Rings',
        'purity': '925',
        'description': 'Pair of plain silver toe rings.',
      };

      final product = Product.fromJson(jsonMap);

      expect(product.subcategory, isNull);
      expect(product.weight, isNull);
      expect(product.size, isNull);
      expect(product.finish, isNull);
      expect(product.material, 'Silver');
      expect(product.imageUrls, isEmpty);
      expect(product.tags, isEmpty);
      expect(product.availability, 'In Stock');
      expect(product.featured, false);
      expect(product.newArrival, false);
    });
  });
}
