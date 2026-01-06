import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:praise_choir_app/features/admin/data/models/admin_stats_model.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_state.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';

class AdminCubit extends Cubit<AdminState> {
  final AuthRepository _authRepository;
  final SongRepository _songRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminCubit(this._authRepository, this._songRepository)
    : super(AdminInitial());

  /// Loads real-time stats from Firestore
  Future<void> loadAdminStats() async {
    emit(AdminLoading());
    try {
      // 1. Fetch all members from Firestore via the repository
      final allMembers = await _authRepository.getAllUsers();

      // 2. Calculate Stats locally from the list
      final activeMembers = allMembers.where((m) => m.isActive).toList();
      final adminCount = allMembers
          .where((m) => m.role == 'leader' || m.role == 'admin')
          .length;

      // 3. Fetch Song Stats
      final allSongs = await _songRepository.getAllSongs();
      final songsWithAudio = allSongs.where((s) => s.audioPath != null).length;
      final amharicCount = allSongs
          .where((s) => s.language.toLowerCase().trim() == 'amharic')
          .length;
      final kembatignaCount = allSongs.where((s) {
        final lang = s.language.toLowerCase().trim();
        return lang == 'kembatigna' || lang == 'kembatgna';
      }).length;

      final stats = AdminStatsModel(
        totalMembers: allMembers.length,
        activeMembers: activeMembers.length,
        totalSongs: allSongs.length,
        songsWithAudio: songsWithAudio,
        monthlyCollectionRate: 0.0,
        unreadMessages: 0,
        upcomingEvents: 0,
        lastUpdated: DateTime.now(),
        adminCount: adminCount,
        lastSynced: DateTime.now(),
      );
      emit(
        AdminStatsLoaded(
          stats,
          allMembers,
          amharicSongsCount: amharicCount,
          kembatgnaSongsCount: kembatignaCount,
        ),
      );
    } catch (e) {
      emit(AdminError('Failed to load: ${e.toString()}'));
    }
  }

  /// Updates a member role and refreshes cloud data
  Future<void> updateMemberRole(String memberId, String newRole) async {
    try {
      // Update in Firestore
      await _authRepository.updateUserRole(memberId, newRole);

      // Refresh the local UI state
      await loadAdminStats();
    } catch (e) {
      emit(AdminError('Failed to update role: $e'));
    }
  }

  // admin_cubit.dart
  Future<void> activateMember(String userId) async {
    try {
      // Optional: emit(AdminLoading()); // Only if you want a full screen spinner
      await _authRepository.updateUserStatus(userId, true);

      // Refresh the list so the UI updates immediately
      await loadAdminStats();
    } catch (e) {
      if (!isClosed) {
        emit(AdminError('Failed to activate member: ${e.toString()}'));
      }
    }
  }

  /// Deactivates a member (Soft Delete)
  Future<void> deactivateMember(String memberId) async {
    try {
      await _authRepository.updateUserStatus(memberId, false);

      // await _authRepository.updateUserRole(memberId, 'deactivated');
      // Or create a specific method in repo: updateStatus(memberId, false)
      await loadAdminStats();
    } catch (e) {
      emit(AdminError('Failed to deactivate member'));
    }
  }

  Future<void> checkSystemHealth() async {
    // Save the current data before starting the check
    if (state is! AdminStatsLoaded) return;
    final currentState = state as AdminStatsLoaded;
    // emit(AdminLoading());
    try {
      // 1. Check local Hive boxes
      final usersBoxHealthy = Hive.isBoxOpen('users');
      final songsBoxHealthy = Hive.isBoxOpen('songs');
      final paymentsBoxHealthy = Hive.isBoxOpen('payments');

      // 2. Get counts from Repository (or direct Firestore calls)
      // final userCount = await _authRepository
      //     .getUserCount(); // Implement these in Repo
      // final songCount = await _songRepository.getSongCount();

      // 3. Logic checks (Example: Check for duplicate users)
      // For now, we'll set these to true, but you can add actual logic later
      bool hasDuplicates = false;

      final healthStatus = {
        'users_box': usersBoxHealthy,
        'songs_box': songsBoxHealthy,
        'payments_box': paymentsBoxHealthy,
        'duplicate_users': hasDuplicates,
        'storage_healthy': true,
        'total_users': currentState.members.length,
        'total_songs': 0,
        'total_payments': 0, // Update as needed
      };

      // THE FIX: Emit the new state WITH the old data
      emit(
        SystemHealthChecked(
          healthStatus,
          currentState.stats,
          currentState.members,
          amharicSongsCount: currentState.amharicSongsCount,
          kembatgnaSongsCount: currentState.kembatgnaSongsCount,
        ),
      );
    } catch (e) {
      emit(AdminError('Health check failed: $e'));
    }
  }

  // admin_cubit.dart

  Future<void> respondToRequest(
    String userId,
    bool approved, {
    String? message,
  }) async {
    try {
      final status = approved ? 'approved' : 'denied';

      // 1. Update Firestore
      await _firestore.collection('users').doc(userId).update({
        'approvalStatus': status,
        'adminMessage': message,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
        // If denied, we might want to keep them as guest, if approved, they become member
        'role': approved ? 'member' : 'guest',
      });

      // 2. Refresh the local data
      await loadAdminStats();
    } catch (e) {
      emit(AdminError("Failed to update user: $e"));
    }
  }

  Future<void> cleanupData() async {
    // Capture state before emitting loading
    final currentState = state;

    // This is a "Safety" feature: Clear local cache and reload
    emit(AdminLoading());

    // 1. Keep the dashboard visible by checking current state
    if (currentState is! AdminStatsLoaded) {
      // If we weren't loaded, just reload
      await loadAdminStats();
      return;
    }

    try {
      final userBox = Hive.box<UserModel>('users');
      await userBox.clear();
      // If you have other boxes, clear them the same way:
      // await Hive.box('songs').clear();
      // After clearing local, reload from Cloud
      // 3. Re-fetch data from Firestore so the UI isn't empty
      await loadAdminStats();
      // 4. Optionally run a health check to show the green checkmarks again
      await checkSystemHealth();
    } catch (e) {
      emit(AdminError('Cleanup failed: ${e.toString()}'));
      // Re-emit the previous state so the dashboard doesn't disappear
      emit(currentState);
    }
  }
}
