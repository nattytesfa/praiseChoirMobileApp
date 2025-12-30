import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/event_model.dart';
import '../../data/models/event_type.dart';
import '../cubit/event_cubit.dart';
import '../cubit/event_state.dart';
import '../widgets/rsvp_button.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Edit event
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_formatDateTime(event.startTime)} - ${_formatTime(event.endTime)}',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(event.location, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.category, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _getEventTypeLabel(event.type),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Description
            if (event.description.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      Text(event.description, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // RSVP Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RSVP', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 12),
                    BlocBuilder<EventCubit, EventState>(
                      builder: (context, state) {
                        final isAttending = event.attendeeIds.contains(
                          'current_user_id',
                        );

                        return RsvpButton(
                          currentStatus: isAttending,
                          onStatusChanged: (bool attending) {
                            final userId = 'current_user_id';
                            context.read<EventCubit>().rsvpToEvent(
                              event.id,
                              userId,
                              attending,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${event.attendeeIds.length} attending',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.rehearsal:
        return 'Rehearsal';
      case EventType.performance:
        return 'Performance';
      case EventType.meeting:
        return 'Meeting';
      case EventType.social:
        return 'Social Event';
    }
  }
}
