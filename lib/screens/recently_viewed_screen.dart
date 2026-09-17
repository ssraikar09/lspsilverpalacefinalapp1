import 'package:flutter/material.dart';
import '../state/recently_viewed_state.dart';
import '../widgets/product_card.dart';

class RecentlyViewedScreen extends StatelessWidget {
  const RecentlyViewedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RECENTLY VIEWED',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            letterSpacing: 2.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: recentlyViewedState,
        builder: (context, _) {
          final products = recentlyViewedState.viewedProducts;
          if (products.isEmpty) {
            return const Center(child: Text('You have not viewed any products yet.'));
          }
          
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
              );
            },
          );
        },
      ),
    );
  }
}
