import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lsp_silver_app/navigation/app_routes.dart';
import 'package:lsp_silver_app/widgets/category_card.dart';

void main() {
  group('CategoryCard Widget Tests', () {
    testWidgets('renders category name in uppercase', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              categoryName: 'Silver Bangles',
              imageUrl: '',
            ),
          ),
        ),
      );

      expect(find.text('SILVER BANGLES'), findsOneWidget);
      expect(find.byIcon(Icons.diamond_outlined), findsOneWidget);
    });

    testWidgets('navigates to product listing route with category arguments on tap', (tester) async {
      String? pushedRouteName;
      dynamic pushedArguments;

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.productListing) {
              pushedRouteName = settings.name;
              pushedArguments = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Product Listing Target')),
              );
            }
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: CategoryCard(
                  categoryName: 'Pooja Articles',
                  imageUrl: '',
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('POOJA ARTICLES'), findsOneWidget);

      await tester.tap(find.byType(CategoryCard));
      await tester.pumpAndSettle();

      expect(pushedRouteName, AppRoutes.productListing);
      expect(pushedArguments, isA<Map<String, dynamic>>());
      expect((pushedArguments as Map<String, dynamic>)['category'], 'Pooja Articles');
      expect(find.text('Product Listing Target'), findsOneWidget);
    });
  });
}
