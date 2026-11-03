class ApiConstants {
  // ============================================
  // ✅ PRODUCTION URL - Render Backend
  // ============================================
  static const String baseUrl = 'https://volunter-connect-backend.onrender.com/api';
  
  // ============================================
  // AUTH
  // ============================================
  static const String register = '$baseUrl/register/';
  static const String login = '$baseUrl/login/';
  
  // ============================================
  // USER
  // ============================================
  static String getUser(int userId) => '$baseUrl/users/$userId/';
  
  // ============================================
  // OPPORTUNITIES
  // ============================================
  static const String opportunities = '$baseUrl/opportunities/';
  static String getOpportunity(int id) => '$baseUrl/opportunities/$id/';
  static String getApplicants(int id) => '$baseUrl/opportunities/$id/applicants/';
  
  // ============================================
  // APPLICATIONS
  // ============================================
  static const String applications = '$baseUrl/applications/';
  static String getUserApplications(int userId) => '$baseUrl/applications/user/$userId/';
  static String getApplication(int id) => '$baseUrl/applications/$id/';
  static String updateApplicationStatus(int id) => '$baseUrl/applications/$id/status/';
}