import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/visual_search_service.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

class VisualSearchScreen extends StatefulWidget {
  final String imagePath;
  const VisualSearchScreen({super.key, required this.imagePath});

  @override
  State<VisualSearchScreen> createState() => _VisualSearchScreenState();
}

class _VisualSearchScreenState extends State<VisualSearchScreen> {
  final VisualSearchService _service = VisualSearchService();
  bool _isAnalyzing = true;
  String? _error;
  VisualAnalysisResult? _result;

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  Future<void> _analyze() async {
    final result = await _service.analyzeImage(widget.imagePath);
    if (!mounted) return;
    
    setState(() {
      _isAnalyzing = false;
      _result = result;
      if (!result.isBackendConfigured) {
        _error = result.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VISUAL SEARCH'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                  ? Image.network(
                      widget.imagePath,
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(widget.imagePath),
                      height: 300,
                      fit: BoxFit.cover,
                    ),
              ),
              if (_isAnalyzing) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 16),
                const Text(
                  'Analyzing image...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ] else if (_error != null) ...[
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.goldAccent.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 1,
                            width: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppTheme.goldAccent.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.filter_vintage,
                            color: AppTheme.goldAccent,
                            size: 36,
                          ),
                          const SizedBox(width: 10),
                          Container(
                            height: 1,
                            width: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.goldAccent.withValues(alpha: 0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.goldAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try capturing another angle or lighting to find matching jewellery.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_result != null && _result!.isBackendConfigured) ...[
                const SizedBox(height: 16),
                if (_result!.closeMatch != null) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'CLOSE MATCH',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ),
                  SizedBox(
                    height: 250,
                    child: ProductCard(product: _result!.closeMatch!),
                  ),
                ],
                if (_result!.similarDesigns.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'SIMILAR DESIGNS',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _result!.similarDesigns.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: SizedBox(
                            width: 160,
                            child: ProductCard(product: _result!.similarDesigns[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (_result!.relatedDesigns.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'RELATED DESIGNS',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _result!.relatedDesigns.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: SizedBox(
                            width: 160,
                            child: ProductCard(product: _result!.relatedDesigns[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
