import 'package:praise_choir_app/features/events/data/models/announcement_model.dart';

abstract class EventRepository {
  Future<List<AnnouncementModel>> getAnnouncements();
  Future<List<AnnouncementModel>> getActiveAnnouncements();
  Future<String> createAnnouncement(AnnouncementModel announcement);
  Future<void> updateAnnouncement(AnnouncementModel announcement);
  Future<void> deleteAnnouncement(String id);
  Future<void> markAnnouncementAsRead(String announcementId, String userId);
}
