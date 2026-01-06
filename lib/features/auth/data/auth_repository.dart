import 'package:praise_choir_app/features/auth/data/models/user_model.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  // Firebase services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hive boxes for local storage
  late Box _settingsBox;
  late Box<UserModel> _usersBox;
  bool _isInitialized = false;

  Future<AuthRepository> init() async {
    await _initializeHive();
    return this;
  }

  Future<void> _initializeHive() async {
    if (!_isInitialized) {
      _settingsBox = await Hive.openBox('settings');
      _usersBox = await Hive.openBox<UserModel>('users');
      _isInitialized = true;
    }
  }

  // Add this check to all methods
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeHive();
    }
  }

  Future<UserModel?> getUser(String id) async {
    await _ensureInitialized();
    // Try Hive first
    final user = _usersBox.get(id);
    if (user != null) return user;

    // Not found in Hive, try Firestore
    try {
      return await getFreshUserData(id);
    } catch (e) {
      return null;
    }
  }

  // Inside AuthRepository.dart
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                "Firestore request timed out. Check your internet.",
              );
            },
          );

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<UserModel> getFreshUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception("User not found");

    final user = UserModel.fromFirestore(doc.id, doc.data()!);

    // Sync the fresh data back to Hive so the cache stays updated
    await _usersBox.put(user.id, user);
    return user;
  }

  Future<void> updateUserRole(String targetUserId, String newRole) async {
    try {
      // 1. Only check the limit if we are UPGRADING someone to admin
      if (newRole == 'admin') {
        final adminQuery = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'admin')
            .get();

        // Check if the user is already an admin (don't count them twice)
        bool alreadyAdmin = adminQuery.docs.any(
          (doc) => doc.id == targetUserId,
        );

        if (!alreadyAdmin && adminQuery.docs.length > 3) {
          throw Exception('Limit reached: Maximum of 3 leaders allowed.');
        }
      }

      // 2. Perform the update for ANY role (admin, user, member, deactivated)
      await _firestore.collection('users').doc(targetUserId).update({
        'role': newRole,
      });
    } catch (e) {
      throw Exception('Failed to update role: $e');
    }
  }

  // ==================== FIREBASE AUTH METHODS ====================

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
    required String approvalStatus, // Add this parameter
  }) async {
    try {
      // 1. Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Create Model
      UserModel user = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        role: role,
        joinDate: DateTime.now(),
        approvalStatus: approvalStatus, // Set it here!
        lastLogin: DateTime.now(),
      );

      // 3. Save to Firestore
      await _firestore.collection('users').doc(user.id).set(user.toJson());

      // 4. Save to Hive - USE THE STRING 'users' DIRECTLY TO BE SAFE
      await _ensureInitialized(); // Make sure this opens the 'users' box
      await _usersBox.put(user.id, user);
      await _settingsBox.put('current_user_id', user.id);

      return user;
    } catch (e) {
      throw Exception('Repository Error: $e');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Authenticate with Firebase
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Check if user exists in Firestore
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      UserModel user;

      if (doc.exists) {
        // 3a. User exists in Firestore - create from document
        user = UserModel.fromJson(doc.data() as Map<String, dynamic>);

        // Update last login time
        user = user.copyWith(lastLogin: DateTime.now());

        // Update in Firestore
        await _firestore.collection('users').doc(user.id).update({
          'lastLogin': DateTime.now().toIso8601String(),
        });
      } else {
        // 3b. User doesn't exist in Firestore (edge case) - create new
        user = UserModel(
          id: credential.user!.uid,
          email: email,
          name: credential.user!.displayName ?? email.split('@').first,
          role: 'member', // Default role
          joinDate: DateTime.now(),
          isActive: true,
          profileImagePath: credential.user!.photoURL,
        );

        // Save to Firestore
        await _firestore.collection('users').doc(user.id).set(user.toJson());
      }

      // 4. Save locally to Hive
      await _saveUserLocally(user);

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _settingsBox.delete('current_user_id');
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Get current user stream (for auto-login state changes)
  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncMap((User? firebaseUser) async {
      if (firebaseUser == null) {
        await _settingsBox.delete('current_user_id');
        return null;
      }

      // Try to get user from Firestore
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        await _saveUserLocally(user);
        return user;
      }

      return null;
    });
  }

  /// In auth_repository.dart
  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Clear local storage (your existing logic)
      await _settingsBox.delete('current_user_id');
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
  // ==================== EXISTING LOCAL STORAGE METHODS ====================

  /// Get current user from local storage (preserving your existing logic)
  Future<UserModel?> getCurrentUser() async {
    // First try to get from Hive (your existing logic)
    await _ensureInitialized(); // ADD THIS LINE
    final id = _settingsBox.get('current_user_id') as String?;
    if (id == null) return null;

    UserModel? match;
    for (final u in _usersBox.values.cast<UserModel>()) {
      if (u.id == id) {
        match = u;
        break;
      }
    }

    // If found locally, verify with Firebase (optional)
    if (match != null) {
      // If we have a Firebase user, make sure it matches the local one
      if (_auth.currentUser != null && _auth.currentUser!.uid != match.id) {
        return null;
      }
      // Otherwise (Firebase agrees OR is not initialized/offline), return local user
      return match;
    }

    return null;
  }

  /// Save user both locally and update Firestore if needed
  Future<void> saveUser(UserModel user) async {
    await _settingsBox.put('current_user_id', user.id);

    // Update local storage
    final exists = _usersBox.values.cast<UserModel>().any(
      (u) => u.id == user.id,
    );
    if (!exists) {
      await _usersBox.add(user);
    }

    // Update Firestore as well
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }

  /// Update user in both local storage and Firestore
  Future<void> updateUser(UserModel user) async {
    // Update locally
    final idx = _usersBox.values.cast<UserModel>().toList().indexWhere(
      (u) => u.id == user.id,
    );
    if (idx >= 0) {
      await _usersBox.putAt(idx, user);
    }

    // Update in Firestore
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }

  Future<void> updateUserStatus(String userId, bool status) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  // auth_repository.dart
  Future<int> getUserCount() async {
    // Using .count() is cheaper than fetching all documents!
    final aggregateQuery = await _firestore.collection('users').count().get();
    return aggregateQuery.count ?? 0;
  }

  // song_repository.dart
  Future<int> getSongCount() async {
    final aggregateQuery = await _firestore.collection('songs').count().get();
    return aggregateQuery.count ?? 0;
  }

  // ==================== PRIVATE HELPER METHODS ====================

  /// Save user to local Hive storage
  Future<void> _saveUserLocally(UserModel user) async {
    await _settingsBox.put('current_user_id', user.id);

    final exists = _usersBox.values.cast<UserModel>().any(
      (u) => u.id == user.id,
    );
    if (!exists) {
      await _usersBox.add(user);
    } else {
      // Update existing user
      final idx = _usersBox.values.cast<UserModel>().toList().indexWhere(
        (u) => u.id == user.id,
      );
      if (idx >= 0) {
        await _usersBox.putAt(idx, user);
      }
    }
  }

  /// Handle Firebase Auth errors with user-friendly messages
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
