import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  final String _baseUrl = 'http://localhost:8888/auth';

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? data['access_token'];
        
        // Fetch full profile info
        final profileResponse = await http.get(
          Uri.parse('$_baseUrl/user/$username'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (profileResponse.statusCode == 200) {
          final profileData = jsonDecode(profileResponse.body);
          _user = User.fromJson({...profileData, 'token': token});
        } else {
           _user = User(
            id: '1',
            username: username,
            email: '',
            token: token,
          );
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('username', username);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> updateProfile(String name, String email, String phone, String address) async {
    if (_user == null || _user!.token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_user!.token}',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
        }),
      );

      if (response.statusCode == 200) {
        _user = _user!.copyWith(
          email: email,
          phone: phone,
          address: address,
        );
      } else {
        _error = 'Failed to update profile';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    if (_user == null || _user!.token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/${_user!.username}'),
        headers: {'Authorization': 'Bearer ${_user!.token}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson({...data, 'token': _user!.token});
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  void logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    notifyListeners();
  }
}
