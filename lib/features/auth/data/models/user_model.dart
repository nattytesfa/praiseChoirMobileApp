import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String id; // This will match Firebase UID

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String role; // leader, songWriter, member, prayerGroup

  @HiveField(4)
  final DateTime joinDate;

  @HiveField(5)
  final bool isActive;

  @HiveField(6)
  final String? profileImagePath;

  @HiveField(7)
  final DateTime? lastLogin;

  @HiveField(8)
  final bool emailVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.joinDate,
    this.isActive = true,
    this.profileImagePath,
    this.lastLogin,
    this.emailVerified = false,
  });

  // Convert Firebase User to your UserModel
  factory UserModel.fromFirebaseUser(
    User user, {
    String? name,
    String role = 'member',
  }) {
    return UserModel(
      id: user.uid,
      email: user.email!,
      name: name ?? user.displayName ?? user.email!.split('@').first,
      role: role,
      joinDate: DateTime.now(),
      lastLogin: DateTime.now(),
      emailVerified: user.emailVerified,
      profileImagePath: user.photoURL,
    );
  }

  // For creating from Firestore document
  factory UserModel.fromFirestore(String id, Map<String, dynamic> data) {
    // Helper to handle both String and Timestamp from Firestore
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      if (value is Timestamp) return value.toDate(); // If using cloud_firestore
      return null;
    }

    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role:
          (data['role']?.toString().toLowerCase() == 'leader' ||
              data['role']?.toString().toLowerCase() == 'admin')
          ? AppConstants.roleLeader
          : AppConstants.roleUser,
      joinDate: parseDateTime(data['joinDate']) ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      profileImagePath: data['profileImagePath'],
      lastLogin: parseDateTime(data['lastLogin']),
      emailVerified: data['emailVerified'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'joinDate': joinDate.toIso8601String(),
      'isActive': isActive,
      'profileImagePath': profileImagePath,
      'lastLogin': lastLogin?.toIso8601String(),
      'emailVerified': emailVerified,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      joinDate: DateTime.parse(json['joinDate']),
      isActive: json['isActive'] ?? true,
      profileImagePath: json['profileImagePath'],
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
      emailVerified: json['emailVerified'] ?? false,
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    DateTime? joinDate,
    bool? isActive,
    String? profileImagePath,
    DateTime? lastLogin,
    bool? emailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      lastLogin: lastLogin ?? this.lastLogin,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
