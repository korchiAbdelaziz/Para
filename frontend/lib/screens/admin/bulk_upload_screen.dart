import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import 'bulk_correction_screen.dart';

class BulkUploadScreen extends StatefulWidget {
  const BulkUploadScreen({super.key});

  @override
  State<BulkUploadScreen> createState() => _BulkUploadScreenState();
}

class _BulkUploadScreenState extends State<BulkUploadScreen> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) return;

    setState(() => _isUploading = true);
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final failedItems = await provider.uploadBulk(
      _selectedFile!.bytes!,
      _selectedFile!.name,
      auth.user?.token,
    );

    setState(() => _isUploading = false);

    if (mounted) {
      if (failedItems != null) {
        if (failedItems.isEmpty) {
          _showSuccessDialog();
        } else {
          _showPartialSuccessDialog(failedItems);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bulk upload failed'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showPartialSuccessDialog(List<dynamic> failedItems) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Action Required'),
        content: Text('${failedItems.length} items have missing or invalid data. Would you like to correct them manually?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BulkCorrectionScreen(invalidItems: failedItems),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            child: const Text('Correct Now'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Success!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Your products have been imported successfully.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Great!', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bulk Import', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal.shade900,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.teal.shade50.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.teal.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Import from CSV',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a CSV file containing your product information.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildFormatGuide(),
            const SizedBox(height: 32),
            if (_selectedFile != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined, color: Colors.teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedFile!.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _selectedFile = null),
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: _selectedFile == null ? _pickFile : _upload,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedFile == null ? Colors.white : Colors.teal,
                foregroundColor: _selectedFile == null ? Colors.teal : Colors.white,
                side: _selectedFile == null ? const BorderSide(color: Colors.teal) : null,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                _selectedFile == null ? 'Select CSV File' : 'Upload and Process',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: Colors.teal.shade700),
            const SizedBox(width: 8),
            Text(
              'File Format Guide',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Header: name,description,price,productCode\n\nExample:\nParacetamol,Pain reliever,5.99,PARA001',
            style: TextStyle(fontFamily: 'Courier', fontSize: 13),
          ),
        ),
      ],
    );
  }
}
