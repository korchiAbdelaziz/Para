import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _skuController;
  late List<TextEditingController> _imageControllers;
  late TextEditingController _categoryController;
  bool _isCheckingUrl = false;
  bool _isUrlValid = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchCategories();
    });
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _discountPriceController = TextEditingController(text: widget.product?.discountPrice?.toString() ?? '');
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
    _categoryController = TextEditingController(text: widget.product?.category ?? '');
    
    // Initialize image controllers
    if (widget.product != null && widget.product!.imageUrls.isNotEmpty) {
      _imageControllers = widget.product!.imageUrls.map((url) => TextEditingController(text: url)).toList();
    } else {
      _imageControllers = [TextEditingController(text: widget.product?.imageUrl ?? '')];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _skuController.dispose();
    for (var c in _imageControllers) {
      c.dispose();
    }
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final imageUrls = _imageControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList();

    final productData = {
      'name': _nameController.text,
      'description': _descController.text,
      'price': double.parse(_priceController.text),
      'discountPrice': _discountPriceController.text.isNotEmpty ? double.parse(_discountPriceController.text) : null,
      'productCode': _skuController.text,
      'imageUrls': imageUrls,
      'category': _categoryController.text,
    };

    bool success;
    if (widget.product == null) {
      success = await productProvider.addProduct(productData, authProvider.user?.token);
    } else {
      success = await productProvider.updateProduct(widget.product!.id, productData, authProvider.user?.token);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null ? 'Product added successfully' : 'Product updated'),
            backgroundColor: Colors.teal,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operation failed'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _pickAndUploadImageForIndex(int index) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      final file = result.files.first;
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final imageUrl = await productProvider.uploadProductImage(
        file.bytes!,
        file.name,
        authProvider.user?.token,
      );

      if (imageUrl != null) {
        setState(() {
          _imageControllers[index].text = imageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded!'), backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<void> _validateUrl(String url) async {
    if (url.isEmpty) {
      setState(() => _isUrlValid = true);
      return;
    }

    setState(() => _isCheckingUrl = true);

    try {
      final response = await http.head(Uri.parse(url));
      setState(() {
        _isUrlValid = response.statusCode == 200;
        _isCheckingUrl = false;
      });
    } catch (_) {
      setState(() {
        _isUrlValid = false;
        _isCheckingUrl = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product == null ? 'New Product' : 'Edit Product', 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal.shade900,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Product Name',
                icon: Icons.title_rounded,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _descController,
                label: 'Description',
                icon: Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              Consumer<ProductProvider>(
                builder: (context, provider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _categoryController,
                        label: 'Category',
                        icon: Icons.category_outlined,
                        hintText: 'e.g. Soin du Visage',
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      if (provider.categories.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: provider.categories.map((cat) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ActionChip(
                                    label: Text(cat, style: const TextStyle(fontSize: 12)),
                                    onPressed: () {
                                      setState(() {
                                        _categoryController.text = cat;
                                      });
                                    },
                                    backgroundColor: Colors.teal.shade50,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Price (€)',
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) => double.tryParse(val ?? '') == null ? 'Invalid price' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _discountPriceController,
                      label: 'Discount Price (€)',
                      icon: Icons.local_offer_outlined,
                      keyboardType: TextInputType.number,
                      hintText: 'Optional',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _skuController,
                label: 'SKU / Code',
                icon: Icons.qr_code_rounded,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Product Images',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade900),
              ),
              const SizedBox(height: 8),
              ...List.generate(_imageControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _imageControllers[index],
                          label: 'Image URL ${index + 1}',
                          icon: Icons.image_outlined,
                          onChanged: (val) => setState(() {}),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _pickAndUploadImageForIndex(index),
                        icon: const Icon(Icons.upload_file, color: Colors.teal),
                      ),
                      if (_imageControllers.length > 1)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _imageControllers[index].dispose();
                              _imageControllers.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _imageControllers.add(TextEditingController());
                  });
                },
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add Another Image'),
                style: TextButton.styleFrom(foregroundColor: Colors.teal),
              ),
              if (_imageControllers.any((c) => c.text.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageControllers.where((c) => c.text.isNotEmpty).length,
                      itemBuilder: (context, index) {
                        final validUrls = _imageControllers.where((c) => c.text.isNotEmpty).toList();
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Image.network(
                            validUrls[index].text,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image_outlined, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  widget.product == null ? 'Add to Inventory' : 'Update Product',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.teal.shade400, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
