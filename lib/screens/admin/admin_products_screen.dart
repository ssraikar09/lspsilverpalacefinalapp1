import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../widgets/custom_network_image.dart';
import '../../services/search_service.dart';
import '../../models/product.dart';
import '../../services/visual_search_service.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String _searchQuery = '';
  late final SearchService _searchService;

  @override
  void initState() {
    super.initState();
    _searchService = SearchService();
  }

  @override
  void dispose() {
    _searchService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts;
    if (_searchQuery.trim().isEmpty) {
      filteredProducts = SampleData.products;
    } else {
      filteredProducts = _searchService.search(_searchQuery).products;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Name, Code, or Category',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ListTile(
                  leading: product.imageUrls.isNotEmpty
                      ? SizedBox(
                          width: 50,
                          height: 50,
                          child: CustomNetworkImage(imageUrl: product.imageUrls.first, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.image, size: 50),
                  title: Text(product.name),
                  subtitle: Text(product.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/admin/product_form',
                            arguments: product,
                          ).then((_) => setState(() {}));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: const Text('Are you sure you want to delete this product?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await SampleData.deleteProduct(product.id);
                                    await VisualSearchService().invalidateCacheForProduct(product.id);
                                    setState(() {});
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin/product_form').then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
