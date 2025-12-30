import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common/empty_state.dart';
import '../../../../core/widgets/common/loading_indicator.dart';
import '../../data/models/event_model.dart';
import '../../data/models/event_type.dart';
import '../cubit/event_cubit.dart';
import '../cubit/event_state.dart';
import '../widgets/event_calendar.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventCubit>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Calendar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to create event
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BlocBuilder<EventCubit, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const LoadingIndicator();
          }

          if (state is EventError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<EventCubit>().loadEvents(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is EventLoaded) {
            final events = state.events;

            return Column(
              children: [
                EventCalendar(
                  events: events,
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  calendarFormat: _calendarFormat,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                  onPageChanged: (focusedDay) {
                    setState(() => _focusedDay = focusedDay);
                  },
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildEventList(events)),
              ],
            );
          }

          return const LoadingIndicator();
        },
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    final dayEvents = _getEventsForDay(_selectedDay, events);

    if (dayEvents.isEmpty) {
      return const EmptyState(
        icon: Icons.event,
        title: 'No Events',
        message: 'No events scheduled for this day.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 4,
              decoration: BoxDecoration(
                color: _getEventColor(event.type),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: Text(event.title, style: AppTextStyles.bodyMedium),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)} • ${event.location}',
                  style: AppTextStyles.caption,
                ),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to event details
            },
          ),
        );
      },
    );
  }

  List<EventModel> _getEventsForDay(DateTime? day, List<EventModel> events) {
    if (day == null) return [];
    return events.where((event) {
      return isSameDay(event.startTime, day);
    }).toList();
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.rehearsal:
        return Colors.blue;
      case EventType.performance:
        return Colors.green;
      case EventType.meeting:
        return Colors.orange;
      case EventType.social:
        return Colors.purple;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
