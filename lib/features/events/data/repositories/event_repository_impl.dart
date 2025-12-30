import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:praise_choir_app/core/services/connectivity_service.dart';
import 'package:praise_choir_app/features/events/data/models/event_model.dart';
import 'package:praise_choir_app/features/events/data/models/announcement_model.dart';
import 'package:praise_choir_app/features/events/data/models/poll_model.dart';
import 'package:praise_choir_app/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final ConnectivityService connectivityService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<EventModel> _eventBox = Hive.box<EventModel>('events');
  final Box<AnnouncementModel> _announcementBox = Hive.box<AnnouncementModel>(
    'announcements',
  );
  final Box<PollModel> _pollBox = Hive.box<PollModel>('polls');

  EventRepositoryImpl({required this.connectivityService});

  @override
  Future<List<EventModel>> getEvents() async {
    if (connectivityService.isConnected) {
      try {
        final snapshot = await _firestore.collection('events').get();
        final events = snapshot.docs
            .map((doc) => EventModel.fromJson(doc.data()))
            .toList();

        // Cache events
        await _eventBox.clear();
        for (var event in events) {
          await _eventBox.put(event.id, event);
        }
        return events;
      } catch (e) {
        // Fallback to cache on error
        return _eventBox.values.toList();
      }
    } else {
      return _eventBox.values.toList();
    }
  }

  @override
  Future<List<EventModel>> getUpcomingEvents() async {
    final now = DateTime.now();
    final events = await getEvents();
    return events.where((e) => e.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<List<EventModel>> getEventsByMonth(DateTime month) async {
    final events = await getEvents();
    return events
        .where(
          (e) =>
              e.startTime.year == month.year &&
              e.startTime.month == month.month,
        )
        .toList();
  }

  @override
  Future<EventModel> getEventById(String id) async {
    if (connectivityService.isConnected) {
      try {
        final doc = await _firestore.collection('events').doc(id).get();
        if (doc.exists) {
          final event = EventModel.fromJson(doc.data()!);
          await _eventBox.put(id, event);
          return event;
        }
      } catch (e) {
        // Fallback to cache
      }
    }

    final event = _eventBox.get(id);
    if (event != null) return event;
    throw Exception('Event not found');
  }

  @override
  Future<String> createEvent(EventModel event) async {
    if (!connectivityService.isConnected) {
      throw Exception('No internet connection');
    }

    // Validation
    if (event.endTime.isBefore(event.startTime)) {
      throw Exception('End time must be after start time');
    }

    await _firestore.collection('events').doc(event.id).set(event.toJson());
    await _eventBox.put(event.id, event);
    return event.id;
  }

  @override
  Future<void> updateEvent(EventModel event) async {
    if (!connectivityService.isConnected) {
      throw Exception('No internet connection');
    }

    await _firestore.collection('events').doc(event.id).update(event.toJson());
    await _eventBox.put(event.id, event);
  }

  @override
  Future<void> deleteEvent(String id) async {
    if (!connectivityService.isConnected) {
      throw Exception('No internet connection');
    }

    await _firestore.collection('events').doc(id).delete();
    await _eventBox.delete(id);
  }

  @override
  Future<void> rsvpToEvent(
    String eventId,
    String userId,
    bool attending,
  ) async {
    if (!connectivityService.isConnected) {
      throw Exception('No internet connection');
    }

    final eventRef = _firestore.collection('events').doc(eventId);

    if (attending) {
      await eventRef.update({
        'attendeeIds': FieldValue.arrayUnion([userId]),
      });
    } else {
      await eventRef.update({
        'attendeeIds': FieldValue.arrayRemove([userId]),
      });
    }

    // Update local cache if possible
    final event = _eventBox.get(eventId);
    if (event != null) {
      final attendees = List<String>.from(event.attendeeIds);
      if (attending && !attendees.contains(userId)) {
        attendees.add(userId);
      } else if (!attending) {
        attendees.remove(userId);
      }

      // Create a copy with updated attendees since fields are final
      // This would require a copyWith method on EventModel
    }
  }

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
        return announcements;
      } catch (e) {
        return _announcementBox.values.toList();
      }
    } else {
      return _announcementBox.values.toList();
    }
  }

  @override
  Future<List<AnnouncementModel>> getActiveAnnouncements() async {
    final announcements = await getAnnouncements();
    return announcements.where((a) => !a.isExpired).toList();
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

    await _firestore
        .collection('announcements')
        .doc(announcement.id)
        .update(announcement.toJson());
    await _announcementBox.put(announcement.id, announcement);
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    if (!connectivityService.isConnected) {
      throw Exception('No internet connection');
    }

    await _firestore.collection('announcements').doc(id).delete();
    await _announcementBox.delete(id);
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

  @override
  Future<List<PollModel>> getPolls() async {
    if (connectivityService.isConnected) {
      try {
        final snapshot = await _firestore
            .collection('polls')
            .orderBy('createdAt', descending: true)
            .get();
        final polls = snapshot.docs
            .map((doc) => PollModel.fromJson(doc.data()))
            .toList();

        await _pollBox.clear();
        for (var p in polls) {
          await _pollBox.put(p.id, p);
        }
        return polls;
      } catch (e) {
        return _pollBox.values.toList();
      }
    } else {
      return _pollBox.values.toList();
    }
  }

  @override
  Future<List<PollModel>> getActivePolls() async {
    final now = DateTime.now();
    final polls = await getPolls();
    return polls.where((p) => p.expiresAt.isAfter(now)).toList();
  }

  @override
  Future<PollModel> getPollById(String id) async {
    if (connectivityService.isConnected) {
      try {
        final doc = await _firestore.collection('polls').doc(id).get();
        if (doc.exists) {
          final poll = PollModel.fromJson(doc.data()!);
          await _pollBox.put(id, poll);
          return poll;
        }
      } catch (e) {
        // Fallback
      }
    }

    final poll = _pollBox.get(id);
    if (poll != null) return poll;
    throw Exception('Poll not found');
  }

  @override
  Future<String> createPoll(PollModel poll) async {
    if (!connectivityService.isConnected) {
      throw Exception('No internet connection');
    }

    if (poll.expiresAt.isBefore(DateTime.now())) {
      throw Exception('Poll expiration must be in the future');
    }

    await _firestore.collection('polls').doc(poll.id).set(poll.toJson());
    await _pollBox.put(poll.id, poll);
    return poll.id;
  }

  @override
  Future<void> voteOnPoll(String pollId, String userId, String optionId) async {
    if (!connectivityService.isConnected) {
      throw Exception('No internet connection');
    }

    // This is a simplified implementation. In a real app, you'd need to handle
    // removing previous votes if single-choice, etc.
    // This assumes the PollOption structure in Firestore matches the model

    // We need to find which option index this is to update it in Firestore
    final poll = await getPollById(pollId);
    final optionIndex = poll.options.indexWhere((o) => o.id == optionId);

    if (optionIndex == -1) throw Exception('Option not found');

    // Check if user already voted if necessary

    // Update the specific option in the array
    // Note: Updating an item in an array in Firestore is tricky without reading first
    // or using a different data structure.

    // For now, we'll just update the whole poll object
    final updatedOptions = List<PollOption>.from(poll.options);
    final option = updatedOptions[optionIndex];
    final updatedVoters = List<String>.from(option.voterIds)..add(userId);

    updatedOptions[optionIndex] = PollOption(
      id: option.id,
      text: option.text,
      voterIds: updatedVoters,
    );

    final updatedPoll = PollModel(
      id: poll.id,
      question: poll.question,
      options: updatedOptions,
      createdBy: poll.createdBy,
      createdAt: poll.createdAt,
      expiresAt: poll.expiresAt,
    );

    await updatePoll(updatedPoll);
  }

  Future<void> updatePoll(PollModel poll) async {
    await _firestore.collection('polls').doc(poll.id).update(poll.toJson());
    await _pollBox.put(poll.id, poll);
  }

  @override
  Future<void> closePoll(String pollId) async {
    if (!connectivityService.isConnected) {
      throw Exception('No internet connection');
    }

    await _firestore.collection('polls').doc(pollId).update({
      'expiresAt': DateTime.now().toIso8601String(),
    });
  }
}
