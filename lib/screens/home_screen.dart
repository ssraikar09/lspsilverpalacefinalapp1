import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/product.dart';
import '../navigation/app_routes.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  
  @override
  void initState() {
    super.initState();
    if (SampleData.products.isEmpty || SampleData.categoryModels.isEmpty) {
      SampleData.init();
    }
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animController.forward();
    NotificationService.startPolling();
  }

  @override
  void dispose() {
    NotificationService.stopPolling();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFD4AF37);
    const Color lightGrey = Color(0xFFAAAAAA);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -150,
            left: -100,
            right: -100,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    goldColor.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.0),
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: RefreshIndicator(
              color: goldColor,
              backgroundColor: Colors.grey[900],
              onRefresh: () async {
                await SampleData.init();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // 1. App Bar / Header
                    _FadeSlide(
                      animation: _animController,
                      delay: 0.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/lsp_logo.png',
                                  height: 54,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Shri Laxmi Silver Palace',
                                      style: TextStyle(
                                        color: goldColor,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ValueListenableBuilder<bool>(
                            valueListenable: NotificationService.hasNewCatalogUpdates,
                            builder: (context, hasNewCatalog, _) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: NotificationService.hasNewBankDetails,
                                builder: (context, hasNewBank, child) {
                                  final hasNew = hasNewCatalog || hasNewBank;
                                  return Stack(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.notifications_none,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                        onPressed: () {
                                          if (hasNewBank) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: Colors.grey[900],
                                                title: const Text('Bank Details Updated', style: TextStyle(color: Color(0xFFD4AF37))),
                                                content: const Text('The shop owner has updated the bank account details for payments.', style: TextStyle(color: Colors.white)),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      NotificationService.markAsRead();
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37))),
                                                  )
                                                ],
                                              )
                                            );
                                          }
                                          if (hasNewCatalog) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: Colors.grey[900],
                                                title: const Text('Catalog Updated', style: TextStyle(color: Color(0xFFD4AF37))),
                                                content: const Text('New products or categories have been added! Refreshing catalog...', style: TextStyle(color: Colors.white)),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      NotificationService.markCatalogAsRead();
                                                      SampleData.init().then((_) {
                                                        SampleData.globalProductState.value++;
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Refresh', style: TextStyle(color: Color(0xFFD4AF37))),
                                                  )
                                                ],
                                              )
                                            );
                                          }
                                          if (!hasNew) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('No new notifications')),
                                            );
                                          }
                                        },
                                      ),
                                      if (hasNew)
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                    ],
                                  );
                                },
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Search Bar
                    _FadeSlide(
                      animation: _animController,
                      delay: 0.1,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.search);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: goldColor.withValues(alpha: 0.2),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: goldColor.withValues(alpha: 0.05),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, color: lightGrey, size: 22),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Search for silver products...',
                                      style: TextStyle(
                                        color: lightGrey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.mic_none, color: goldColor.withValues(alpha: 0.7), size: 20),
                                  const SizedBox(width: 12),
                                  Icon(Icons.camera_alt_outlined, color: goldColor.withValues(alpha: 0.7), size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 4. Shop by Category (Glass Chips)
                    _FadeSlide(
                      animation: _animController,
                      delay: 0.2,
                      child: _buildSectionHeader(context, 'Shop by Category', goldColor, onSeeAll: () {
                        Navigator.pushNamed(context, AppRoutes.categories);
                      }),
                    ),
                    const SizedBox(height: 16),
                    _FadeSlide(
                      animation: _animController,
                      delay: 0.3,
                      child: SizedBox(
                        height: 50,
                        child: ValueListenableBuilder<int>(
                          valueListenable: SampleData.globalProductState,
                          builder: (context, value, child) {
                            final categories = SampleData.categoryModels;
                            if (categories.isEmpty) {
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.0, color: goldColor),
                                ),
                              );
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                return _buildCategoryChip(context, categories[index].name, goldColor);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 5. Explore Collection (Grid)
                    _FadeSlide(
                      animation: _animController,
                      delay: 0.4,
                      child: _buildSectionHeader(context, 'Explore Collection', goldColor, onSeeAll: () {
                        Navigator.pushNamed(context, AppRoutes.productListing);
                      }),
                    ),
                    const SizedBox(height: 16),
                    _FadeSlide(
                      animation: _animController,
                      delay: 0.5,
                      child: ValueListenableBuilder<int>(
                        valueListenable: SampleData.globalProductState,
                        builder: (context, value, child) {
                          final products = SampleData.products;
                          if (products.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.0, color: goldColor),
                                ),
                              ),
                            );
                          }
                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.65, // Taller cards for jewelry
                            ),
                            itemCount: products.length > 10 ? 10 : products.length,
                            itemBuilder: (context, index) {
                              // Re-using the same aesthetic product card
                              // but without the forced width/margin since GridView handles it.
                              return _buildGridProductCard(context, products[index], goldColor);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color goldColor, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            color: goldColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'View all',
            style: TextStyle(
              color: goldColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, String name, Color goldColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.productListing, arguments: {'category': name});
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: goldColor.withValues(alpha: 0.45),
                  width: 1.2,
                ),
              ),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildGridProductCard(BuildContext context, Product product, Color goldColor) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.productDetails, arguments: product);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: goldColor.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Product Image
              Container(
                color: const Color(0xFF161616),
                child: product.imageUrls.isNotEmpty
                    ? Image.network(
                        product.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.diamond_outlined, color: Colors.white24, size: 40),
                      ),
              ),
              
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.9),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.5],
                  ),
                ),
              ),

              // Product Details
              Positioned(
                bottom: 12,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Heart Icon Glassmorphism
              Positioned(
                top: 8,
                right: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        color: goldColor,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A simple widget to handle staggered fade-and-slide up animations.
class _FadeSlide extends StatelessWidget {
  final AnimationController animation;
  final double delay; // 0.0 to 1.0 representing start time
  final Widget child;

  const _FadeSlide({
    required this.animation,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double end = delay + 0.3 > 1.0 ? 1.0 : delay + 0.3;
    final curve = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) {
        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - curve.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
