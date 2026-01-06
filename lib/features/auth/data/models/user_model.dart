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

  @HiveField(5, defaultValue: true)
  final bool isActive;

  @HiveField(6)
  final String? profileImagePath;

  @HiveField(7)
  final DateTime? lastLogin;

  @HiveField(8, defaultValue: false)
  final bool emailVerified;

  @HiveField(9, defaultValue: 'approved')
  final String approvalStatus; // 'pending', 'approved', 'denied'
  @HiveField(10)
  final String? adminMessage; // Message from leader if denied

  @HiveField(11)
  final DateTime? statusUpdatedAt;

  @HiveField(12)
  final Map<String, dynamic>? metadata;

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
    this.approvalStatus = 'approved', // Default 'approved' for guests
    this.adminMessage,
    this.statusUpdatedAt,
    this.metadata,
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

    final String rawRole = data['role']?.toString().toLowerCase() ?? 'guest';
    final String mappedRole = (rawRole == 'leader' || rawRole == 'admin')
        ? AppConstants.roleLeader
        : rawRole;
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: mappedRole,
      joinDate: parseDateTime(data['joinDate']) ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      profileImagePath: data['profileImagePath'],
      lastLogin: parseDateTime(data['lastLogin']),
      emailVerified: data['emailVerified'] ?? false,
      approvalStatus: data['approvalStatus'] ?? 'pending',
      adminMessage: data['adminMessage'],
      statusUpdatedAt: parseDateTime(data['statusUpdatedAt']),
      metadata: data['metadata'] as Map<String, dynamic>?,
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
      'approvalStatus': approvalStatus,
      'adminMessage': adminMessage,
      'statusUpdatedAt': statusUpdatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      joinDate: parseDateTime(json['joinDate']) ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
      profileImagePath: json['profileImagePath'],
      lastLogin: parseDateTime(json['lastLogin']),
      emailVerified: json['emailVerified'] ?? false,
      approvalStatus: json['approvalStatus'] ?? 'approved',
      adminMessage: json['adminMessage'],
      statusUpdatedAt: parseDateTime(json['statusUpdatedAt']),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
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
    String? approvalStatus,
    String? adminMessage,
    DateTime? statusUpdatedAt,
    Map<String, dynamic>? metadata,
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
      approvalStatus: approvalStatus ?? this.approvalStatus,
      adminMessage: adminMessage ?? this.adminMessage,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
