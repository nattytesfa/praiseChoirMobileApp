import 'package:praise_choir_app/features/events/data/models/announcement_model.dart';

abstract class EventState {
  const EventState();
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<AnnouncementModel> announcements;

  const EventLoaded({required this.announcements});

  EventLoaded copyWith({List<AnnouncementModel>? announcements}) {
    return EventLoaded(announcements: announcements ?? this.announcements);
  }
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);
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

class PollVoting extends EventState {
  final String pollId;

  const PollVoting(this.pollId);
}

class PollVoted extends EventState {
  final String pollId;
  final String optionId;

  const PollVoted(this.pollId, this.optionId);
}
