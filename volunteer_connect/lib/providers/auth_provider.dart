import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isVolunteer => _currentUser?.role == 'volunteer';
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isNgo => _currentUser?.role == 'ngo';
  
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.login(email, password);
      
      if (response['success'] == true) {
        _currentUser = User.fromJson(response['data']);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(response['data']));
        await prefs.setString('role', _currentUser!.role);
        await prefs.setString('email', _currentUser!.email);
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.register({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      });
      
      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }
  
  // ✅ ADD THIS METHOD
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.updateUserProfile(
        _currentUser!.id,
        {
          'name': name ?? _currentUser!.name,
          'phone': phone ?? _currentUser!.phone,
          'profile_image': profileImage ?? _currentUser!.profileImage,
        },
      );
      
      if (response['success'] == true) {
        final userData = response['data'];
        _currentUser = User.fromJson(userData);
        // Update SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(userData));
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Profile update failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }
  
  Future<void> logout() async {
    _currentUser = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('role');
    await prefs.remove('email');
    notifyListeners();
  }
  
  Future<void> loadSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
      notifyListeners();
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}