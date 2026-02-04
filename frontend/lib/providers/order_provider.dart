import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final String _orderBaseUrl = 'http://localhost:8888/api/order';
  final String _authBaseUrl = 'http://localhost:8888/auth';

  Future<void> fetchUserOrders(String username, String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_orderBaseUrl/$username'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _orders = data.map((item) => Order.fromJson(item)).toList();
      } else {
        _error = 'Failed to load orders: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllOrders(String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(_orderBaseUrl),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _orders = data.map((item) => Order.fromJson(item)).toList();
      } else {
        _error = 'Failed to load all orders: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllUsers(String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_authBaseUrl/users'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _users = data.map((u) => u as Map<String, dynamic>).toList();
      } else {
        _error = 'Failed to load users: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> placeOrder(List<CartItem> cartItems, String username, String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final orderData = {
      'username': username,
      'orderLineItemsDtoList': cartItems.map((item) => {
        'productCode': item.productCode, // This is the SKU
        'price': item.price,
        'quantity': item.quantity,
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(_orderBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to place order: ${response.body}';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
