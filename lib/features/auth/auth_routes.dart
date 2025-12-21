import 'package:flutter/material.dart';
import 'package:praise_choir_app/core/widgets/common/role_selection_screen.dart';

class AuthRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case '/auth/login':
      // return MaterialPageRoute(builder: (_) => const LoginScreen());

      // case '/auth/otp':
      //   final args = settings.arguments as Map<String, dynamic>;
      //   return MaterialPageRoute(
      //     builder: (_) => OtpScreen(
      //       verificationId: args['verificationId'],
      //       email: args['email'],
      //     ),
      //   );
      // it will be edited
      case '/auth/role-selection':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RoleSelectionScreen(
            email: args['email'],
            // verificationId: args['verificationId'],
            user: null,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No auth route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

// Update the main routes.dart to include auth routes
// class AppRouter {
//   Route<dynamic> onGenerateRoute(RouteSettings settings) {
//     // Auth Routes
//     if (settings.name?.startsWith('/auth/') ?? false) {
//       return AuthRoutes.onGenerateRoute(settings);
//     }

//     // Other routes...
//     switch (settings.name) {
//       // ... existing routes
//       default:
//         return MaterialPageRoute(
//           builder: (_) => Scaffold(
//             body: Center(child: Text('No route defined for ${settings.name}')),
//           ),
//         );
//     }
//   }
// }
