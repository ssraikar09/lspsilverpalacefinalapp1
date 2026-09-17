import 'dart:math';
import '../models/product.dart';
import '../data/sample_data.dart';

class SearchResult {
  final List<Product> products;
  final String correctedQuery;
  
  SearchResult(this.products, this.correctedQuery);
}

class SearchService {
  final Set<String> _catalogVocabulary = {};

  SearchService() {
    _buildVocabulary();
    SampleData.globalProductState.addListener(_onProductStateChanged);
  }

  void _onProductStateChanged() {
    _catalogVocabulary.clear();
    _buildVocabulary();
  }

  void _buildVocabulary() {
    final RegExp wordRegex = RegExp(r'[a-zA-Z]+');
    for (final p in SampleData.products) {
      final fields = [p.name, p.category, p.subcategory ?? '', p.material ?? '', ...p.tags];
      for (final field in fields) {
        final matches = wordRegex.allMatches(field.toLowerCase());
        for (final m in matches) {
          if (m.group(0) != null && m.group(0)!.length > 2) {
            _catalogVocabulary.add(m.group(0)!);
          }
        }
      }
    }
  }

  int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var v0 = List<int>.generate(b.length + 1, (i) => i);
    var v1 = List<int>.filled(b.length + 1, 0);
    for (var i = 0; i < a.length; i++) {
      v1[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        var cost = (a[i] == b[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (var j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[b.length];
  }

  String _correctWord(String word) {
    if (_catalogVocabulary.contains(word)) return word;
    if (word.length <= 3) return word;

    String bestMatch = word;
    int bestDist = 999;

    for (final v in _catalogVocabulary) {
      final dist = _levenshtein(word, v);
      if (dist <= 1 && v.length <= 5 && dist < bestDist) {
        bestDist = dist;
        bestMatch = v;
      } else if (dist <= 2 && v.length > 5 && dist < bestDist) {
        bestDist = dist;
        bestMatch = v;
      }
    }
    return bestMatch;
  }

  SearchResult search(String query) {
    if (query.trim().isEmpty) return SearchResult([], '');

    final lowerQuery = query.toLowerCase();
    final RegExp wordRegex = RegExp(r'[a-z]+');
    final tokens = wordRegex.allMatches(lowerQuery).map((m) => m.group(0)!).toList();
    
    final correctedTokens = tokens.map((t) => _correctWord(t)).toList();
    final correctedQueryString = correctedTokens.join(' ');

    final scoredProducts = <Product, int>{};

    for (final p in SampleData.products) {
      int score = 0;
      final pName = p.name.toLowerCase();
      final pCat = p.category.toLowerCase();
      final pSub = p.subcategory?.toLowerCase() ?? '';
      final pMat = p.material?.toLowerCase() ?? '';
      final pDesc = p.description.toLowerCase();

      for (final t in correctedTokens) {
        if (pName.contains(t)) score += 100;
        if (pCat.contains(t)) score += 75;
        if (pSub.contains(t)) score += 75;
        if (p.tags.any((tag) => tag.toLowerCase().contains(t))) score += 50;
        if (pMat.contains(t)) score += 50;
        if (pDesc.contains(t)) score += 10;
      }

      if (correctedTokens.length > 1 && pName.contains(correctedQueryString)) {
        score += 200;
      }

      if (score > 0) {
        scoredProducts[p] = score;
      }
    }

    final sortedEntries = scoredProducts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return SearchResult(sortedEntries.map((e) => e.key).toList(), correctedQueryString);
  }

  void dispose() {
    SampleData.globalProductState.removeListener(_onProductStateChanged);
  }
}
