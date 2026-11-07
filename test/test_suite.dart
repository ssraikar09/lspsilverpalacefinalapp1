import 'package:flutter_test/flutter_test.dart';

import 'models/product_test.dart' as product_test;
import 'models/category_model_test.dart' as category_model_test;
import 'services/search_service_test.dart' as search_service_test;
import 'services/wishlist_test.dart' as wishlist_test;
import 'services/notification_service_test.dart' as notification_service_test;
import 'services/supabase_data_test.dart' as supabase_data_test;
import 'widgets/category_widgets_test.dart' as category_widgets_test;
import 'widgets/product_listing_widgets_test.dart' as product_listing_widgets_test;
import 'widgets/product_details_widgets_test.dart' as product_details_widgets_test;
import 'screens/admin_login_validation_test.dart' as admin_login_validation_test;
import 'integration/navigation_test.dart' as navigation_test;

void main() {
  group('LSP Silver Palace Automated Test Suite', () {
    group('Models Tests', () {
      product_test.main();
      category_model_test.main();
    });

    group('Services Tests', () {
      search_service_test.main();
      wishlist_test.main();
      notification_service_test.main();
      supabase_data_test.main();
    });

    group('Widgets Tests', () {
      category_widgets_test.main();
      product_listing_widgets_test.main();
      product_details_widgets_test.main();
    });

    group('Screens & Validation Tests', () {
      admin_login_validation_test.main();
    });

    group('Integration & Navigation Tests', () {
      navigation_test.main();
    });
  });
}
