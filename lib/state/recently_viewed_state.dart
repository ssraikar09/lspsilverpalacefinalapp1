import 'package:flutter/foundation.dart';
import '../models/product.dart';

class RecentlyViewedState extends ChangeNotifier {
  final List<Product> _viewedProducts = [];

  List<Product> get viewedProducts => _viewedProducts;

  void addProduct(Product product) {
    // Remove if it already exists to move it to the front
    _viewedProducts.removeWhere((p) => p.id == product.id);
    
    // Add to the front of the list
    _viewedProducts.insert(0, product);
    
    // Keep only the last 20 viewed products
    if (_viewedProducts.length > 20) {
      _viewedProducts.removeLast();
    }
    
    notifyListeners();
  }
}

final recentlyViewedState = RecentlyViewedState();
