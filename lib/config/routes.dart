import 'package:flutter/material.dart';
import 'package:praise_choir_app/core/widgets/common/home_screen.dart';
import 'package:praise_choir_app/core/widgets/common/main_navigation_shell.dart';
import 'package:praise_choir_app/core/widgets/common/pending_approval_screen.dart';
import 'package:praise_choir_app/core/widgets/common/role_selection_screen.dart';
import 'package:praise_choir_app/core/widgets/common/song_list_screen.dart';
import 'package:praise_choir_app/core/widgets/common/splash_screen.dart';
import 'package:praise_choir_app/core/widgets/common/user_list_screen.dart';
import 'package:praise_choir_app/features/admin/admin_routes.dart';
import 'package:praise_choir_app/features/auth/presentation/screens/login_screen.dart';
import 'package:praise_choir_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:praise_choir_app/features/songs/song_routes.dart';

class Routes {
  static const String splash = '/';
  static const String mainNavigationShell = '/mainNavigationShell';
  static const String roleSelection = '/role-selection';

  static const String login = '/login';
  static const String signUp = '/signup';

  static const String home = '/home';
  static const String manageUsers = '/manage-users';

  static const String pendingUser = '/pendingUser';
  static const String guestUser = '/guestUser';

  // admin
  static const String adminDashboard = '/admin';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // 1. Check if the route belongs to the Admin section
    // This looks at the string (e.g., '/admin/dashboard')
    // DEBUG: See what string is being sent
    if (settings.name != null && settings.name!.startsWith('/admin')) {
      return AdminRoutes.onGenerateRoute(settings);
    }
    if (settings.name != null && settings.name!.startsWith('/song')) {
      return SongRoutes.onGenerateRoute(settings);
    }
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
          settings: settings,
        );
      case pendingUser:
        return MaterialPageRoute(builder: (_) => PendingApprovalScreen());
      case guestUser:
        return MaterialPageRoute(builder: (_) => SongListScreen());
      case mainNavigationShell:
        return MaterialPageRoute(builder: (_) => MainNavigationShell());
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
