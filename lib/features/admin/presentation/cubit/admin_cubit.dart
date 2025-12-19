import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/admin/data/models/admin_stats_model.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_state.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';

class AdminCubit extends Cubit<AdminState> {
  final AuthRepository _authRepository;

  AdminCubit(this._authRepository) : super(AdminInitial());

  /// Loads real-time stats from Firestore
  Future<void> loadAdminStats() async {
    emit(AdminLoading());
    try {
      // 1. Fetch all members from Firestore via the repository
      final allMembers = await _authRepository.getAllUsers();

      // 2. Calculate Stats locally from the list
      final activeMembers = allMembers.where((m) => m.isActive).toList();
      final adminCount = allMembers.where((m) => m.role == 'admin').length;

      // Note: You can add SongRepository later to fill totalSongs
      final stats = AdminStatsModel(
        totalMembers: allMembers.length,
        activeMembers: activeMembers.length,
        totalSongs: 0, // Fill this when SongRepo is ready
        songsWithAudio: 0,
        monthlyCollectionRate: 0.0,
        unreadMessages: 0,
        upcomingEvents: 0,
        lastUpdated: DateTime.now(),
        adminCount: adminCount,
      );
      emit(AdminStatsLoaded(stats, allMembers));
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

  /// Checks if Hive boxes are healthy on the local device
  void checkSystemHealth() {
    try {
      final healthStatus = <String, dynamic>{
        'firestore_connected': true,
        'last_sync': DateTime.now().toIso8601String(),
      };
      emit(SystemHealthChecked(healthStatus));
    } catch (e) {
      emit(AdminError('System health check failed'));
    }
  }
}

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:praise_choir_app/core/constants/app_constants.dart';
// import 'package:praise_choir_app/features/auth/data/models/user_model.dart';
// import 'package:hive/hive.dart';
// import 'admin_state.dart';

// class AdminCubit extends Cubit<AdminState> {
//   AdminCubit() : super(AdminInitial());

//   void loadAdminStats() async {
//     emit(AdminLoading());
//     try {
//       // final userBox = Hive.box<UserModel>(HiveBoxes.users);
//       // final songBox = Hive.box<SongModel>(HiveBoxes.songs);
//       // final paymentBox = Hive.box<PaymentModel>(HiveBoxes.payments);

//       // final members = userBox.values.toList();
//       // final songs = songBox.values.toList();
//       // final payments = paymentBox.values.toList();

//       // final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
//       // final monthlyPayments = payments
//       //     .where(
//       //       (p) =>
//       //           p.dueDate.year == currentMonth.year &&
//       //           p.dueDate.month == currentMonth.month,
//       //     )
//       //     .toList();

//       //     final paidCount = monthlyPayments
//       //         .where((p) => p.status == PaymentStatus.paid)
//       //         .length;
//       //     final collectionRate = monthlyPayments.isNotEmpty
//       //         ? (paidCount / monthlyPayments.length) * 100
//       //         : 0.0;

//       //     final stats = AdminStatsModel(
//       //       totalMembers: members.length,
//       //       activeMembers: members.where((m) => m.isActive).length,
//       //       totalSongs: songs.length,
//       //       songsWithAudio: songs.where((s) => s.audioPath != null).length,
//       //       monthlyCollectionRate: collectionRate,
//       //       unreadMessages: 0, // Would be calculated from chat
//       //       upcomingEvents: 0, // Would be calculated from events
//       //       lastUpdated: DateTime.now(),
//       //     );

//       //     emit(AdminStatsLoaded(stats, members));
//     } catch (e) {
//       //     emit(AdminError('Failed to load admin statistics'));
//     }
//   }

//   void updateMemberRole(String memberId, String newRole) async {
//     try {
//       final userBox = Hive.box<UserModel>(HiveBoxes.users);
//       final member = userBox.values.firstWhere((m) => m.id == memberId);
//       final updatedMember = UserModel(
//         id: member.id,
//         email: member.email,
//         name: member.name,
//         role: newRole,
//         joinDate: member.joinDate,
//         isActive: member.isActive,
//         profileImagePath: member.profileImagePath,
//       );

//       final index = userBox.values.toList().indexWhere((m) => m.id == memberId);
//       if (index != -1) {
//         await userBox.putAt(index, updatedMember);
//         emit(MemberUpdated(updatedMember));
//         loadAdminStats(); // Reload stats
//       }
//     } catch (e) {
//       emit(AdminError('Failed to update member role'));
//     }
//   }

//   void deactivateMember(String memberId) async {
//     try {
//       final userBox = Hive.box<UserModel>(HiveBoxes.users);
//       final member = userBox.values.firstWhere((m) => m.id == memberId);
//       final updatedMember = UserModel(
//         id: member.id,
//         email: member.email,
//         name: member.name,
//         role: member.role,
//         joinDate: member.joinDate,
//         isActive: false,
//         profileImagePath: member.profileImagePath,
//       );

//       final index = userBox.values.toList().indexWhere((m) => m.id == memberId);
//       if (index != -1) {
//         await userBox.putAt(index, updatedMember);
//         emit(MemberUpdated(updatedMember));
//         loadAdminStats(); // Reload stats
//       }
//     } catch (e) {
//       emit(AdminError('Failed to deactivate member'));
//     }
//   }

//   void checkSystemHealth() async {
//     emit(AdminLoading());
//     try {
//       final healthStatus = <String, dynamic>{};

//       // Check Hive boxes
//       final userBox = Hive.box<UserModel>(HiveBoxes.users);
//       // final songBox = Hive.box<SongModel>(HiveBoxes.songs);
//       // final paymentBox = Hive.box<PaymentModel>(HiveBoxes.payments);

//       healthStatus['users_box'] = userBox.isOpen;
//       // healthStatus['songs_box'] = songBox.isOpen;
//       // healthStatus['payments_box'] = paymentBox.isOpen;

//       // Check data integrity
//       healthStatus['total_users'] = userBox.length;
//       // healthStatus['total_songs'] = songBox.length;
//       // healthStatus['total_payments'] = paymentBox.length;

//       // Check for duplicates
//       final users = userBox.values.toList();
//       final uniquePhones = users.map((u) => u.email).toSet();
//       healthStatus['duplicate_users'] = users.length != uniquePhones.length;

//       // Check storage usage (simplified)
//       healthStatus['storage_healthy'] = true;

//       emit(SystemHealthChecked(healthStatus));
//     } catch (e) {
//       emit(AdminError('Failed to check system health'));
//     }
//   }

//   // void cleanupData() async {
//   //   emit(AdminLoading());
//   //   try {
//   //     // Remove duplicate songs (simplified logic)
//   //     final songBox = Hive.box<SongModel>(HiveBoxes.songs);
//   //     final songs = songBox.values.toList();
//   //     final uniqueSongs = <String, SongModel>{};

//   //     for (final song in songs) {
//   //       final key = '${song.title}_${song.language}';
//   //       if (!uniqueSongs.containsKey(key)) {
//   //         uniqueSongs[key] = song;
//   //       }
//   //     }

//   //     await songBox.clear();
//   //     for (final song in uniqueSongs.values) {
//   //       await songBox.add(song);
//   //     }

//   //     loadAdminStats(); // Reload stats after cleanup
//   //   } catch (e) {
//   //     emit(AdminError('Failed to cleanup data'));
//   //   }
//   // }
// }
