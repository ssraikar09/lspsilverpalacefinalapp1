import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../widgets/product_card.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String? _selectedCategory;
  String? _selectedSubcategory;
  
  // Filter states (Removed)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _selectedCategory = args['category'] as String?;
      _selectedSubcategory = args['subcategory'] as String?;
    } else if (args is String) {
      _selectedCategory = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SampleData.globalProductState,
      builder: (context, value, child) {
        var categoryProducts = SampleData.products.where((p) {
          if (_selectedCategory != null && p.category != _selectedCategory) return false;
          if (_selectedSubcategory != null && p.subcategory != _selectedSubcategory) return false;
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Text(
              (_selectedSubcategory ?? _selectedCategory ?? 'Products').toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                letterSpacing: 2.0,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFD4AF37),
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: Colors.white.withValues(alpha: 0.05),
                height: 1.0,
              ),
            ),
          ),
          body: SafeArea(
            child: categoryProducts.isEmpty
                ? const Center(child: Text('No products match your filters.', style: TextStyle(color: Colors.white54)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          '${categoryProducts.length} Items',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.70,
                          ),
                          itemCount: categoryProducts.length,
                          itemBuilder: (context, index) {
                            return ProductCard(product: categoryProducts[index]);
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
