import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InventoryItem {
  final String productCode;
  final int quantity;

  InventoryItem({required this.productCode, required this.quantity});

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      productCode: json['productCode'],
      quantity: json['quantity'],
    );
  }
}

class InventoryProvider with ChangeNotifier {
  List<InventoryItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final String _baseUrl = 'http://localhost:8888/api/inventory';

  Future<void> fetchInventory(String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _items = data.map((item) => InventoryItem.fromJson(item)).toList();
      } else {
        _error = 'Failed to load inventory: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateInventory(Map<String, dynamic> updateData, String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/update'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        await fetchInventory(token);
        return true;
      } else {
        _error = 'Failed to update inventory: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
