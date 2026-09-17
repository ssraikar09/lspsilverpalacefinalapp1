import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../state/wishlist_state.dart';
import '../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WISHLIST'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: globalWishlistState,
          builder: (context, _) {
            final wishlistIds = globalWishlistState.wishlistProductIds;
            
            if (wishlistIds.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Wishlist is Empty',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explore our catalogue to save your favorite silver pieces.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final wishlistedProducts = SampleData.products
                .where((p) => wishlistIds.contains(p.id))
                .toList();

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: wishlistedProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: wishlistedProducts[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
