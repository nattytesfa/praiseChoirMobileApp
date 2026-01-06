import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'data/models/announcement_model.dart';
import 'presentation/screens/announcement_board.dart';
import 'presentation/screens/create_announcement_screen.dart';

class EventRoutes {
  static const String announcements = '/events/announcements';
  static const String createAnnouncement = '/events/create-announcement';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case announcements:
        return MaterialPageRoute(
          builder: (_) => const AnnouncementBoard(),
          settings: settings,
        );
      case createAnnouncement:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => CreateAnnouncementScreen(
            announcement: args is AnnouncementModel ? args : null,
          ),
          settings: settings,
        );

      default:
        return _errorRoute('No event route defined for ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('error'.tr())),
        body: Center(child: Text(message)),
      ),
    );
  }
}
