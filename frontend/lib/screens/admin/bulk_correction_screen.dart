import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';

class BulkCorrectionScreen extends StatefulWidget {
  final List<dynamic> invalidItems;

  const BulkCorrectionScreen({super.key, required this.invalidItems});

  @override
  State<BulkCorrectionScreen> createState() => _BulkCorrectionScreenState();
}

class _BulkCorrectionScreenState extends State<BulkCorrectionScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<Map<String, TextEditingController>> _controllers;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controllers = widget.invalidItems.map((item) {
      return {
        'name': TextEditingController(text: item['name'] ?? ''),
        'description': TextEditingController(text: item['description'] ?? ''),
        'price': TextEditingController(text: item['price']?.toString() ?? ''),
        'productCode': TextEditingController(text: item['productCode'] ?? ''),
        'category': TextEditingController(text: item['category'] ?? ''),
      };
    }).toList();
  }

  @override
  void dispose() {
    for (var row in _controllers) {
      row.values.forEach((c) => c.dispose());
    }
    super.dispose();
  }

  Future<void> _submitCorrections() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    int successCount = 0;
    for (var row in _controllers) {
      final productData = {
        'name': row['name']!.text,
        'description': row['description']!.text,
        'price': double.parse(row['price']!.text),
        'productCode': row['productCode']!.text,
        'category': row['category']!.text,
      };

      final success = await productProvider.addProduct(productData, auth.user?.token);
      if (success) successCount++;
    }

    setState(() => _isSubmitting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully added $successCount products'), backgroundColor: Colors.teal),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Correct Data', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _controllers.length,
                itemBuilder: (context, index) {
                  final row = _controllers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Entry #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                          const SizedBox(height: 12),
                          _buildField(row['name']!, 'Product Name', Icons.title),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildField(row['price']!, 'Price', Icons.payments, keyboardType: TextInputType.number)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildField(row['productCode']!, 'SKU', Icons.qr_code)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildField(row['category']!, 'Category', Icons.category),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitCorrections,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Save All Corrections', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }
}
