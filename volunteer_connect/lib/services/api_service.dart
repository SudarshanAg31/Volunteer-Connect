import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

class ApiService {
  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Connection timeout'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getOpportunities({
    String? search,
    String? category,
    String? role,
    String? email,
  }) async {
    final uri = Uri.parse(ApiConstants.opportunities).replace(queryParameters: {
      if (search != null) 'search': search,
      if (category != null) 'category': category,
      if (role != null) 'role': role,
      if (email != null) 'email': email,
    });
    return _request(() => _client.get(uri));
  }

  Future<Map<String, dynamic>> getOpportunity(int id) async {
    return _request(() => _client.get(Uri.parse(ApiConstants.getOpportunity(id))));
  }

  Future<Map<String, dynamic>> createOpportunity(Map<String, dynamic> data) async {
    return _request(() => _client.post(
      Uri.parse(ApiConstants.opportunities),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  Future<Map<String, dynamic>> updateOpportunity(int id, Map<String, dynamic> data) async {
    return _request(() => _client.put(
      Uri.parse(ApiConstants.getOpportunity(id)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  Future<Map<String, dynamic>> deleteOpportunity(int id, String role, {String? email}) async {
    return _request(() => _client.delete(
      Uri.parse(ApiConstants.getOpportunity(id)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'role': role, 'email': email ?? ''}),
    ));
  }

  Future<Map<String, dynamic>> createApplication(Map<String, dynamic> data) async {
    return _request(() => _client.post(
      Uri.parse(ApiConstants.applications),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  Future<Map<String, dynamic>> getUserApplications(int userId) async {
    return _request(() => _client.get(Uri.parse(ApiConstants.getUserApplications(userId))));
  }

  Future<Map<String, dynamic>> cancelApplication(int applicationId) async {
    return _request(() => _client.delete(Uri.parse(ApiConstants.getApplication(applicationId))));
  }

  Future<Map<String, dynamic>> updateApplicationStatus(
    int applicationId,
    String status,
    String role, {
    String? email,
  }) async {
    return _request(() => _client.put(
      Uri.parse(ApiConstants.updateApplicationStatus(applicationId)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'role': role, 'status': status, 'email': email ?? ''}),
    ));
  }

  Future<Map<String, dynamic>> getApplicants(
    int opportunityId,
    String role, {
    String? email,
  }) async {
    final uri = Uri.parse(ApiConstants.getApplicants(opportunityId))
        .replace(queryParameters: {'role': role, 'email': email ?? ''});
    return _request(() => _client.get(uri));
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    return _request(() => _client.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    ));
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    return _request(() => _client.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }

  Future<Map<String, dynamic>> updateUserProfile(int userId, Map<String, dynamic> data) async {
    return _request(() => _client.put(
      Uri.parse(ApiConstants.getUser(userId)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ));
  }
}