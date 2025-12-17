import 'package:flutter/material.dart';
import 'package:praise_choir_app/core/widgets/common/home_screen.dart';
import 'package:praise_choir_app/core/widgets/common/role_selection_screen.dart';
import 'package:praise_choir_app/core/widgets/common/splash_screen.dart';
import 'package:praise_choir_app/core/widgets/common/user_list_screen.dart';
import 'package:praise_choir_app/features/admin/admin_routes.dart';
import 'package:praise_choir_app/features/auth/presentation/screens/login_screen.dart';
import 'package:praise_choir_app/features/auth/presentation/screens/signup_screen.dart';

class Routes {
  static const String splash = '/';
  static const String roleSelection = '/role-selection';

  static const String login = '/login';
  static const String signUp = '/signup';

  static const String home = '/home';
  static const String manageUsers = '/manage-users';

  // admin
  static const String adminDashboard = '/admin';
  static const String memberManagement = '/admin/members';
  static const String adminApprovals = '/admin/approvals';
  static const String usageAnalytics = '/admin/analytics';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // 1. Check if the route belongs to the Admin section
    // This looks at the string (e.g., '/admin/dashboard')
    if (settings.name != null && settings.name!.startsWith('/admin')) {
      return AdminRoutes.generateRoute(settings);
    }
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case manageUsers:
        return MaterialPageRoute(builder: (_) => const UserListScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case roleSelection:
        return MaterialPageRoute(
          builder: (_) => RoleSelectionScreen(email: ''),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
