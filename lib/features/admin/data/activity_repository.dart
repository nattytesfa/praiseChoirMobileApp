import 'package:praise_choir_app/features/admin/data/models/activity_event.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
import 'package:praise_choir_app/features/payment/data/payment_repository.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_model.dart';
import 'package:hive/hive.dart';
import 'package:praise_choir_app/features/chat/data/models/message_model.dart';
import 'package:praise_choir_app/features/events/data/models/announcement_model.dart';

class ActivityRepository {
  final AuthRepository _authRepository;
  final PaymentRepository _paymentRepository;

  ActivityRepository(this._authRepository, this._paymentRepository);

  Future<List<ActivityEvent>> getRecentActivities() async {
    final List<ActivityEvent> activities = [];

    // 1. User Registrations
    try {
      final users = await _authRepository.getAllUsers();
      for (var user in users) {
        activities.add(
          ActivityEvent(
            title: 'New Member Joined',
            description: '${user.name} joined the choir (Pending Approval).',
            timestamp: user.joinDate,
            type: ActivityType.userRegistration,
            user: user.name,
          ),
        );

        if (user.statusUpdatedAt != null) {
          String status = user.approvalStatus;
          // Capitalize
          String formattedStatus = status.isNotEmpty
              ? '${status[0].toUpperCase()}${status.substring(1)}'
              : status;

          activities.add(
            ActivityEvent(
              title: 'User $formattedStatus',
              description: '${user.name} was marked as $status.',
              timestamp: user.statusUpdatedAt!,
              type: ActivityType.userStatusChange,
              user: user.name,
            ),
          );
        }
      }
    } catch (e) {
      // Ignore errors for individual sources
    }

    // 2. Songs Activity (Added, Edited, Deleted)
    try {
      final songBox = Hive.box<SongModel>('songs');
      final songs = songBox.values.toList();

      for (var song in songs) {
        // A. Song Added
        activities.add(
          ActivityEvent(
            title: 'New Song Added',
            description: '"${song.title}" was added to the repertoire.',
            timestamp: song.dateAdded,
            type: ActivityType.songAdded,
            user: song.addedBy,
          ),
        );

        // B. Song Deleted
        if (song.isDeleted &&
            song.metadata != null &&
            song.metadata!['deletedAt'] != null) {
          final deletedAt = DateTime.parse(song.metadata!['deletedAt']);
          activities.add(
            ActivityEvent(
              title: 'Song Deleted',
              description: '"${song.title}" was removed.',
              timestamp: deletedAt,
              type: ActivityType.songDeleted,
              user: 'Admin', // We don't track who deleted it yet, assume Admin
            ),
          );
        }

        // C. Song Edited (Only shows the LATEST edit)
        if (song.updatedAt != null) {
          // If deleted, check if update time matches delete time
          bool isDeleteAction = false;
          if (song.isDeleted &&
              song.metadata != null &&
              song.metadata!['deletedAt'] != null) {
            final deletedAt = DateTime.parse(song.metadata!['deletedAt']);
            if (song.updatedAt!.difference(deletedAt).inSeconds.abs() < 5) {
              isDeleteAction = true;
            }
          }

          // Also filter out if update time is very close to creation time (initial save quirks)
          if (!isDeleteAction &&
              song.updatedAt!.difference(song.dateAdded).inSeconds.abs() > 1) {
            activities.add(
              ActivityEvent(
                title: 'Song Edited',
                description: '"${song.title}" details were updated.',
                timestamp: song.updatedAt!,
                type: ActivityType.songEdited,
                user: 'Admin',
              ),
            );
          }
        }
      }
    } catch (e) {
      // Ignore
    }

    // 3. Payments Received
    try {
      final payments = await _paymentRepository.getAllPayments();
      for (var payment in payments) {
        if (payment.status == PaymentStatus.paid && payment.paidDate != null) {
          // We might need to fetch user name if not available in payment
          // For now, we'll use memberId or fetch user if possible.
          // Since this is async inside a loop, it's better to have a map of users.

          activities.add(
            ActivityEvent(
              title: 'Payment Received',
              description: 'Payment of ${payment.amount} received.',
              timestamp: payment.paidDate!,
              type: ActivityType.paymentReceived,
              user: 'Member ID: ${payment.memberId}', // Ideally resolve name
            ),
          );
        }
      }
    } catch (e) {
      // Ignore
    }

    // 4. Chat Activity (Deleted and Edited Messages)
    try {
      final messageBox = Hive.box<MessageModel>('messages');
      final messages = messageBox.values.toList();

      for (var msg in messages) {
        String title = '';
        String description = msg.content;
        bool shouldAdd = false;
        DateTime activityTime = msg.timestamp;

        if (msg.isDeleted) {
          title = 'Message Deleted';
          description = 'Content: "${msg.content}"';
          shouldAdd = true;

          if (msg.metadata != null && msg.metadata!.containsKey('deletedAt')) {
            activityTime = DateTime.parse(msg.metadata!['deletedAt']);
          }
        } else if (msg.isEdited) {
          title = 'Message Edited';
          String prev = 'Unknown';
          if (msg.metadata != null &&
              msg.metadata!.containsKey('previousContent')) {
            prev = msg.metadata!['previousContent'];
          }
          description = 'From: "$prev"\nTo: "${msg.content}"';
          shouldAdd = true;

          if (msg.metadata != null && msg.metadata!.containsKey('editedAt')) {
            activityTime = DateTime.parse(msg.metadata!['editedAt']);
          }
        }

        if (shouldAdd) {
          // Truncate description if too long (but keep enough to see change)
          if (description.length > 100) {
            description = '${description.substring(0, 100)}...';
          }

          activities.add(
            ActivityEvent(
              title: title,
              description: description,
              timestamp: activityTime,
              type: ActivityType.chatActivity,
              user: msg.senderName,
            ),
          );
        }
      }
    } catch (e) {
      // Ignore
    }

    // 5. Announcements
    try {
      final announcementBox = Hive.box<AnnouncementModel>('announcements');
      final announcements = announcementBox.values.toList();

      for (var a in announcements) {
        String title = 'Announcement: ${a.title}';
        String description = a.content;
        DateTime time = a.createdAt;

        if (a.isDeleted) {
          title = 'Announcement Deleted';
          description = 'Title: "${a.title}"';
          if (a.metadata != null && a.metadata!.containsKey('deletedAt')) {
            time = DateTime.parse(a.metadata!['deletedAt']);
          }
        } else if (a.isEdited) {
          title = 'Announcement Edited';
          String prev = 'Unknown';
          if (a.metadata != null &&
              a.metadata!.containsKey('previousContent')) {
            prev = a.metadata!['previousContent'];
          }
          description = 'From: "$prev"\nTo: "${a.content}"';
          if (a.metadata != null && a.metadata!.containsKey('editedAt')) {
            time = DateTime.parse(a.metadata!['editedAt']);
          }
        }

        activities.add(
          ActivityEvent(
            title: title,
            description: description,
            timestamp: time,
            type: ActivityType.announcement,
            user: a.authorName ?? 'Admin',
          ),
        );
      }
    } catch (e) {
      // Ignore
    }

    // Filter by last cleared timestamp
    final settingsBox = Hive.box('settings');
    final lastCleared =
        settingsBox.get('lastClearedActivityTimestamp') as DateTime?;

    if (lastCleared != null) {
      activities.removeWhere(
        (activity) => activity.timestamp.isBefore(lastCleared),
      );
    }

    // Sort by timestamp descending
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities;
  }

  Future<void> clearHistory() async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('lastClearedActivityTimestamp', DateTime.now());
  }
}
