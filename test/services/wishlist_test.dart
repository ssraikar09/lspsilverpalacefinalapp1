import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lsp_silver_app/state/wishlist_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WishlistState Functionality Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'wishlist': ['prod-101', 'prod-102'],
      });
    });

    test('initializes and loads existing wishlist items from SharedPreferences', () async {
      final wishlist = WishlistState();
      // Allow async _loadWishlist to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(wishlist.isInWishlist('prod-101'), isTrue);
      expect(wishlist.isInWishlist('prod-102'), isTrue);
      expect(wishlist.isInWishlist('prod-unknown'), isFalse);
      expect(wishlist.wishlistProductIds.length, 2);
    });

    test('toggling an unlisted product adds it to the wishlist and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final wishlist = WishlistState();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      var listenerNotified = false;
      wishlist.addListener(() {
        listenerNotified = true;
      });

      expect(wishlist.isInWishlist('prod-201'), isFalse);

      wishlist.toggleWishlist('prod-201');

      expect(wishlist.isInWishlist('prod-201'), isTrue);
      expect(wishlist.wishlistProductIds.contains('prod-201'), isTrue);
      expect(listenerNotified, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('wishlist'), contains('prod-201'));
    });

    test('toggling an already wishlisted product removes it from the wishlist', () async {
      SharedPreferences.setMockInitialValues({
        'wishlist': ['prod-301'],
      });
      final wishlist = WishlistState();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(wishlist.isInWishlist('prod-301'), isTrue);

      wishlist.toggleWishlist('prod-301');

      expect(wishlist.isInWishlist('prod-301'), isFalse);
      expect(wishlist.wishlistProductIds.contains('prod-301'), isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('wishlist'), isNot(contains('prod-301')));
    });

    test('handles empty or missing SharedPreferences gracefully', () async {
      SharedPreferences.setMockInitialValues({});
      final wishlist = WishlistState();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(wishlist.wishlistProductIds, isEmpty);
      expect(wishlist.isInWishlist('any-id'), isFalse);
    });
  });
}
