import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/api_service.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Application> _applications = [];
  List<Applicant> _applicants = [];
  bool _isLoading = false;
  String? _error;
  
  List<Application> get applications => _applications;
  List<Applicant> get applicants => _applicants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadUserApplications(int userId) async {
    _setLoading(true);
    _error = null;
    
    try {
      print('📋 Loading applications for user: $userId');
      
      final response = await _apiService.getUserApplications(userId);
      
      print('📦 Response: $response');
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        _applications = data.map((json) => Application.fromJson(json)).toList();
        _error = null;
        print('✅ Loaded ${_applications.length} applications');
      } else {
        _error = response['message'] ?? 'Failed to load applications';
        _applications = [];
        print('❌ Error: $_error');
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _applications = [];
      print('❌ Exception: $e');
    }
    
    _setLoading(false);
  }
  
  Future<bool> applyForOpportunity(int userId, int opportunityId) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.createApplication({
        'user_id': userId,
        'opportunity_id': opportunityId,
      });
      
      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to apply';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }
  
  bool hasAppliedToOpportunity(int opportunityId) {
    return _applications.any((app) => app.opportunityId == opportunityId);
  }
  
  Future<bool> cancelApplication(int applicationId) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.cancelApplication(applicationId);
      
      if (response['success'] == true) {
        _applications.removeWhere((app) => app.applicationId == applicationId);
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to cancel application';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }
  
  Future<void> loadApplicants(int opportunityId, String role, {String? email}) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.getApplicants(
        opportunityId,
        role,
        email: email,
      );
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        _applicants = data.map((json) => Applicant.fromJson(json)).toList();
      } else {
        _error = response['message'] ?? 'Failed to load applicants';
        _applicants = [];
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _applicants = [];
    }
    
    _setLoading(false);
  }
  
  Future<bool> updateApplicationStatus(
    int applicationId,
    String status,
    String role, {
    String? email,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      final response = await _apiService.updateApplicationStatus(
        applicationId,
        status,
        role,
        email: email,
      );
      
      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update status';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }
  
  void clearApplicants() {
    _applicants = [];
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}