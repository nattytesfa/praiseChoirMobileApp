import 'package:hive/hive.dart';

part 'song_version_model.g.dart';

@HiveType(typeId: 2)
class SongVersion {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? audioPath;

  @HiveField(3)
  final String notes;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String createdBy;

  @HiveField(6)
  final Map<String, dynamic>? metadata; // Tempo, key, etc.

  SongVersion({
    required this.id,
    required this.name,
    this.audioPath,
    this.notes = '',
    required this.createdAt,
    required this.createdBy,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'audioPath': audioPath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'metadata': metadata,
    };
  }

  factory SongVersion.fromJson(Map<String, dynamic> json) {
    return SongVersion(
      id: json['id'],
      name: json['name'],
      audioPath: json['audioPath'],
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      metadata: json['metadata'],
    );
  }

  SongVersion copyWith({
    String? id,
    String? name,
    String? audioPath,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
    Map<String, dynamic>? metadata,
  }) {
    return SongVersion(
      id: id ?? this.id,
      name: name ?? this.name,
      audioPath: audioPath ?? this.audioPath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  bool get hasAudio => audioPath != null && audioPath!.isNotEmpty;

  String get displayName {
    if (name.toLowerCase() == 'original') return 'Original';
    if (name.toLowerCase() == 'traditional') return 'Traditional';
    if (name.toLowerCase() == 'modern') return 'Modern';
    return name;
  }

  String? get tempo => metadata?['tempo']?.toString();
  String? get key => metadata?['key']?.toString();
  String? get arrangement => metadata?['arrangement']?.toString();

  Duration? get duration {
    final durationMs = metadata?['durationMs'] as int?;
    return durationMs != null ? Duration(milliseconds: durationMs) : null;
  }

  set duration(Duration? value) {
    metadata?['durationMs'] = value?.inMilliseconds;
  }
}
