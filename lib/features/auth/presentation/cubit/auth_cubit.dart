import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/config/routes.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';
import 'auth_state.dart';
import 'package:hive/hive.dart';

class AuthCubit extends Cubit<AuthState> {
  final dynamic _auth;
  final AuthRepository authRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Box<UserModel> _usersBox;

  /// If [disableFirebase] is true, the cubit will not call Firebase APIs and
  /// will operate in a disabled mode suitable for testing other features.
  AuthCubit(
    AuthRepository authRepository, {
    AuthRepository? repository,
    bool disableFirebase = false,
  }) : _auth = disableFirebase ? null : FirebaseAuth.instance,
       authRepository = repository ?? AuthRepository(),
       super(AuthInitial()) {
    // Only check auth status when Firebase is available.
    if (_auth != null) checkAuthStatus();
  }

  Future<void> appStarted() async {
    try {
      // 1. Ask the repository to check Firebase and Hive
      final user = await authRepository.getCurrentUser();

      if (user != null) {
        // 2. If a user is found, skip login
        emit(AuthAuthenticated(user));
      } else {
        // 3. If no user, show login screen
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError("Failed to initialize: $e"));
    }
  }

  Future<void> refreshUserStatus() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // 1. Fetch fresh data from Firestore
      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final updatedUser = UserModel.fromFirestore(doc.id, doc.data()!);

      // 2. Update local Hive cache
      await _usersBox.put(updatedUser.id, updatedUser);

      // 3. Emit new state to trigger UI update
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      emit(AuthError("Failed to refresh: $e"));
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await authRepository.logout(); // Call repo to clear Firebase/Hive
      emit(AuthUnauthenticated()); // Tell UI to go back to Login screen
      if (!context.mounted) return;
      // Use the root navigator to ensure we clear the app's top-level
      // navigation stack (avoids nested navigator contexts leaving the
      // `MainNavigationShell` in the background).
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil(Routes.login, (route) => false);
    } catch (e) {
      emit(AuthError("Logout failed: $e"));
    }
  }

  void checkAuthStatus() async {
    if (_auth == null) {
      // Firebase disabled — try to restore a persisted local user.
      final current = await authRepository.getCurrentUser();
      if (current != null) {
        emit(AuthAuthenticated(current));
        return;
      }
      emit(AuthUnauthenticated());
      return;
    }

    final auth = _auth;
    final user = auth.currentUser;
    if (user != null) {
      // If a Firebase user exists, ensure they're authorized by checking the
      // leaders-managed `users` Hive box. If authorized, emit authenticated
      // state with the matching stored UserModel; otherwise emit unauthenticated.
      try {
        final email = user.email ?? '';
        final userBox = Hive.box<UserModel>(HiveBoxes.users);
        final matches = userBox.values
            .cast<UserModel>()
            .where((u) => u.email == email)
            .toList();
        if (matches.isEmpty) {
          // Not an authorized user
          await auth.signOut();
          emit(AuthUnauthenticated());
          return;
        }
        final matching = matches.first;
        await authRepository.saveUser(matching);
        emit(AuthAuthenticated(matching));
        return;
      } catch (e) {
        emit(AuthError('Failed to verify stored user'));
        return;
      }
    } else {
      // No Firebase currentUser — fallback to locally persisted user so the
      // app doesn't prompt to login repeatedly between restarts.
      final current = await authRepository.getCurrentUser();
      if (current != null) {
        emit(AuthAuthenticated(current));
        return;
      }
      emit(AuthUnauthenticated());
    }
  }

  /// Sign in with email and password. If the user's email is not verified
  /// the method will send a verification email and emit an error instructing
  /// the user to verify. On successful sign-in and authorization the
  /// AuthAuthenticated state will be emitted.
  Future<void> emailSignIn(String email, String password) async {
    emit(AuthLoading());

    try {
      // 1. Use the repository to handle the heavy lifting.
      // It handles: Firebase Sign-In, Firestore Fetching, and Hive Saving.
      final user = await authRepository.signInWithEmail(
        email: email,
        password: password,
      );

      // 2. If the repository succeeded, we now have a UserModel.
      // Emitting this state tells the LoginScreen BlocListener to navigate.
      emit(AuthAuthenticated(user));
    } on FirebaseAuthException catch (e) {
      // Catch specific Firebase errors (e.g., 'wrong-password')
      emit(AuthError(e.message ?? 'Authentication failed'));
    } catch (e) {
      // Catch any other errors (e.g., Hive errors or Network issues)
      emit(AuthError(e.toString()));
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String role = 'member',
  }) async {
    emit(AuthLoading());

    try {
      final status = (role == 'guest') ? 'approved' : 'pending';
      // 1. Let the repository handle the complex work:
      // - Creating the Firebase account
      // - Updating the Firestore document
      // - Saving the UserModel to Hive
      final user = await authRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        role: role,
        approvalStatus: status, // Pass this to repository
      );

      // 2. Emit success only after the repository finishes successfully.
      // This state is what the BlocListener in your SignUpScreen is waiting for.
      emit(AuthAuthenticated(user));
    } catch (e) {
      // If anything fails in the repository, we emit the error.
      // This stops the loading spinner in your UI.
      emit(AuthError(e.toString()));
    }
  }

  /// Password reset
  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await authRepository.sendPasswordResetEmail(email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

// admin_cubit.dart

List<UserModel> getRecentLogins(List<UserModel> members) {
  // Sort members: most recent login at the top
  final sorted = List<UserModel>.from(members);
  sorted.sort((a, b) {
    if (a.lastLogin == null) return 1;
    if (b.lastLogin == null) return -1;
    return b.lastLogin!.compareTo(a.lastLogin!);
  });
  return sorted;
}

Map<String, List<UserModel>> getActivitySegments(List<UserModel> members) {
  final now = DateTime.now();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));

  return {
    'active': members
        .where((u) => u.lastLogin != null && u.lastLogin!.isAfter(sevenDaysAgo))
        .toList(),
    'inactive': members
        .where(
          (u) => u.lastLogin == null || u.lastLogin!.isBefore(sevenDaysAgo),
        )
        .toList(),
  };
}
  // Future<void> googleSignIn() async {
  //   emit(AuthLoading());
  //   if (_auth == null) {
  //     emit(AuthError('Authentication disabled'));
  //     return;
  //   }
  //   try {
  //     final google = GoogleSignIn();
  //     final account = await google.signIn();
  //     if (account == null) {
  //       emit(AuthUnauthenticated());
  //       return;
  //     }
  //     final authDetails = await account.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: authDetails.accessToken,
  //       idToken: authDetails.idToken,
  //     );

  //     final userCredential = await _auth.signInWithCredential(credential);
  //     final fbUser = userCredential.user;
  //     if (fbUser == null) {
  //       emit(AuthError('Google sign-in failed'));
  //       return;
  //     }

  //     final userBox = Hive.box<UserModel>(HiveBoxes.users);
  //     final matches = userBox.values
  //         .cast<UserModel>()
  //         .where((u) => u.id == fbUser.uid || u.email == (fbUser.email ?? ''))
  //         .toList();
  //     if (matches.isEmpty) {
  //       await _auth.signOut();
  //       emit(AuthUnauthorized(fbUser.email ?? ''));
  //       return;
  //     }
  //     final matching = matches.first;
  //     await authRepository.saveUser(matching);
  //     emit(AuthAuthenticated(matching));
  //     return;
  //   } on FirebaseAuthException catch (e) {
  //     emit(AuthError(e.message ?? e.code));
  //   } catch (e) {
  //     emit(AuthError('Google sign-in failed'));
  //   }
  // }

