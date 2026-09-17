import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/sample_data.dart';
import 'visual_search_engine.dart';

class CatalogueEmbeddingService {
  final VisualSearchEngine _engine;
  
  // Cache of product ID -> embedding
  final Map<String, List<double>> _embeddingCache = {};
  bool _isLoadedFromPrefs = false;

  CatalogueEmbeddingService(this._engine);

  bool get isReady => _embeddingCache.isNotEmpty || SampleData.products.isEmpty;

  Future<void> loadCachedEmbeddings() async {
    if (_isLoadedFromPrefs) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString('catalogue_embeddings_v1');
      if (cacheString != null) {
        final Map<String, dynamic> decoded = jsonDecode(cacheString);
        decoded.forEach((key, value) {
          _embeddingCache[key] = List<double>.from(value);
        });
        debugPrint('VISUAL_AI: LOADED ${_embeddingCache.length} EMBEDDINGS FROM CACHE');
      }
      _isLoadedFromPrefs = true;
    } catch (e) {
      debugPrint('VISUAL_AI: ERROR LOADING CACHE = $e');
    }
  }

  Future<void> _saveCacheToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_embeddingCache);
      await prefs.setString('catalogue_embeddings_v1', encoded);
    } catch (e) {
      debugPrint('VISUAL_AI: ERROR SAVING CACHE = $e');
    }
  }

  Future<void> precalculateEmbeddings() async {
    if (kIsWeb) return; // Not supported on web
    
    await loadCachedEmbeddings();
    
    debugPrint('VISUAL_AI: CATALOGUE COUNT = ${SampleData.products.length}');
    int validCount = _embeddingCache.length;
    int failedCount = 0;
    bool newEmbeddingsAdded = false;
    
    for (var product in SampleData.products) {
      if (product.imageUrls.isNotEmpty) {
        String imageUrl = product.imageUrls.first;
        if (!_embeddingCache.containsKey(product.id)) {
          try {
            debugPrint('VISUAL_AI: CATALOGUE IMAGE URL = $imageUrl');
            Uint8List bytes;
            if (imageUrl.startsWith('http')) {
              // Download image using http package
              final response = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 10));
              if (response.statusCode == 200) {
                bytes = response.bodyBytes;
              } else {
                throw Exception('HTTP Error ${response.statusCode}');
              }
            } else {
              // Read local file
              bytes = await File(imageUrl).readAsBytes();
            }
            
            if (bytes.isEmpty) throw Exception('Empty bytes received from URL');
            
            // Extract embedding (this also does the image decoding)
            final embedding = await _engine.extractFeatureVectorFromBytes(bytes);
            
            _embeddingCache[product.id] = embedding;
            validCount++;
            newEmbeddingsAdded = true;
          } catch (e) {
            failedCount++;
            debugPrint('VISUAL_AI: CATALOGUE ERROR = $e');
          }
        }
      }
    }
    
    if (newEmbeddingsAdded) {
      await _saveCacheToPrefs();
    }
    
    debugPrint('VISUAL_AI: VALID CATALOGUE EMBEDDINGS = $validCount');
    debugPrint('VISUAL_AI: FAILED CATALOGUE IMAGES = $failedCount');
  }

  List<double>? getEmbedding(String productId) {
    return _embeddingCache[productId];
  }

  Future<void> removeCacheForProduct(String productId) async {
    if (_embeddingCache.containsKey(productId)) {
      _embeddingCache.remove(productId);
      await _saveCacheToPrefs();
    }
  }
}
