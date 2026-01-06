import 'package:hive/hive.dart';

part 'announcement_model.g.dart';

@HiveType(typeId: 11)
class AnnouncementModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String createdBy;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final bool isUrgent;

  @HiveField(6)
  final String? authorName;

  @HiveField(7)
  final DateTime? expiresAt;

  @HiveField(8)
  final List<String> targetRoles;

  @HiveField(9)
  final int priority;

  @HiveField(10)
  final List<String> readBy;

  @HiveField(11, defaultValue: false)
  final bool isEdited;

  @HiveField(12, defaultValue: false)
  final bool isDeleted;

  @HiveField(13)
  final Map<String, dynamic>? metadata;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdBy,
    required this.createdAt,
    this.isUrgent = false,
    this.authorName,
    this.expiresAt,
    this.targetRoles = const ['member'],
    this.priority = 1,
    this.readBy = const [],
    this.isEdited = false,
    this.isDeleted = false,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isUrgent': isUrgent,
      'authorName': authorName,
      'expiresAt': expiresAt?.toIso8601String(),
      'targetRoles': targetRoles,
      'priority': priority,
      'readBy': readBy,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'metadata': metadata,
    };
  }

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      isUrgent: json['isUrgent'] ?? false,
      authorName: json['authorName'],
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      targetRoles: List<String>.from(json['targetRoles'] ?? ['member']),
      priority: json['priority'] ?? 1,
      readBy: List<String>.from(json['readBy'] ?? []),
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      metadata: json['metadata'],
    );
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    String? createdBy,
    DateTime? createdAt,
    bool? isUrgent,
    String? authorName,
    DateTime? expiresAt,
    List<String>? targetRoles,
    int? priority,
    List<String>? readBy,
    bool? isEdited,
    bool? isDeleted,
    Map<String, dynamic>? metadata,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isUrgent: isUrgent ?? this.isUrgent,
      authorName: authorName ?? this.authorName,
      expiresAt: expiresAt ?? this.expiresAt,
      targetRoles: targetRoles ?? this.targetRoles,
      priority: priority ?? this.priority,
      readBy: readBy ?? this.readBy,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isHighPriority => priority >= 4;
}
