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
    );
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isHighPriority => priority >= 4;
}
