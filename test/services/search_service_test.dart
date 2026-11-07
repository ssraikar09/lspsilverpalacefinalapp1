import 'package:flutter_test/flutter_test.dart';
import 'package:lsp_silver_app/data/sample_data.dart';
import 'package:lsp_silver_app/models/product.dart';
import 'package:lsp_silver_app/services/search_service.dart';

void main() {
  group('SearchService Tests', () {
    late SearchService searchService;

    final testProduct1 = const Product(
      id: 'test-1',
      name: 'Oxidised Silver Bangles',
      productCode: 'BAN-001',
      category: 'Bangles & Kadas',
      subcategory: 'Bangles',
      purity: '92.5',
      material: 'Silver',
      description: 'Traditional oxidised silver bangles with floral motifs',
      imageUrls: ['https://example.com/bangles.jpg'],
      tags: ['antique', 'traditional', 'wedding'],
    );

    final testProduct2 = const Product(
      id: 'test-2',
      name: 'Pure Silver Pooja Thali',
      productCode: 'POO-002',
      category: 'Pooja & Ritual Items',
      subcategory: 'Pooja / Ritual Item',
      purity: '99.9',
      material: 'Pure Silver',
      description: 'Auspicious silver pooja thali set with diya and bell',
      imageUrls: ['https://example.com/thali.jpg'],
      tags: ['pooja', 'festival', 'auspicious'],
    );

    setUp(() {
      SampleData.products = [testProduct1, testProduct2];
      searchService = SearchService();
    });

    tearDown(() {
      searchService.dispose();
      SampleData.products = [];
    });

    test('returns empty SearchResult when search query is empty or whitespace', () {
      final resultEmpty = searchService.search('');
      expect(resultEmpty.products, isEmpty);
      expect(resultEmpty.correctedQuery, isEmpty);

      final resultWhitespace = searchService.search('   ');
      expect(resultWhitespace.products, isEmpty);
      expect(resultWhitespace.correctedQuery, isEmpty);
    });

    test('finds products by exact title keyword match', () {
      final result = searchService.search('Bangles');
      expect(result.products, isNotEmpty);
      expect(result.products.first.id, 'test-1');
      expect(result.products.first.name, contains('Bangles'));
    });

    test('finds products matching category or tag', () {
      final resultTag = searchService.search('wedding');
      expect(resultTag.products, isNotEmpty);
      expect(resultTag.products.first.id, 'test-1');

      final resultCat = searchService.search('pooja');
      expect(resultCat.products, isNotEmpty);
      expect(resultCat.products.first.id, 'test-2');
    });

    test('performs fuzzy typo correction via catalog vocabulary', () {
      // "Bangles" typo -> "Banglez" (dist 1)
      final result = searchService.search('Banglez');
      expect(result.correctedQuery, contains('bangles'));
      expect(result.products, isNotEmpty);
      expect(result.products.first.id, 'test-1');
    });

    test('returns empty product list when query has no matching tokens in catalog', () {
      final result = searchService.search('diamond platinum watch');
      expect(result.products, isEmpty);
    });

    test('rebuilds vocabulary when globalProductState notifies', () {
      final testProduct3 = const Product(
        id: 'test-3',
        name: 'Ghungroo Anklets',
        productCode: 'ANK-003',
        category: 'Anklets & Payal',
        purity: '92.5',
        description: 'Silver anklets',
        imageUrls: [],
        tags: ['ghungroo'],
      );

      SampleData.products.add(testProduct3);
      SampleData.globalProductState.value++;

      final result = searchService.search('anklets');
      expect(result.products.any((p) => p.id == 'test-3'), isTrue);
    });
  });
}
