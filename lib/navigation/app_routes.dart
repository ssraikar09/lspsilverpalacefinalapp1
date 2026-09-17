import 'package:flutter/material.dart';
import '../screens/product_listing_screen.dart';
import '../screens/product_details_screen.dart';
import '../screens/search_screen.dart';
import '../screens/subcategories_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/mobile_otp_screen.dart';
import '../screens/admin_login_screen.dart';
import '../screens/visual_search_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/recently_viewed_screen.dart';
import '../navigation/main_layout.dart';
import '../screens/categories_screen.dart';

import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_products_screen.dart';
import '../screens/admin/admin_product_form_screen.dart';
import '../screens/admin/admin_categories_screen.dart';
import '../screens/admin/admin_category_form_screen.dart';
import '../screens/admin/admin_business_details_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String main = '/main';
  static const String search = '/search';
  static const String subcategories = '/subcategories';
  static const String productListing = '/products';
  static const String productDetails = '/product-details';
  static const String contact = '/contact';
  static const String mobileOtp = '/mobile-otp';
  static const String adminLogin = '/admin-login';
  static const String categories = '/categories';
  static const String categoryProducts = '/category_products';
  static const String visualSearch = '/visual_search';
  static const String wishlist = '/wishlist';
  static const String recentlyViewed = '/recently_viewed';

  static const String adminDashboard = '/admin/dashboard';
  static const String adminProducts = '/admin/products';
  static const String adminProductForm = '/admin/product_form';
  static const String adminCategories = '/admin/categories';
  static const String adminCategoryForm = '/admin/category_form';
  static const String adminBusinessDetails = '/admin/business_details';

  static Map<String, WidgetBuilder> get routes {
    return {
      welcome: (context) => const WelcomeScreen(),
      main: (context) => const MainLayout(),
      search: (context) => const SearchScreen(),
      subcategories: (context) => const SubcategoriesScreen(),
      categories: (context) => const CategoriesScreen(),
      productListing: (context) => const ProductListingScreen(),
      productDetails: (context) => const ProductDetailsScreen(),
      mobileOtp: (context) => const MobileOtpScreen(),
      adminLogin: (context) => const AdminLoginScreen(),
      visualSearch: (context) {
        final imagePath = ModalRoute.of(context)!.settings.arguments as String;
        return VisualSearchScreen(imagePath: imagePath);
      },
      wishlist: (context) => const WishlistScreen(),
      recentlyViewed: (context) => const RecentlyViewedScreen(),
      contact: (context) => const Scaffold(body: Center(child: Text('Contact Placeholder'))),
      
      adminDashboard: (context) => const AdminDashboardScreen(),
      adminProducts: (context) => const AdminProductsScreen(),
      adminProductForm: (context) => const AdminProductFormScreen(),
      adminCategories: (context) => const AdminCategoriesScreen(),
      adminCategoryForm: (context) => const AdminCategoryFormScreen(),
      adminBusinessDetails: (context) => const AdminBusinessDetailsScreen(),
    };
  }
}
