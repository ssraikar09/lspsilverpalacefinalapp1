import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistState extends ChangeNotifier {
  final Set<String> _wishlistProductIds = {};
  
  WishlistState() {
    _loadWishlist();
  }

  Set<String> get wishlistProductIds => _wishlistProductIds;

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('wishlist') ?? [];
    _wishlistProductIds.addAll(savedList);
    notifyListeners();
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('wishlist', _wishlistProductIds.toList());
  }

  bool isInWishlist(String productId) {
    return _wishlistProductIds.contains(productId);
  }

  void toggleWishlist(String productId) {
    if (_wishlistProductIds.contains(productId)) {
      _wishlistProductIds.remove(productId);
    } else {
      _wishlistProductIds.add(productId);
    }
    _saveWishlist();
    notifyListeners();
  }
}

// Global instance for simple state management without extra packages
final WishlistState globalWishlistState = WishlistState();
