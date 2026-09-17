import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/sample_data.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../services/voice_search_service.dart';
import '../navigation/app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final VoiceSearchService _voiceService = VoiceSearchService();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<Product> _results = [];
  bool _hasSearched = false;
  bool _isListening = false;
  String _listeningText = 'Listening...';
  
  Timer? _debounce;
  final Set<String> _catalogVocabulary = {};
  String _correctedQueryDisplay = '';

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
    _buildVocabulary();
    SampleData.globalProductState.addListener(_onProductStateChanged);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }
  
  void _onProductStateChanged() {
    _catalogVocabulary.clear();
    _buildVocabulary();
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    } else {
      setState(() {});
    }
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
      // Typo tolerance rules
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

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _correctedQueryDisplay = '';
      });
      return;
    }

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
      
      // Bonus if exact multi-word match is present
      if (correctedTokens.length > 1 && pName.contains(correctedQueryString)) {
        score += 200;
      }
      
      if (score > 0) {
        scoredProducts[p] = score;
      }
    }

    final sortedEntries = scoredProducts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    setState(() {
      _hasSearched = true;
      _results = sortedEntries.map((e) => e.key).toList();
      _correctedQueryDisplay = (correctedQueryString != lowerQuery && correctedTokens.isNotEmpty) 
          ? correctedQueryString 
          : '';
    });
  }

  Future<void> _startVoiceSearch() async {
    setState(() {
      _isListening = true;
      _listeningText = 'Listening...';
    });
    
    await _voiceService.startListening((text, isFinal) {
      if (!mounted) return;
      setState(() {
        _listeningText = text;
        _searchController.text = text;
      });
      
      _debounce?.cancel();

      if (isFinal) {
        if (text.isNotEmpty) _performSearch(text);
        setState(() => _isListening = false);
      } else {
        // Trigger a background search if they pause for 1 second, but keep listening!
        _debounce = Timer(const Duration(milliseconds: 1000), () {
          if (text.isNotEmpty && mounted) {
            _performSearch(text);
          }
        });
      }
    });
  }

  void _stopVoiceSearch() async {
    await _voiceService.stopListening();
    setState(() {
      _isListening = false;
    });
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 1024,
      );
      if (image != null) {
        if (!mounted) return;
        Navigator.pushNamed(
          context, 
          AppRoutes.visualSearch,
          arguments: image.path,
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    SampleData.globalProductState.removeListener(_onProductStateChanged);
    _debounce?.cancel();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search silver jewellery...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.mic, color: _isListening ? const Color(0xFFD4AF37) : Colors.white70),
                  onPressed: _isListening ? _stopVoiceSearch : _startVoiceSearch,
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white70),
                  onPressed: _showImageSourceDialog,
                ),
              ],
            ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
          onChanged: (val) {
            setState(() {}); // update suffix icons visibility
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 300), () {
              _performSearch(val);
            });
          },
        ),
      ),
      body: Column(
        children: [
          if (_isListening)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2 + 0.3 * _pulseController.value),
                      width: 1 + 2 * _pulseController.value,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.1 * _pulseController.value),
                        blurRadius: 10 * _pulseController.value,
                        spreadRadius: 2 * _pulseController.value,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mic, color: const Color(0xFFD4AF37), size: 28 + (4 * _pulseController.value)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _listeningText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          Expanded(
            child: !_hasSearched && _searchController.text.isEmpty
                ? const Center(
                    child: Text(
                      'Type, speak, or upload an image to search.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : _results.isEmpty
                    ? const Center(
                        child: Text(
                          'No products found matching your search.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: Column(
                                children: _results.map((p) => p.name).toSet().take(4).map((suggestion) {
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.search, size: 20, color: Colors.grey),
                                    title: Text(suggestion, style: const TextStyle(fontSize: 14)),
                                    onTap: () {
                                      _searchController.text = suggestion;
                                      _performSearch(suggestion);
                                      FocusScope.of(context).unfocus();
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_results.length} Results',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                if (_correctedQueryDisplay.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'Showing results for "$_correctedQueryDisplay"',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.65,
                              ),
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                return ProductCard(product: _results[index]);
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
