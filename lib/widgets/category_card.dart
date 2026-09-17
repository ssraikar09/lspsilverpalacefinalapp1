import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import 'custom_network_image.dart';

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final String imageUrl;

  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productListing,
          arguments: {'category': categoryName},
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: CustomNetworkImage(imageUrl: imageUrl),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            categoryName.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
