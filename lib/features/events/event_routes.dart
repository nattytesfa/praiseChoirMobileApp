import 'package:flutter/material.dart';
import 'data/models/event_model.dart';
import 'presentation/screens/announcement_board.dart';
import 'presentation/screens/create_event_screen.dart';
import 'presentation/screens/create_poll_screen.dart';
import 'presentation/screens/event_calendar_screen.dart';
import 'presentation/screens/event_detail_screen.dart';

class EventRoutes {
  static const String calendar = '/events/calendar';
  static const String announcements = '/events/announcements';
  static const String createEvent = '/events/create';
  static const String createPoll = '/events/create-poll';
  static const String eventDetail = '/events/detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case calendar:
        return MaterialPageRoute(
          builder: (_) => const EventCalendarScreen(),
          settings: settings,
        );

      case announcements:
        return MaterialPageRoute(
          builder: (_) => const AnnouncementBoard(),
          settings: settings,
        );

      case createEvent:
        return MaterialPageRoute(
          builder: (_) => const CreateEventScreen(),
          settings: settings,
        );

      case createPoll:
        return MaterialPageRoute(
          builder: (_) => const CreatePollScreen(),
          settings: settings,
        );

      case eventDetail:
        final args = settings.arguments;
        if (args is EventModel) {
          return MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: args),
            settings: settings,
          );
        }
        return _errorRoute('Invalid arguments for event detail');

      default:
        return _errorRoute('No event route defined for ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(message)),
      ),
    );
  }

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      calendar: (context) => const EventCalendarScreen(),
      announcements: (context) => const AnnouncementBoard(),
      createEvent: (context) => const CreateEventScreen(),
      createPoll: (context) => const CreatePollScreen(),
    };
  }

  // Modal routes
  static Future<T?> showEventFilters<T>({
    required BuildContext context,
    required Function(Map<String, dynamic>) onFiltersApplied,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Event Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Placeholder for filters
            const Text('Filter by type, date, etc.'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onFiltersApplied({});
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
