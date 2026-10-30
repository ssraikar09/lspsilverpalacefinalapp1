import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../state/wishlist_state.dart';
import '../state/recently_viewed_state.dart';
import '../widgets/custom_network_image.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;

  String _buildShareText(Product product) {
    return '''Shri Laxmi Silver Palace

I am interested in this silver jewellery design.

Product:
${product.name}

Weight:
${product.weight ?? 'N/A'}

Purity:
${product.purity}

Please provide more details.''';
  }

  Future<void> _shareProduct(Product product) async {
    final text = _buildShareText(product);
    
    if (product.imageUrls.isEmpty) {
      await SharePlus.instance.share(ShareParams(text: text));
      return;
    }

    try {
      final imageUrl = product.imageUrls.first;
      String? localPath;
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/shared_image_${product.id}.jpg');
      
      if (imageUrl.startsWith('http')) {
        // Download network image
        final response = await http.get(Uri.parse(imageUrl));
        await tempFile.writeAsBytes(response.bodyBytes);
        localPath = tempFile.path;
      } else if (imageUrl.startsWith('assets/')) {
        // Load asset image
        if (!mounted) return;
        final byteData = await DefaultAssetBundle.of(context).load(imageUrl);
        await tempFile.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
        localPath = tempFile.path;
      } else {
        // Assume it's an absolute file path (e.g. from image picker)
        localPath = imageUrl;
      }
      
      await SharePlus.instance.share(ShareParams(files: [XFile(localPath)], text: text));
    } catch (e) {
      // Fallback to text only if image load fails
      await SharePlus.instance.share(ShareParams(text: text));
    }
  }

  Future<void> _enquireOnWhatsApp(Product product) async {
    String number = '919886855425'; // Fallback
    try {
      final response = await Supabase.instance.client.from('business_details').select('shop_whatsapp').limit(1).maybeSingle();
      if (response != null && response['shop_whatsapp'] != null && response['shop_whatsapp'].toString().isNotEmpty) {
        number = response['shop_whatsapp'].toString();
      }
    } catch (e) {
      // Ignore and use fallback
    }

    final message = _buildShareText(product);
    
    final text = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$number?text=$text');
    
    final success = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp. Please make sure it is installed.')),
      );
    }
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade300,
                        fontSize: 13,
                      ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: Colors.white.withValues(alpha: 0.05),
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)?.settings.arguments as Product?;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Product details not found.')),
      );
    }

    // Add to recently viewed once built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        recentlyViewedState.addProduct(product);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        title: Text(
          product.name.toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFD4AF37),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22),
            onPressed: () => _shareProduct(product),
          ),
          ListenableBuilder(
            listenable: globalWishlistState,
            builder: (context, _) {
              final isWished = globalWishlistState.isInWishlist(product.id);
              return IconButton(
                icon: Icon(
                  isWished ? Icons.favorite : Icons.favorite_border,
                  color: isWished ? const Color(0xFFD4AF37) : Colors.white70,
                  size: 22,
                ),
                onPressed: () => globalWishlistState.toggleWishlist(product.id),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Gallery
              Builder(
                builder: (context) {
                  final images = product.imageUrls.isNotEmpty ? product.imageUrls : [''];
                  return Container(
                    height: 380,
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: PageView.builder(
                            itemCount: images.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return CustomNetworkImage(imageUrl: images[index]);
                            },
                          ),
                        ),
                        if (images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                images.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? Theme.of(context).colorScheme.secondary
                                        : Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Product Specifications Box
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Specifications',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7), size: 16),
                              ],
                            ),
                          ),
                          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                          _buildDetailRow(context, 'Material', product.material ?? '925 Sterling Silver'),
                          _buildDetailRow(context, 'Weight', product.weight ?? '4.25 gm'),
                          _buildDetailRow(context, 'Size', product.size ?? 'Adjustable'),
                          _buildDetailRow(context, 'Category', product.category, showDivider: false),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Description Box
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600, size: 14),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                            child: Text(
                              product.description,
                              style: TextStyle(
                                height: 1.5,
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Tags
                    if (product.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Text(
                            tag,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 32),
                    ],

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () async {
                      String phone = '+919886855425'; // Fallback
                      try {
                        final response = await Supabase.instance.client.from('business_details').select('shop_phone').limit(1).maybeSingle();
                        if (response != null && response['shop_phone'] != null && response['shop_phone'].toString().isNotEmpty) {
                          phone = response['shop_phone'].toString();
                        }
                      } catch (e) {
                        // Ignore and use fallback
                      }
                      
                      final url = Uri.parse('tel:$phone');
                      final success = await launchUrl(url);
                      if (!success) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not launch Phone Dialer.')),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'CONTACT SHOP',
                        maxLines: 1,
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _enquireOnWhatsApp(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shadowColor: const Color(0xFF25D366).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'WHATSAPP',
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
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
