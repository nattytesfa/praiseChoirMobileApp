import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/events/domain/repositories/event_repository.dart';
import 'package:praise_choir_app/features/events/data/models/event_model.dart';
import 'package:praise_choir_app/features/events/data/models/announcement_model.dart';
import 'package:praise_choir_app/features/events/data/models/poll_model.dart';
import 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final EventRepository eventRepository;

  EventCubit({required this.eventRepository}) : super(EventInitial());

  Future<void> loadEvents() async {
    emit(EventLoading());
    try {
      final events = await eventRepository.getEvents();
      final announcements = await eventRepository.getActiveAnnouncements();
      final polls = await eventRepository.getActivePolls();

      emit(
        EventLoaded(events: events, announcements: announcements, polls: polls),
      );
    } catch (e) {
      emit(EventError('Failed to load events: ${e.toString()}'));
    }
  }

  Future<void> createEvent(EventModel event) async {
    // Optimistic update or separate loading state could be better,
    // but for now we'll stick to the pattern but handle errors better
    final currentState = state;
    emit(EventCreating());
    try {
      final eventId = await eventRepository.createEvent(event);
      emit(EventCreated(eventId));
      await loadEvents();
    } catch (e) {
      emit(EventError('Failed to create event: ${e.toString()}'));
      // Restore previous state if it was loaded
      if (currentState is EventLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> updateEvent(EventModel event) async {
    final currentState = state;
    emit(EventUpdating());
    try {
      await eventRepository.updateEvent(event);
      emit(EventUpdated());
      await loadEvents();
    } catch (e) {
      emit(EventError('Failed to update event: ${e.toString()}'));
      if (currentState is EventLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> deleteEvent(String eventId) async {
    final currentState = state;
    emit(EventDeleting());
    try {
      await eventRepository.deleteEvent(eventId);
      emit(EventDeleted());
      await loadEvents();
    } catch (e) {
      emit(EventError('Failed to delete event: ${e.toString()}'));
      if (currentState is EventLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> rsvpToEvent(
    String eventId,
    String userId,
    bool attending,
  ) async {
    // Don't replace the whole state, just emit a side-effect or partial update if possible
    // But since our state is monolithic, we have to be careful.
    // We'll emit a specific loading state that carries the current data if possible,
    // but for now we'll use the existing pattern but ensure we reload.

    // Ideally: emit(state.copyWith(rsvpLoading: true));

    emit(EventRsvpLoading(eventId));
    try {
      await eventRepository.rsvpToEvent(eventId, userId, attending);
      emit(EventRsvpSuccess(eventId, attending));
      await loadEvents();
    } catch (e) {
      emit(EventError('Failed to RSVP: ${e.toString()}'));
      // We should probably reload here too to ensure consistency
      await loadEvents();
    }
  }

  Future<void> createAnnouncement(AnnouncementModel announcement) async {
    emit(AnnouncementCreating());
    try {
      final announcementId = await eventRepository.createAnnouncement(
        announcement,
      );
      emit(AnnouncementCreated(announcementId));
      await loadEvents();
    } catch (e) {
      emit(EventError('Failed to create announcement: ${e.toString()}'));
    }
  }

  Future<void> markAnnouncementAsRead(
    String announcementId,
    String userId,
  ) async {
    emit(AnnouncementMarkingAsRead(announcementId));
    try {
      await eventRepository.markAnnouncementAsRead(announcementId, userId);
      emit(AnnouncementMarkedAsRead(announcementId));
      await loadEvents();
    } catch (e) {
      emit(EventError('Failed to mark announcement as read: ${e.toString()}'));
    }
  }

  Future<void> createPoll(PollModel poll) async {
    emit(PollCreating());
    try {
      final pollId = await eventRepository.createPoll(poll);
      emit(PollCreated(pollId));
      await loadEvents();
    } catch (e) {
      emit(EventError('Failed to create poll: ${e.toString()}'));
    }
  }

  Future<void> voteOnPoll(String pollId, String userId, String optionId) async {
    emit(PollVoting(pollId));
    try {
      await eventRepository.voteOnPoll(pollId, userId, optionId);
      emit(PollVoted(pollId, optionId));
      await loadEvents();
    } catch (e) {
      emit(EventError('Failed to vote: ${e.toString()}'));
    }
  }

  void clearError() {
    if (state is EventError) {
      loadEvents();
    }
  }
}
