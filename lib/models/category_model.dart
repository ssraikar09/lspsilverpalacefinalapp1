class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String imagePath;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      imagePath: json['image_url'] ?? json['imagePath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imagePath,
    };
  }
}
