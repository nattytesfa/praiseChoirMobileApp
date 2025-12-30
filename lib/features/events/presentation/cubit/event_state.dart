import 'package:praise_choir_app/features/events/data/models/event_model.dart';
import 'package:praise_choir_app/features/events/data/models/announcement_model.dart';
import 'package:praise_choir_app/features/events/data/models/poll_model.dart';

abstract class EventState {
  const EventState();
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<EventModel> events;
  final List<AnnouncementModel> announcements;
  final List<PollModel> polls;

  const EventLoaded({
    required this.events,
    required this.announcements,
    required this.polls,
  });

  EventLoaded copyWith({
    List<EventModel>? events,
    List<AnnouncementModel>? announcements,
    List<PollModel>? polls,
  }) {
    return EventLoaded(
      events: events ?? this.events,
      announcements: announcements ?? this.announcements,
      polls: polls ?? this.polls,
    );
  }
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);
}

class EventCreating extends EventState {}

class EventCreated extends EventState {
  final String eventId;

  const EventCreated(this.eventId);
}

class EventUpdating extends EventState {}

class EventUpdated extends EventState {}

class EventDeleting extends EventState {}

class EventDeleted extends EventState {}

class EventRsvpLoading extends EventState {
  final String eventId;

  const EventRsvpLoading(this.eventId);
}

class EventRsvpSuccess extends EventState {
  final String eventId;
  final bool attending;

  const EventRsvpSuccess(this.eventId, this.attending);
}

class AnnouncementCreating extends EventState {}

class AnnouncementCreated extends EventState {
  final String announcementId;

  const AnnouncementCreated(this.announcementId);
}

class AnnouncementMarkingAsRead extends EventState {
  final String announcementId;

  const AnnouncementMarkingAsRead(this.announcementId);
}

class AnnouncementMarkedAsRead extends EventState {
  final String announcementId;

  const AnnouncementMarkedAsRead(this.announcementId);
}

class PollCreating extends EventState {}

class PollCreated extends EventState {
  final String pollId;

  const PollCreated(this.pollId);
}

class PollVoting extends EventState {
  final String pollId;

  const PollVoting(this.pollId);
}

class PollVoted extends EventState {
  final String pollId;
  final String optionId;

  const PollVoted(this.pollId, this.optionId);
}
