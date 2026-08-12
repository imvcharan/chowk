import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api_service.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  int? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];

  String? _filePath;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _contentCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ApiService.getCategories();
      setState(() {
        _categories = cats.map<Map<String, dynamic>>((e) => {
              'id': e['id'],
              'name': e['name'],
            }).toList();
        if (_categories.isNotEmpty) _selectedCategoryId = _categories.first['id'] as int;
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4', 'mov', 'jpeg', 'webm'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _filePath = result.files.first.path);
    }
  }

  Widget _buildFilePreview() {
    if (_filePath == null) return const SizedBox.shrink();
    final lc = _filePath!.toLowerCase();
    if (lc.endsWith('.mp4') || lc.endsWith('.mov') || lc.endsWith('.webm')) {
      return Container(
        height: 160,
        color: AppTheme.mediumGray,
        child: const Center(child: Icon(Icons.play_circle, size: 48)),
      );
    }

    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.mediumGray,
        image: DecorationImage(
          image: FileImage(File(_filePath!)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  Future<void> _uploadAndCreate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUploading = true);

    try {
      String? imageUrl;
      if (_filePath != null) {
        final uploadResp = await ApiService.uploadMedia(filePath: _filePath!);
        imageUrl = uploadResp['url'];
      }

      final categoryId = _selectedCategoryId ?? 1;

      final createResp = await ApiService.createNews(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        categoryId: categoryId,
        imageUrl: imageUrl,
      );

      if (createResp['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('News created successfully')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception(createResp['message'] ?? 'Create failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Upload'),
        backgroundColor: AppTheme.primaryRed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Short Description'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Description required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentCtrl,
                decoration: const InputDecoration(labelText: 'Content'),
                minLines: 4,
                maxLines: 8,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Content required' : null,
              ),
              const SizedBox(height: 12),
              if (_categories.isEmpty)
                const SizedBox.shrink()
              else
                DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  items: _categories
                      .map((c) => DropdownMenuItem<int>(
                            value: c['id'] as int,
                            child: Text(c['name'] ?? 'Category'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_filePath == null ? 'Pick Image/Video' : 'Change File'),
              ),
              if (_filePath != null) ...[
                const SizedBox(height: 8),
                _buildFilePreview(),
              ],
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                            onPressed: _isUploading ? null : _uploadAndCreate,
                            child: _isUploading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Uploading...'),
                                    ],
                                  )
                                : const Text('Upload & Create News'),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
