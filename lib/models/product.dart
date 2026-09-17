class Product {
  final String id;
  final String name;
  final String productCode;
  final String category;
  final String? subcategory;
  final String? weight;
  final String? size;
  final String purity;
  final String? finish;
  final String? stoneDetails;
  final String description;
  final List<String> imageUrls;
  final List<String> tags;
  final String? availability;
  final String? material;
  final bool featured;
  final bool newArrival;

  const Product({
    required this.id,
    required this.name,
    required this.productCode,
    required this.category,
    this.subcategory,
    this.weight,
    this.size,
    required this.purity,
    this.finish,
    this.material,
    this.stoneDetails,
    required this.description,
    required this.imageUrls,
    this.tags = const [],
    this.availability = 'In Stock',
    this.featured = false,
    this.newArrival = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      productCode: (json['product_code'] ?? json['productCode']) as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      weight: json['weight'] as String?,
      size: json['size'] as String?,
      purity: json['purity'] as String,
      finish: json['finish'] as String?,
      material: json['material'] as String? ?? 'Silver',
      stoneDetails: (json['stone_details'] ?? json['stoneDetails']) as String?,
      description: json['description'] as String,
      imageUrls: ((json['image_urls'] ?? json['imageUrls'] ?? []) as List<dynamic>).map((e) => e as String).toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      availability: json['availability'] as String? ?? 'In Stock',
      featured: (json['is_featured'] ?? json['featured']) as bool? ?? false,
      newArrival: (json['is_new_arrival'] ?? json['newArrival']) as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'product_code': productCode,
      'category': category,
      'subcategory': subcategory,
      'weight': weight,
      'size': size,
      'purity': purity,
      'finish': finish,
      'material': material,
      'stone_details': stoneDetails,
      'description': description,
      'image_urls': imageUrls,
      'availability': availability,
      'is_featured': featured,
      'is_new_arrival': newArrival,
    };
  }
}
