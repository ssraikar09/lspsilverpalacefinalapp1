import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/sample_data.dart';
import '../../models/category_model.dart';
import '../../widgets/custom_network_image.dart';

class AdminCategoryFormScreen extends StatefulWidget {
  const AdminCategoryFormScreen({super.key});

  @override
  State<AdminCategoryFormScreen> createState() => _AdminCategoryFormScreenState();
}

class _AdminCategoryFormScreenState extends State<AdminCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _id;
  late TextEditingController _nameController;
  late TextEditingController _descController;

  String? _imagePath;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final category = ModalRoute.of(context)?.settings.arguments as CategoryModel?;
      _id = category?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      _nameController = TextEditingController(text: category?.name ?? '');
      _descController = TextEditingController(text: category?.description ?? '');
      _imagePath = category?.imagePath.isNotEmpty == true ? category!.imagePath : null;
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75, // Balanced for crisp details
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

      final newCategory = CategoryModel(
        id: _id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        imagePath: _imagePath ?? '',
      );
      
      try {
        final existingIndex = SampleData.categoryModels.indexWhere((c) => c.id == _id);
        if (existingIndex >= 0) {
          await SampleData.updateCategory(newCategory);
        } else {
          await SampleData.addCategory(newCategory);
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
        title: const Text('Category Details'),
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
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 3,
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
                child: const Text('SAVE CATEGORY'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
