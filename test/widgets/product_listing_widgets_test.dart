import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_silver_app/models/product.dart';
import 'package:lsp_silver_app/navigation/app_routes.dart';
import 'package:lsp_silver_app/state/wishlist_state.dart';
import 'package:lsp_silver_app/widgets/product_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProductCard Widget Tests', () {
    const testProduct = Product(
      id: 'prod-widget-1',
      name: 'Floral Silver Ring',
      productCode: 'RNG-001',
      category: 'Rings & Toe Rings',
      purity: '92.5',
      description: 'Handcrafted floral ring in 92.5 pure silver',
      imageUrls: [],
      newArrival: true,
      availability: 'In Stock',
    );

    const soldOutProduct = Product(
      id: 'prod-widget-2',
      name: 'Antique Kada',
      productCode: 'KAD-002',
      category: 'Bangles & Kadas',
      purity: '92.5',
      description: 'Antique kada',
      imageUrls: [],
      newArrival: false,
      availability: 'Sold Out',
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({'wishlist': []});
      if (globalWishlistState.isInWishlist('prod-widget-1')) {
        globalWishlistState.toggleWishlist('prod-widget-1');
      }
    });

    testWidgets('renders product name, category, and NEW arrival badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: ProductCard(product: testProduct),
            ),
          ),
        ),
      );

      expect(find.text('FLORAL SILVER RING'), findsOneWidget);
      expect(find.text('Rings & Toe Rings'), findsOneWidget);
      expect(find.text('NEW'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('renders SOLD OUT label when product is not in stock', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: ProductCard(product: soldOutProduct),
            ),
          ),
        ),
      );

      expect(find.text('ANTIQUE KADA'), findsOneWidget);
      expect(find.text('SOLD OUT'), findsOneWidget);
      expect(find.text('NEW'), findsNothing);
    });

    testWidgets('toggles wishlist icon state when favorite button is tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: ProductCard(product: testProduct),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(globalWishlistState.isInWishlist('prod-widget-1'), isFalse);

      // Tap favorite icon
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(globalWishlistState.isInWishlist('prod-widget-1'), isTrue);
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Tap favorite icon again to untoggle
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pump();

      expect(globalWishlistState.isInWishlist('prod-widget-1'), isFalse);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('navigates to product details route on card tap', (tester) async {
      Product? pushedProduct;

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.productDetails) {
              pushedProduct = settings.arguments as Product;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Details Screen')),
              );
            }
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: SizedBox(
                  width: 200,
                  height: 300,
                  child: ProductCard(product: testProduct),
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.byType(ProductCard));
      await tester.pumpAndSettle();

      expect(pushedProduct, isNotNull);
      expect(pushedProduct?.id, 'prod-widget-1');
      expect(find.text('Details Screen'), findsOneWidget);
    });
  });
}
