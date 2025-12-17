import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';

import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usersSub;

  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUser(String id) async {
    final doc = await _users.doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    // Ensure `id` is present for local model
    if (!data.containsKey('id')) data['id'] = doc.id;
    return UserModel.fromJson(data);
  }

  Future<void> updateUser(UserModel user) async {
    await _users.doc(user.id).update(user.toJson());
  }

  Future<void> deleteUser(String id) async {
    await _users.doc(id).delete();
  }

  /// Start listening to Firestore `users` collection and keep the local
  /// Hive `users` box in sync. On each snapshot the box is replaced with
  /// the latest documents from Firestore. This provides centralized
  /// remote control while preserving offline local access.
  void startUserSync() {
    // Avoid multiple subscriptions
    if (_usersSub != null) return;

    _usersSub = _users.snapshots().listen(
      (snapshot) async {
        try {
          final box = Hive.box<UserModel>(HiveBoxes.users);

          // Rebuild the box contents from Firestore documents.
          await box.clear();

          for (final doc in snapshot.docs) {
            final data = doc.data();
            if (!data.containsKey('id')) data['id'] = doc.id;
            final user = UserModel.fromJson(data);
            await box.add(user);
          }
        } catch (e) {
          // For now, print the error so it appears in logs. In production
          // consider using a logging service.
          // ignore: avoid_print
          print('UserRepository.startUserSync error: $e');
        }
      },
      onError: (e) {
        // ignore: avoid_print
        print('UserRepository snapshot error: $e');
      },
    );
  }

  /// Stop the firestore -> Hive sync subscription.
  Future<void> stopUserSync() async {
    await _usersSub?.cancel();
    _usersSub = null;
  }
}
