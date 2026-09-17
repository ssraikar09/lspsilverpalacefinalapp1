import 'dart:io';
import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorPlaceholder(context);
    }
    
    if (!imageUrl.startsWith('http')) {
      return Image.file(
        File(imageUrl),
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Image.file load error: $error\n$stackTrace');
          return _buildErrorPlaceholder(context);
        },
      );
    }

    return Image.network(
      imageUrl,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Image.network load error: $error\n$stackTrace');
        return _buildErrorPlaceholder(context);
      },
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.diamond_outlined,
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'LSP Silver',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
