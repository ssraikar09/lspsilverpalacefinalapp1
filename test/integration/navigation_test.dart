import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lsp_silver_app/navigation/app_routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation & Route Registry Integration Tests', () {
    test('verifies all expected core routes exist in AppRoutes.routes', () {
      final routes = AppRoutes.routes;

      expect(routes.containsKey(AppRoutes.welcome), isTrue);
      expect(routes.containsKey(AppRoutes.main), isTrue);
      expect(routes.containsKey(AppRoutes.search), isTrue);
      expect(routes.containsKey(AppRoutes.subcategories), isTrue);
      expect(routes.containsKey(AppRoutes.categories), isTrue);
      expect(routes.containsKey(AppRoutes.productListing), isTrue);
      expect(routes.containsKey(AppRoutes.productDetails), isTrue);
      expect(routes.containsKey(AppRoutes.mobileOtp), isTrue);
      expect(routes.containsKey(AppRoutes.adminLogin), isTrue);
      expect(routes.containsKey(AppRoutes.visualSearch), isTrue);
      expect(routes.containsKey(AppRoutes.wishlist), isTrue);
      expect(routes.containsKey(AppRoutes.recentlyViewed), isTrue);
      expect(routes.containsKey(AppRoutes.contact), isTrue);
      expect(routes.containsKey(AppRoutes.adminDashboard), isTrue);
      expect(routes.containsKey(AppRoutes.adminProducts), isTrue);
      expect(routes.containsKey(AppRoutes.adminProductForm), isTrue);
      expect(routes.containsKey(AppRoutes.adminCategories), isTrue);
      expect(routes.containsKey(AppRoutes.adminCategoryForm), isTrue);
      expect(routes.containsKey(AppRoutes.adminBusinessDetails), isTrue);
    });

    testWidgets('successfully navigates to registered route using Navigator.pushNamed', (tester) async {
      final testRoutes = <String, WidgetBuilder>{
        '/': (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/target'),
                child: const Text('Go To Target'),
              ),
            ),
        '/target': (context) => const Scaffold(
              body: Text('Target Route Reached'),
            ),
      };

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: testRoutes,
        ),
      );

      expect(find.text('Go To Target'), findsOneWidget);

      await tester.tap(find.text('Go To Target'));
      await tester.pumpAndSettle();

      expect(find.text('Target Route Reached'), findsOneWidget);
    });

    testWidgets('renders placeholder contact route from AppRoutes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => AppRoutes.routes[AppRoutes.contact]!(context),
          ),
        ),
      );

      expect(find.text('Contact Placeholder'), findsOneWidget);
    });
  });
}
