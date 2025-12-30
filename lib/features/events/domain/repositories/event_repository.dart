import 'package:praise_choir_app/features/events/data/models/event_model.dart';
import 'package:praise_choir_app/features/events/data/models/announcement_model.dart';
import 'package:praise_choir_app/features/events/data/models/poll_model.dart';

abstract class EventRepository {
  Future<List<EventModel>> getEvents();
  Future<List<EventModel>> getUpcomingEvents();
  Future<List<EventModel>> getEventsByMonth(DateTime month);
  Future<EventModel> getEventById(String id);
  Future<String> createEvent(EventModel event);
  Future<void> updateEvent(EventModel event);
  Future<void> deleteEvent(String id);
  Future<void> rsvpToEvent(String eventId, String userId, bool attending);

  Future<List<AnnouncementModel>> getAnnouncements();
  Future<List<AnnouncementModel>> getActiveAnnouncements();
  Future<String> createAnnouncement(AnnouncementModel announcement);
  Future<void> updateAnnouncement(AnnouncementModel announcement);
  Future<void> deleteAnnouncement(String id);
  Future<void> markAnnouncementAsRead(String announcementId, String userId);

  Future<List<PollModel>> getPolls();
  Future<List<PollModel>> getActivePolls();
  Future<PollModel> getPollById(String id);
  Future<String> createPoll(PollModel poll);
  Future<void> voteOnPoll(String pollId, String userId, String optionId);
  Future<void> closePoll(String pollId);
}
