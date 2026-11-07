import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/category_model.dart';
import '../services/visual_search_service.dart';

class SampleData {
  static final ValueNotifier<int> globalProductState = ValueNotifier(0);

  static List<CategoryModel> categoryModels = [];
  static List<String> get categories => categoryModels.map((c) => c.name).toList();

  static Map<String, List<String>> subcategories = {
    'Anklets & Payal': ['Payal / Anklets', 'Other'],
    'Bangles & Kadas': ['Bangles', 'Kadas'],
    'Bracelets': ['Bracelets'],
    'Chains & Necklaces': ['Chains', 'Necklaces / Haar / Mala'],
    'Earrings & Challa': ['Challa'],
    'Headwear & Crowns': ['Kirit / Mukut'],
    'Idols & Religious Statues': ['Animal Idol', 'Deity / Religious Idol'],
    'Other Silver Jewellery': ['Other', 'Traditional Body Jewellery'],
    'Pendants & Amulets': ['Decorative Pendant', 'Eye / Protective Ornament', 'Pendants'],
    'Pooja & Ritual Items': ['Pooja / Ritual Item'],
    'Rakhi & Seasonal': ['Silver Rakhi'],
    'Rings & Toe Rings': ['Toe Rings'],
    'Silver Articles & Gifts': ['Attardani'],
    'Watches': ['Men\'s / Ladies\' Watch'],
  };

  static List<Product> products = [];

  static Future<void>? _loadingFuture;

  static Future<void> init() {
    if (_loadingFuture != null && products.isNotEmpty) {
      return _loadingFuture!;
    }
    _loadingFuture = _fetchCatalog();
    return _loadingFuture!;
  }

  static Future<void> _fetchCatalog() async {
    final client = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();

    // Instant local cache restoration
    if (products.isEmpty) {
      final cachedCats = prefs.getString('cached_categories');
      if (cachedCats != null) {
        try {
          final List decoded = jsonDecode(cachedCats);
          categoryModels = decoded.map((e) => CategoryModel.fromJson(e)).toList();
        } catch (_) {}
      }
      final cachedProds = prefs.getString('cached_products');
      if (cachedProds != null) {
        try {
          final List decoded = jsonDecode(cachedProds);
          products = decoded.map((e) => Product.fromJson(e)).toList();
        } catch (_) {}
      }
      if (products.isNotEmpty) {
        globalProductState.value++;
      }
    }

    // High-speed parallel network fetch (< 1s)
    try {
      final results = await Future.wait([
        client.from('categories').select(),
        client.from('products').select(),
      ]);
      final catResponse = results[0] as List<dynamic>;
      final prodResponse = results[1] as List<dynamic>;
      categoryModels = catResponse.map((e) => CategoryModel.fromJson(e)).toList();
      products = prodResponse.map((e) => Product.fromJson(e)).toList();

      prefs.setString('cached_categories', jsonEncode(catResponse));
      prefs.setString('cached_products', jsonEncode(prodResponse));
    } catch (e) {
      debugPrint("Error fetching catalog: $e");
    }
    globalProductState.value++;
  }

