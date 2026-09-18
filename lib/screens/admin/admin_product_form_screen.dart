import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/sample_data.dart';
import '../../models/product.dart';
import '../../widgets/custom_network_image.dart';

class AdminProductFormScreen extends StatefulWidget {
  const AdminProductFormScreen({super.key});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _id;
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _sizeController;
  late TextEditingController _materialController;
  late TextEditingController _availabilityController;
  late TextEditingController _descController;

  String? _imagePath;
  String _category = SampleData.categories.isNotEmpty ? SampleData.categories.first : '';
  
  String? _existingProductCode;
  String? _existingPurity;
  String? _existingFinish;
  String? _existingStoneDetails;
  String? _subcategory;
  
  bool _isFeatured = false;
  bool _isNewArrival = false;
  
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final product = ModalRoute.of(context)?.settings.arguments as Product?;
      _id = product?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      _nameController = TextEditingController(text: product?.name ?? '');
      _weightController = TextEditingController(text: product?.weight ?? '');
      _sizeController = TextEditingController(text: product?.size ?? '');
      _materialController = TextEditingController(text: product?.material ?? 'Silver');
      _availabilityController = TextEditingController(text: product?.availability ?? 'In Stock');
      _descController = TextEditingController(text: product?.description ?? '');
      _imagePath = product?.imageUrls.isNotEmpty == true ? product!.imageUrls.first : null;
      
      _existingProductCode = product?.productCode;
      _existingPurity = product?.purity;
      _existingFinish = product?.finish;
      _existingStoneDetails = product?.stoneDetails;
      _subcategory = product?.subcategory;
      _isFeatured = product?.featured ?? false;
      _isNewArrival = product?.newArrival ?? false;
      
      if (product != null) {
        if (SampleData.categories.contains(product.category)) {
          _category = product.category;
          
          if (_subcategory != null && !(SampleData.subcategories[_category]?.contains(_subcategory) ?? false)) {
            _subcategory = null;
          }
        }
      }
      
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _sizeController.dispose();
    _materialController.dispose();
    _availabilityController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75, // Balanced for fast upload but crisp details
      maxWidth: 1024,
    );
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  bool _isSaving = false;

  void _saveForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saving and uploading to cloud...')));

      final String finalCode = _existingProductCode ?? 'PRD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final String finalPurity = _existingPurity ?? '';
      
      final newProduct = Product(
        id: _id,
        name: _nameController.text,
        productCode: finalCode,
        category: _category,
        subcategory: _subcategory,
        weight: _weightController.text.isNotEmpty ? _weightController.text : null,
        size: _sizeController.text.isNotEmpty ? _sizeController.text : null,
        purity: finalPurity,
        finish: _existingFinish,
        material: _materialController.text.isNotEmpty ? _materialController.text : null,
        availability: _availabilityController.text.isNotEmpty ? _availabilityController.text : null,
        stoneDetails: _existingStoneDetails,
        description: _descController.text,
        imageUrls: _imagePath != null ? [_imagePath!] : [],
        featured: _isFeatured,
        newArrival: _isNewArrival,
      );
      
      try {
        if (SampleData.products.any((p) => p.id == _id)) {
          await SampleData.updateProduct(newProduct);
        } else {
          await SampleData.addProduct(newProduct);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          _isSaving 
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                )
              )
            : IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveForm,
              ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              if (SampleData.categories.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: SampleData.categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _category = value;
                        _subcategory = null; // Reset subcategory when category changes
                      });
                    }
                  },
                ),
              if (_category.isNotEmpty && SampleData.subcategories.containsKey(_category) && SampleData.subcategories[_category]!.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: _subcategory,
                  decoration: const InputDecoration(labelText: 'Subcategory'),
                  items: SampleData.subcategories[_category]!.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _subcategory = value;
                      });
                    }
                  },
                ),
              TextFormField(
                controller: _materialController,
                decoration: const InputDecoration(labelText: 'Material'),
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight'),
              ),
              Builder(
                builder: (context) {
                  List<String> options = ['92.5%', '99.9%', 'Other'];
                  if (_existingPurity != null && _existingPurity!.isNotEmpty && !options.contains(_existingPurity)) {
                    options.add(_existingPurity!);
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _existingPurity?.isNotEmpty == true ? _existingPurity : null,
                    decoration: const InputDecoration(labelText: 'Purity'),
                    items: options.map((p) {
                      return DropdownMenuItem(value: p, child: Text(p));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _existingPurity = val;
                      });
                    },
                  );
                },
              ),
              TextFormField(
                initialValue: _existingFinish,
                decoration: const InputDecoration(labelText: 'Finish'),
                onChanged: (val) {
                  _existingFinish = val;
                },
              ),
              TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(labelText: 'Size'),
              ),
              TextFormField(
                controller: _availabilityController,
                decoration: const InputDecoration(labelText: 'Availability'),
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _imagePath == null || _imagePath!.isEmpty
                        ? const Center(child: Text('No Image'))
                        : CustomNetworkImage(imageUrl: _imagePath!, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pick Image'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('SAVE PRODUCT'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
