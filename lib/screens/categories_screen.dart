import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../widgets/custom_network_image.dart';
import '../navigation/main_layout.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFD4AF37);
    const Color darkGrey = Color(0xFF161616);
    const Color lightGrey = Color(0xFFAAAAAA);

    return ValueListenableBuilder<int>(
      valueListenable: SampleData.globalProductState,
      builder: (context, value, child) {
        final activeCategories = SampleData.categories;
        
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: goldColor, size: 24),
              onPressed: () => MainLayoutState.navigateToHome(context),
            ),
            title: const Text(
              'Categories',
              style: TextStyle(
                color: goldColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: lightGrey, size: 24),
                onPressed: () {
                  Navigator.pushNamed(context, '/search');
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: Colors.white.withValues(alpha: 0.05),
                height: 1.0,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: activeCategories.length,
              itemBuilder: (context, index) {
                final categoryName = activeCategories[index];
                final categoryProducts = SampleData.products.where((p) => p.category == categoryName).toList();
                final itemCount = categoryProducts.length;
                final imageUrl = categoryProducts.isNotEmpty && categoryProducts.first.imageUrls.isNotEmpty 
                    ? categoryProducts.first.imageUrls.first 
                    : '';
                
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/products', 
                      arguments: {'category': categoryName},
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: darkGrey,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        // Category Image Square
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CustomNetworkImage(
                              imageUrl: imageUrl,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Text Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                categoryName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$itemCount Items',
                                style: TextStyle(
                                  color: lightGrey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right Arrow
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
