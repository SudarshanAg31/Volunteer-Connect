import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../services/api_service.dart';

class OpportunityProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Opportunity> _opportunities = [];
  Opportunity? _selectedOpportunity;
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  String? _selectedCategory;
  
  List<Opportunity> get opportunities => _opportunities;
  Opportunity? get selectedOpportunity => _selectedOpportunity;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  
  final List<String> categories = [
    'All',
    'Education',
    'Environment',
    'Health',
    'Community',
    'Animal Welfare',
    'Social Service',
  ];
  
  // Role aur Email pass karo (NGO ke liye important)
   Future<void> loadOpportunities({String? search, String? category, String? role, String? email}) async {
    _setLoading(true);
    _error = null;
    _searchQuery = search;
    _selectedCategory = category;
    
    try {
      final response = await _apiService.getOpportunities(
        search: search,
        category: category != 'All' ? category : null,
        role: role,
        email: email,
      );
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        _opportunities = data.map((json) => Opportunity.fromJson(json)).toList();
      } else {
        _error = response['message'] ?? 'Failed to load opportunities';
        _opportunities = [];
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _opportunities = [];
    }
    
    _setLoading(false);
  }

  Future<bool> getOpportunityDetails(int id) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.getOpportunity(id);
      
      if (response['success'] == true) {
        _selectedOpportunity = Opportunity.fromJson(response['data']);
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Opportunity not found';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }
  
  // Data mein role aur email automatically pass hoga
  Future<bool> createOpportunity(Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.createOpportunity(data);
      
      if (response['success'] == true) {
        await loadOpportunities(
          role: data['role'],
          email: data['email'],
        );
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create opportunity';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> updateOpportunity(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.updateOpportunity(id, data);
      
      if (response['success'] == true) {
        await loadOpportunities(
          role: data['role'],
          email: data['email'],
        );
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update opportunity';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }
  
  // Delete mein role aur email dono pass karo
  Future<bool> deleteOpportunity(int id, String role, {String? email}) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.deleteOpportunity(id, role, email: email);
      
      if (response['success'] == true) {
        await loadOpportunities(
          role: role,
          email: email,
        );
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to delete opportunity';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }
  
  void clearSelectedOpportunity() {
    _selectedOpportunity = null;
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}