import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../navigation/app_routes.dart';

class SubcategoriesScreen extends StatelessWidget {
  const SubcategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryName = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    
    final activeSubcategories = SampleData.products
        .where((p) => p.category == categoryName && p.subcategory != null && p.subcategory!.isNotEmpty)
        .map((p) => p.subcategory!)
        .toSet()
        .toList();
    activeSubcategories.sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName.toUpperCase()),
      ),
      body: SafeArea(
        child: activeSubcategories.isEmpty
            ? const Center(child: Text('No subcategories found.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: activeSubcategories.length,
                itemBuilder: (context, index) {
                  final subcategory = activeSubcategories[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.productListing,
                          arguments: {
                            'category': categoryName,
                            'subcategory': subcategory,
                          },
                        );
                      },
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161616),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          subcategory.toUpperCase(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