  // Helper to upload image to Supabase Storage
  static Future<String> _uploadImage(String localPath) async {
    final file = File(localPath);
    if (!file.existsSync()) return localPath; // Already a URL or missing

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final client = Supabase.instance.client;
    
    await client.storage.from('product_images').upload(
      fileName, 
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
    
    return client.storage.from('product_images').getPublicUrl(fileName);
  }

  static Future<void> addProduct(Product p) async {
    final client = Supabase.instance.client;
    
    // Upload any local images
    List<String> uploadedUrls = [];
    for (String url in p.imageUrls) {
      if (!url.startsWith('http')) {
        String newUrl = await _uploadImage(url);
        uploadedUrls.add(newUrl);
      } else {
        uploadedUrls.add(url);
      }
    }
    
    final newProduct = Product(
      id: p.id,
      name: p.name,
      productCode: p.productCode,
      category: p.category,
      subcategory: p.subcategory,
      weight: p.weight,
      size: p.size,
      purity: p.purity,
      finish: p.finish,
      material: p.material,
      stoneDetails: p.stoneDetails,
      description: p.description,
      imageUrls: uploadedUrls,
      tags: p.tags,
      availability: p.availability,
      featured: p.featured,
      newArrival: p.newArrival,
    );

    // Insert into Supabase (remove id so it auto-generates if it's not a UUID)
    var json = newProduct.toJson();
    if (!json['id'].contains('-')) {
      json.remove('id');
    }
    
    final response = await client.from('products').insert(json).select().single();
    
    final finalProduct = Product.fromJson(response);
    
    final index = products.indexWhere((element) => element.id == finalProduct.id);
    if (index >= 0) {
      products[index] = finalProduct;
    } else {
      products.add(finalProduct);
    }
    
    globalProductState.value++;
    await VisualSearchService().invalidateCacheForProduct(finalProduct.id);
  }

  static Future<void> updateProduct(Product p) async {
    final client = Supabase.instance.client;
    
    List<String> uploadedUrls = [];
    for (String url in p.imageUrls) {
      if (!url.startsWith('http')) {
        String newUrl = await _uploadImage(url);
        uploadedUrls.add(newUrl);
      } else {
        uploadedUrls.add(url);
      }
    }
    
    var json = p.toJson();
    json['image_urls'] = uploadedUrls;
    json.remove('id');
    
    await client.from('products').update(json).eq('id', p.id);
    
    final index = products.indexWhere((element) => element.id == p.id);
    if (index >= 0) {
      // Re-fetch or manually update
      final updatedResponse = await client.from('products').select().eq('id', p.id).single();
      products[index] = Product.fromJson(updatedResponse);
    }
    globalProductState.value++;
    await VisualSearchService().invalidateCacheForProduct(p.id);
  }

  static Future<void> deleteProduct(String id) async {
    final client = Supabase.instance.client;
    await client.from('products').delete().eq('id', id);
    products.removeWhere((element) => element.id == id);
    globalProductState.value++;
  }

  static Future<void> addCategory(CategoryModel c) async {
    final client = Supabase.instance.client;
    
    String finalImageUrl = c.imagePath;
    if (finalImageUrl.isNotEmpty && !finalImageUrl.startsWith('http')) {
      finalImageUrl = await _uploadImage(finalImageUrl);
    }
    
    var json = c.toJson();
    json['image_url'] = finalImageUrl.isNotEmpty ? finalImageUrl : null;
    if (!json['id'].contains('-')) {
      json.remove('id'); // let Supabase generate UUID
    }
    
    final response = await client.from('categories').insert(json).select().single();
    categoryModels.add(CategoryModel.fromJson(response));
    globalProductState.value++;
  }

  static Future<void> updateCategory(CategoryModel c) async {
    final client = Supabase.instance.client;
    
    String finalImageUrl = c.imagePath;
    if (finalImageUrl.isNotEmpty && !finalImageUrl.startsWith('http')) {
      finalImageUrl = await _uploadImage(finalImageUrl);
    }
    
    var json = c.toJson();
    json['image_url'] = finalImageUrl.isNotEmpty ? finalImageUrl : null;
    json.remove('id');
    
    await client.from('categories').update(json).eq('id', c.id);
    
    final index = categoryModels.indexWhere((element) => element.id == c.id);
    if (index >= 0) {
      final updatedResponse = await client.from('categories').select().eq('id', c.id).single();
      categoryModels[index] = CategoryModel.fromJson(updatedResponse);
      globalProductState.value++;
    }
  }

  static Future<void> deleteCategory(String id) async {
    final client = Supabase.instance.client;
    await client.from('categories').delete().eq('id', id);
    categoryModels.removeWhere((element) => element.id == id);
    globalProductState.value++;
  }
}
