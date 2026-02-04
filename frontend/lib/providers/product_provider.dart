import 'package:flutter/material.dart';
import '../models/product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'auth_provider.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  List<Product> get products {
    if (_selectedCategory == null || _selectedCategory == 'All') {
      return _products;
    }
    return _products.where((p) => p.category == _selectedCategory).toList();
  }
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final String _baseUrl = 'http://localhost:8888/api/product';

  Future<void> fetchProducts({bool filterStock = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_baseUrl?filterStock=$filterStock'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _products = data.map((item) => Product.fromJson(item)).toList();
      } else {
        _error = 'Failed to load products: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addProduct(Map<String, dynamic> productData, String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201) {
        await fetchProducts();
        return true;
      } else {
        _error = 'Failed to add product: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> productData, String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200) {
        await fetchProducts();
        return true;
      } else {
        _error = 'Failed to update product: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteProduct(String id, String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        await fetchProducts();
        return true;
      } else {
        _error = 'Failed to delete product: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<List<dynamic>?> uploadBulk(List<int> fileBytes, String fileName, String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/bulk'));
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: MediaType('text', 'csv'),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        await fetchProducts();
        final List<dynamic> failedItems = jsonDecode(response.body);
        _isLoading = false;
        notifyListeners();
        return failedItems;
      } else {
        _error = 'Failed to upload: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          _categories = ['All', ...data.map((e) => e.toString())];
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<String?> uploadProductImage(List<int> fileBytes, String fileName, String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload-image'));
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: MediaType('image', fileName.split('.').last),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return response.body; // Returns the image URL
      } else {
        _error = 'Failed to upload image: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }
}
