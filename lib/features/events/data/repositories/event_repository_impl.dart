import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:praise_choir_app/core/services/connectivity_service.dart';
import 'package:praise_choir_app/features/events/data/models/announcement_model.dart';
import 'package:praise_choir_app/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final ConnectivityService connectivityService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<AnnouncementModel> _announcementBox = Hive.box<AnnouncementModel>(
    'announcements',
  );

  EventRepositoryImpl({required this.connectivityService});

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    if (connectivityService.isConnected) {
      try {
        final snapshot = await _firestore
            .collection('announcements')
            .orderBy('createdAt', descending: true)
            .get();
        final announcements = snapshot.docs
            .map((doc) => AnnouncementModel.fromJson(doc.data()))
            .toList();

        await _announcementBox.clear();
        for (var a in announcements) {
          await _announcementBox.put(a.id, a);
        }
        return _sortAnnouncements(announcements);
      } catch (e) {
        return _sortAnnouncements(_announcementBox.values.toList());
      }
    } else {
      return _sortAnnouncements(_announcementBox.values.toList());
    }
  }

  List<AnnouncementModel> _sortAnnouncements(List<AnnouncementModel> list) {
    // Sort by urgent first, then by date descending
    list.sort((a, b) {
      if (a.isUrgent && !b.isUrgent) return -1;
      if (!a.isUrgent && b.isUrgent) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  @override
  Future<List<AnnouncementModel>> getActiveAnnouncements() async {
    final announcements = await getAnnouncements();
    return announcements.where((a) => !a.isExpired && !a.isDeleted).toList();
  }

  @override
  Future<String> createAnnouncement(AnnouncementModel announcement) async {
    if (!connectivityService.isConnected) {
      throw Exception('No internet connection');
    }

    await _firestore
        .collection('announcements')
        .doc(announcement.id)
        .set(announcement.toJson());
    await _announcementBox.put(announcement.id, announcement);
    return announcement.id;
  }

  @override
  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    if (!connectivityService.isConnected) {
      throw Exception('No internet connection');
    }

    // Get the previous version to track content changes if needed
    // But caller passed the new 'announcement' object.
    // Ideally we should fetch the old one to compare content, but let's assume 'announcement' has the new content.
    // We need to mark it as edited.

    final metadata = Map<String, dynamic>.from(announcement.metadata ?? {});
    // Note: We don't have the OLD content here easily unless we fetch.
    // Let's fetch local first.
    final oldAnnouncement = _announcementBox.get(announcement.id);
    if (oldAnnouncement != null) {
      metadata['previousContent'] = oldAnnouncement.content;
    }

    metadata['editedAt'] = DateTime.now().toIso8601String();

    final updatedAnnouncement = announcement.copyWith(
      isEdited: true,
      metadata: metadata,
    );

    await _firestore
        .collection('announcements')
        .doc(updatedAnnouncement.id)
        .update(updatedAnnouncement.toJson());
    await _announcementBox.put(updatedAnnouncement.id, updatedAnnouncement);
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    if (!connectivityService.isConnected) {
      throw Exception('No internet connection');
    }

    // Soft delete
    final announcement = _announcementBox.get(id);
    if (announcement != null) {
      final metadata = Map<String, dynamic>.from(announcement.metadata ?? {});
      metadata['deletedAt'] = DateTime.now().toIso8601String();

      final deletedAnnouncement = announcement.copyWith(
        isDeleted: true,
        metadata: metadata,
      );

      await _firestore
          .collection('announcements')
          .doc(id)
          .update(deletedAnnouncement.toJson());

      await _announcementBox.put(id, deletedAnnouncement);
    }
  }

  @override
  Future<void> markAnnouncementAsRead(
    String announcementId,
    String userId,
  ) async {
    if (!connectivityService.isConnected) {
      throw Exception('No internet connection');
    }

    await _firestore.collection('announcements').doc(announcementId).update({
      'readBy': FieldValue.arrayUnion([userId]),
    });
  }
}
