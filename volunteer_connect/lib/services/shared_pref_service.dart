// import 'package:shared_preferences/shared_preferences.dart';

// class SharedPrefService {
//   static const String _keyLoggedIn = 'isLoggedIn';
//   static const String _keyUserId = 'userId';
//   static const String _keyUserName = 'userName';
//   static const String _keyUserEmail = 'userEmail';
//   static const String _keyUserRole = 'userRole';
//   static const String _keyUserPhone = 'userPhone';
//   static const String _keyUserProfileImage = 'userProfileImage';
  
//   Future<void> saveSession({
//     required int userId,
//     required String name,
//     required String email,
//     required String phone,
//     required String role,
//     String? profileImage,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_keyLoggedIn, true);
//     await prefs.setInt(_keyUserId, userId);
//     await prefs.setString(_keyUserName, name);
//     await prefs.setString(_keyUserEmail, email);
//     await prefs.setString(_keyUserPhone, phone);
//     await prefs.setString(_keyUserRole, role);
//     if (profileImage != null) {
//       await prefs.setString(_keyUserProfileImage, profileImage);
//     }
//   }
  
//   Future<Map<String, dynamic>> getSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     return {
//       'isLoggedIn': prefs.getBool(_keyLoggedIn) ?? false,
//       'userId': prefs.getInt(_keyUserId) ?? 0,
//       'name': prefs.getString(_keyUserName) ?? '',
//       'email': prefs.getString(_keyUserEmail) ?? '',
//       'phone': prefs.getString(_keyUserPhone) ?? '',
//       'role': prefs.getString(_keyUserRole) ?? 'volunteer',
//       'profileImage': prefs.getString(_keyUserProfileImage),
//     };
//   }
  
//   Future<void> updateProfile({String? name, String? phone, String? profileImage}) async {
//     final prefs = await SharedPreferences.getInstance();
//     if (name != null) await prefs.setString(_keyUserName, name);
//     if (phone != null) await prefs.setString(_keyUserPhone, phone);
//     if (profileImage != null) await prefs.setString(_keyUserProfileImage, profileImage);
//   }
  
//  Future<void> clearSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_keyLoggedIn);
//     await prefs.remove(_keyUserId);
//     await prefs.remove(_keyUserName);
//     await prefs.remove(_keyUserEmail);
//     await prefs.remove(_keyUserPhone);
//     await prefs.remove(_keyUserRole);
//     await prefs.remove(_keyUserProfileImage);
//     print('✅ Session cleared!');
//   }
// }