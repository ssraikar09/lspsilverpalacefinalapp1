import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import '../../widgets/custom_network_image.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredCategories = SampleData.categoryModels.where((c) {
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Category',
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
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final cat = filteredCategories[index];
                return ListTile(
                  leading: cat.imagePath.isNotEmpty
                      ? SizedBox(
                          width: 50,
                          height: 50,
                          child: CustomNetworkImage(imageUrl: cat.imagePath, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.image, size: 50),
                  title: Text(cat.name),
                  subtitle: Text(cat.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/admin/category_form',
                            arguments: cat,
                          ).then((_) => setState(() {}));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Category'),
                              content: const Text('Are you sure you want to delete this category?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await SampleData.deleteCategory(cat.id);
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
          Navigator.pushNamed(context, '/admin/category_form').then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
