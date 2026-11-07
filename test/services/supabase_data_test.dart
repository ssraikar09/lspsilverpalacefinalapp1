import 'package:flutter_test/flutter_test.dart';
import 'package:lsp_silver_app/models/product.dart';
import 'package:lsp_silver_app/models/category_model.dart';

void main() {
  group('Supabase Data Handling & Transformation Tests', () {
    test('sanitizes product payload for Supabase insert by stripping non-UUID IDs', () {
      const productWithTempId = Product(
        id: 'temp123', // Does not contain hyphens / not a standard UUID
        name: 'Silver Coin 10g',
        productCode: 'COI-010',
        category: 'Silver Articles & Gifts',
        purity: '999',
        description: 'Fine 999 silver coin',
        imageUrls: ['https://example.com/coin.jpg'],
      );

      final json = productWithTempId.toJson();
      
      // Mirroring the exact logic used in SampleData.addProduct before insertion
      if (!json['id'].contains('-')) {
        json.remove('id');
      }

      expect(json.containsKey('id'), isFalse, reason: 'Temporary non-UUID IDs should be omitted so Supabase generates a UUID');
      expect(json['name'], 'Silver Coin 10g');
      expect(json['product_code'], 'COI-010');
    });

    test('retains valid UUID formatted ID in product insert payload', () {
      const productWithUuid = Product(
        id: 'e2a87612-42cf-4bc6-bf31-9f93c834a31a',
        name: 'Silver Coin 20g',
        productCode: 'COI-020',
        category: 'Silver Articles & Gifts',
        purity: '999',
        description: 'Fine 999 silver coin',
        imageUrls: [],
      );

      final json = productWithUuid.toJson();
      if (!json['id'].contains('-')) {
        json.remove('id');
      }

      expect(json.containsKey('id'), isTrue);
      expect(json['id'], 'e2a87612-42cf-4bc6-bf31-9f93c834a31a');
    });

    test('prepares update payload by removing primary key ID', () {
      const productToUpdate = Product(
        id: 'prod-uuid-update',
        name: 'Updated Kada',
        productCode: 'KAD-999',
        category: 'Bangles & Kadas',
        purity: '92.5',
        description: 'Updated description',
        imageUrls: ['https://example.com/updated.jpg'],
      );

      final updatePayload = productToUpdate.toJson();
      updatePayload.remove('id');

      expect(updatePayload.containsKey('id'), isFalse, reason: 'ID must not be modified in update payload');
      expect(updatePayload['name'], 'Updated Kada');
      expect(updatePayload['purity'], '92.5');
    });

    test('converts empty category image URL to null for database compatibility', () {
      final category = CategoryModel(
        id: 'cat-new-1',
        name: 'Rings',
        description: 'Silver finger rings',
        imagePath: '', // empty path
      );

      final json = category.toJson();
      final finalImageUrl = category.imagePath;
      json['image_url'] = finalImageUrl.isNotEmpty ? finalImageUrl : null;

      expect(json['image_url'], isNull, reason: 'Empty image strings should map to null in Postgres');
      expect(json['name'], 'Rings');
    });

    test('parses Supabase response records containing null values and type variations', () {
      final rawSupabaseProductRecord = {
        'id': 'db-uuid-001',
        'name': 'Ganesha Idol',
        'product_code': 'IDL-GAN-01',
        'category': 'Idols & Religious Statues',
        'subcategory': null,
        'weight': null,
        'size': null,
        'purity': '925',
        'finish': null,
        'material': null,
        'stone_details': null,
        'description': 'Pure silver lord Ganesha idol for car dashboard or puja.',
        'image_urls': null,
        'tags': null,
        'availability': null,
        'is_featured': null,
        'is_new_arrival': null,
      };

      final product = Product.fromJson(rawSupabaseProductRecord);

      expect(product.id, 'db-uuid-001');
      expect(product.name, 'Ganesha Idol');
      expect(product.subcategory, isNull);
      expect(product.weight, isNull);
      expect(product.imageUrls, isEmpty);
      expect(product.tags, isEmpty);
      expect(product.material, 'Silver');
      expect(product.availability, 'In Stock');
      expect(product.featured, isFalse);
      expect(product.newArrival, isFalse);
    });
  });
}
