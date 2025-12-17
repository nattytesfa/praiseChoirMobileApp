import 'package:praise_choir_app/core/constants/app_constants.dart';

class RoleConstants {
  static const List<String> leaderPermissions = [
    'manage_songs',
    'manage_members',
    'view_payments',
    'create_events',
    'send_announcements',
    'send_sms',
    'view_analytics',
  ];

  static const List<String> atigniPermissions = [
    'manage_songs',
    'view_songs',
    'chat',
    'view_events',
  ];

  static const List<String> prayerGroupPermissions = [
    'view_songs',
    'chat',
    'view_events',
    'mark_payments',
  ];

  static const List<String> memberPermissions = [
    'view_songs',
    'chat',
    'view_events',
    'mark_payments',
  ];

  static List<String> getPermissionsForRole(String role) {
    switch (role) {
      case AppConstants.roleLeader:
        return leaderPermissions;
      case AppConstants.roleSongwriter:
        return atigniPermissions;
      case AppConstants.rolePrayerGroup:
        return prayerGroupPermissions;
      case AppConstants.roleMember:
        return memberPermissions;
      default:
        return memberPermissions;
    }
  }

  static bool hasPermission(String role, String permission) {
    return getPermissionsForRole(role).contains(permission);
  }
}
