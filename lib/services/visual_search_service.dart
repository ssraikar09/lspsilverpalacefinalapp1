import 'visual_search_engine.dart';
import 'catalogue_embedding_service.dart';
import '../data/sample_data.dart';
import '../models/product.dart';

class VisualAnalysisResult {
  final bool isBackendConfigured;
  final String? error;
  final String? detectionType;
  final String? category;
  final Product? closeMatch;
  final List<Product> similarDesigns;
  final List<Product> relatedDesigns;

  VisualAnalysisResult({
    required this.isBackendConfigured,
    this.error,
    this.detectionType,
    this.category,
    this.closeMatch,
    this.similarDesigns = const [],
    this.relatedDesigns = const [],
  });
}

class VisualSearchService {
  static final VisualSearchService _instance = VisualSearchService._internal();

  factory VisualSearchService() {
    return _instance;
  }

  final VisualSearchEngine _engine = VisualSearchEngine();
  late CatalogueEmbeddingService _catalogueService;

  VisualSearchService._internal() {
    _catalogueService = CatalogueEmbeddingService(_engine);
  }

  String? _initError;

  /// Initializes the service without precalculating catalogue yet.
  Future<bool> initialize() async {
    try {
      await _engine.initialize();
      _initError = null;
      return true;
    } catch (e) {
      _initError = e.toString();
      return false;
    }
  }

  /// Fire-and-forget method to pre-load TFLite and cache catalogue embeddings in the background
  Future<void> preheat() async {
    try {
      if (!_engine.isInitialized) {
        await initialize();
      }
      if (!_catalogueService.isReady) {
        // Do not await, let it run in the background
        _catalogueService.precalculateEmbeddings();
      }
    } catch (_) {
      // Ignore background preheating errors
    }
  }

  Future<void> invalidateCacheForProduct(String productId) async {
    await _catalogueService.removeCacheForProduct(productId);
    preheat();
  }

  /// Analyzes an image for jewellery characteristics using local TFLite model.
  Future<VisualAnalysisResult> analyzeImage(String imagePath) async {
    try {
      return await _analyzeImageInternal(imagePath).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Timeout or any other exception caught here
      return VisualAnalysisResult(
        isBackendConfigured: false,
        error: e.toString().contains('Timeout') 
            ? 'No similar product found in catalogue.' 
            : 'Visual search failed to process the image: $e',
      );
    }
  }

  Future<VisualAnalysisResult> _analyzeImageInternal(String imagePath) async {
    if (!_engine.isInitialized) {
      bool success = await initialize();
      if (!success && !_engine.isInitialized) {
        return VisualAnalysisResult(
          isBackendConfigured: false,
          error: _initError ?? 'Visual search engine is not initialized.',
        );
      }
    }

    // 1. Extract embedding for uploaded user image
    final userEmbedding = await _engine.extractFeatureVectorFromFile(imagePath);
    
    // 2. ONLY load cached embeddings. Do NOT await the full download/generation process
    await _catalogueService.loadCachedEmbeddings();

    // 3. Compute cosine similarity for all AVAILABLE catalogue products
    List<Map<String, dynamic>> productScores = [];
    for (var product in SampleData.products) {
      final catEmbedding = _catalogueService.getEmbedding(product.id);
      if (catEmbedding != null) {
        double score = _engine.cosineSimilarity(userEmbedding, catEmbedding);
        if (score >= 0.5) { // Similarity threshold
          productScores.add({
            'product': product,
            'score': score,
          });
        }
      }
    }

    if (productScores.isEmpty) {
      return VisualAnalysisResult(
        isBackendConfigured: false,
        error: 'No similar product found in catalogue.',
      );
    }

    // 4. Sort by score descending
    productScores.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    Product? closeMatch;
    List<Product> similarDesigns = [];
    List<Product> relatedDesigns = [];

    if (productScores.isNotEmpty) {
      closeMatch = productScores[0]['product'] as Product;
    }
    
    if (productScores.length > 1) {
      int similarCount = productScores.length > 4 ? 3 : productScores.length - 1;
      similarDesigns = productScores.sublist(1, 1 + similarCount).map((e) => e['product'] as Product).toList();
    }

    if (productScores.length > 4) {
      relatedDesigns = productScores.sublist(4, productScores.length > 10 ? 10 : productScores.length).map((e) => e['product'] as Product).toList();
    }

    return VisualAnalysisResult(
      isBackendConfigured: true,
      detectionType: 'Jewellery',
      category: 'Detected',
      closeMatch: closeMatch,
      similarDesigns: similarDesigns,
      relatedDesigns: relatedDesigns,
    );
  }
}
