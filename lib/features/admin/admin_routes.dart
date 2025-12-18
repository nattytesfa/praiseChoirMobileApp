import 'package:flutter/material.dart';
import 'package:praise_choir_app/features/admin/presentation/screens/approve_access.dart';
import 'presentation/screens/admin_dashboard.dart';
import 'presentation/screens/member_management.dart';
import 'presentation/screens/usage_analytics.dart';
import 'presentation/screens/system_settings.dart';

class AdminRoutes {
  static const String adminDashboard = '/admin/dashboard';
  static const String memberManagement = '/admin/members';
  static const String adminApprovals = '/admin/approvals';
  static const String usageAnalytics = '/admin/analytics';
  static const String systemSettings = '/admin/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case memberManagement:
        return MaterialPageRoute(
          builder: (_) => const MemberManagementScreen(),
        );
      case usageAnalytics:
        return MaterialPageRoute(builder: (_) => const UsageAnalyticsScreen());
      case systemSettings:
        return MaterialPageRoute(builder: (_) => const SystemSettingsScreen());
      case adminApprovals:
        return MaterialPageRoute(builder: (_) => const ApproveAccessScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'From adminroutes: No route defined for ${settings.name}',
              ),
            ),
          ),
        );
    }
  }
}
