import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/events/domain/repositories/event_repository.dart';
import 'package:praise_choir_app/features/events/data/models/announcement_model.dart';
import 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final EventRepository eventRepository;

  EventCubit({required this.eventRepository}) : super(EventInitial());

  Future<void> loadEvents() async {
    emit(EventLoading());
    try {
      final announcements = await eventRepository.getActiveAnnouncements();

      emit(EventLoaded(announcements: announcements));
    } catch (e) {
      emit(EventError('Failed to load announcements: ${e.toString()}'));
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

  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    emit(AnnouncementCreating()); // Reuse creating state or add Updating
    try {
      await eventRepository.updateAnnouncement(announcement);
      emit(AnnouncementCreated(announcement.id)); // Reuse created state
      await loadEvents();
    } catch (e) {
      emit(EventError('Failed to update announcement: ${e.toString()}'));
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    // emit(EventDeleting()); // Removed EventDeleting
    emit(EventLoading()); // Use loading for now
    try {
      await eventRepository.deleteAnnouncement(announcementId);
      // emit(EventDeleted()); // Removed EventDeleted
      await loadEvents();
    } catch (e) {
      emit(EventError('Failed to delete announcement: ${e.toString()}'));
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

  void clearError() {
    if (state is EventError) {
      loadEvents();
    }
  }
}
