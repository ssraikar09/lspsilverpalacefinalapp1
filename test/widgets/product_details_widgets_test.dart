import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_silver_app/models/product.dart';
import 'package:lsp_silver_app/screens/product_details_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProductDetailsScreen Widget Tests', () {
    const sampleProduct = Product(
      id: 'prod-detail-01',
      name: 'Silver Peacock Payal',
      productCode: 'PAY-PEA-01',
      category: 'Anklets & Payal',
      subcategory: 'Payal / Anklets',
      purity: '92.5',
      weight: '45g',
      size: '10 inch',
      material: 'Fine Silver',
      description: 'Traditional oxidised silver payal with engraved peacock motifs.',
      imageUrls: [],
      availability: 'In Stock',
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({'wishlist': [], 'recently_viewed': []});
    });

    testWidgets('displays error fallback view when no product arguments are provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProductDetailsScreen(),
        ),
      );

      expect(find.text('Product details not found.'), findsOneWidget);
    });

    testWidgets('renders product details specifications, description, and action buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                settings: const RouteSettings(arguments: sampleProduct),
                builder: (_) => const ProductDetailsScreen(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title in app bar and header
      expect(find.text('SILVER PEACOCK PAYAL'), findsWidgets);

      // Verify product specifications
      expect(find.text('Specifications'), findsOneWidget);
      expect(find.text('Fine Silver'), findsOneWidget);
      expect(find.text('45g'), findsOneWidget);
      expect(find.text('10 inch'), findsOneWidget);
      expect(find.text('Anklets & Payal'), findsOneWidget);

      // Verify description
      expect(find.text('Description'), findsOneWidget);
      expect(find.textContaining('peacock motifs'), findsOneWidget);

      // Verify action buttons
      expect(find.text('CONTACT SHOP'), findsOneWidget);
      expect(find.text('WHATSAPP'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });
  });
}
