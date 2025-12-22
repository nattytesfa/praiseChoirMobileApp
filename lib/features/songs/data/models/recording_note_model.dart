import 'package:hive/hive.dart';

part 'recording_note_model.g.dart';

@HiveType(typeId: 3)
class RecordingNote {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String note;

  @HiveField(2)
  final String addedBy;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String? timestamp; // Optional: "0:30" for note at specific time

  RecordingNote({
    required this.id,
    required this.note,
    required this.addedBy,
    required this.createdAt,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'addedBy': addedBy,
      'createdAt': createdAt.toIso8601String(),
      'timestamp': timestamp,
    };
  }

  factory RecordingNote.fromJson(Map<String, dynamic> json) {
    return RecordingNote(
      id: json['id'],
      note: json['note'],
      addedBy: json['addedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      timestamp: json['timestamp'],
    );
  }

  RecordingNote copyWith({
    String? id,
    String? note,
    String? addedBy,
    DateTime? createdAt,
    String? timestamp,
  }) {
    return RecordingNote(
      id: id ?? this.id,
      note: note ?? this.note,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Helper methods
  bool get hasTimestamp => timestamp != null && timestamp!.isNotEmpty;

  String get displayTime {
    if (timestamp == null) return 'General Note';
    return 'At $timestamp';
  }

  String get abbreviatedNote {
    if (note.length <= 50) return note;
    return '${note.substring(0, 50)}...';
  }
}
