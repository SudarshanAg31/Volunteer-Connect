// import 'package:flutter/material.dart';
// import '../screens/splash_screen.dart';
// import '../screens/login_screen.dart';
// import '../screens/register_screen.dart';
// import '../screens/volunteer_home_screen.dart';
// import '../screens/opportunity_details_screen.dart';
// import '../screens/my_activities_screen.dart';
// import '../screens/profile_screen.dart';
// import '../screens/admin_dashboard_screen.dart';

// class AppRoutes {
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String register = '/register';
//   static const String volunteerHome = '/volunteer-home';
//   static const String opportunityDetails = '/opportunity-details';
//   static const String myActivities = '/my-activities';
//   static const String profile = '/profile';
//   static const String adminDashboard = '/admin-dashboard';

//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case splash:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
//       case login:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());
//       case register:
//         return MaterialPageRoute(builder: (_) => const RegisterScreen());
//       case volunteerHome:
//         return MaterialPageRoute(builder: (_) => const VolunteerHomeScreen());
//       case opportunityDetails:
//         final args = settings.arguments as Map<String, dynamic>?;
//         return MaterialPageRoute(
//           builder: (_) => OpportunityDetailsScreen(
//             opportunityId: args?['opportunityId'] ?? 0,
//           ),
//         );
//       case myActivities:
//         return MaterialPageRoute(builder: (_) => const MyActivitiesScreen());
//       case profile:
//         return MaterialPageRoute(builder: (_) => const ProfileScreen());
//       case adminDashboard:
//         return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
//       default:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
//     }
//   }
// }