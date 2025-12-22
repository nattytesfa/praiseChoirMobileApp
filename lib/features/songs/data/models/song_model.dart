import 'package:hive/hive.dart';

part 'song_model.g.dart';

@HiveType(typeId: 1)
class SongModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String lyrics;

  @HiveField(3)
  final String language; // 'kembatigna' or 'amharic'

  @HiveField(4)
  final List<String> tags; // ['old', 'new', 'favorite', 'this_round']

  @HiveField(5)
  final String? audioPath;

  @HiveField(6)
  final String addedBy;

  @HiveField(7)
  final DateTime dateAdded;

  @HiveField(8)
  final DateTime? lastPerformed;

  @HiveField(9)
  final DateTime? lastPracticed;

  @HiveField(10)
  final int performanceCount;

  @HiveField(11)
  final List<SongVersion> versions;

  @HiveField(12)
  final List<RecordingNote> recordingNotes;

  SongModel({
    required this.id,
    required this.title,
    required this.lyrics,
    required this.language,
    required this.tags,
    this.audioPath,
    required this.addedBy,
    required this.dateAdded,
    this.lastPerformed,
    this.lastPracticed,
    this.performanceCount = 0,
    this.versions = const [],
    this.recordingNotes = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lyrics': lyrics,
      'language': language,
      'tags': tags,
      'audioPath': audioPath,
      'addedBy': addedBy,
      'dateAdded': dateAdded.toIso8601String(),
      'lastPerformed': lastPerformed?.toIso8601String(),
      'lastPracticed': lastPracticed?.toIso8601String(),
      'performanceCount': performanceCount,
      'versions': versions.map((v) => v.toJson()).toList(),
      'recordingNotes': recordingNotes.map((n) => n.toJson()).toList(),
    };
  }

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'],
      title: json['title'],
      lyrics: json['lyrics'],
      language: json['language'],
      tags: List<String>.from(json['tags']),
      audioPath: json['audioPath'],
      addedBy: json['addedBy'],
      dateAdded: DateTime.parse(json['dateAdded']),
      lastPerformed: json['lastPerformed'] != null
          ? DateTime.parse(json['lastPerformed'])
          : null,
      lastPracticed: json['lastPracticed'] != null
          ? DateTime.parse(json['lastPracticed'])
          : null,
      performanceCount: json['performanceCount'] ?? 0,
      versions: (json['versions'] as List? ?? [])
          .map((v) => SongVersion.fromJson(v))
          .toList(),
      recordingNotes: (json['recordingNotes'] as List? ?? [])
          .map((n) => RecordingNote.fromJson(n))
          .toList(),
    );
  }

  SongModel copyWith({
    String? title,
    String? lyrics,
    String? language,
    List<String>? tags,
    String? audioPath,
    DateTime? lastPerformed,
    DateTime? lastPracticed,
    int? performanceCount,
    List<SongVersion>? versions,
    List<RecordingNote>? recordingNotes,
  }) {
    return SongModel(
      id: id,
      title: title ?? this.title,
      lyrics: lyrics ?? this.lyrics,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      audioPath: audioPath ?? this.audioPath,
      addedBy: addedBy,
      dateAdded: dateAdded,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      performanceCount: performanceCount ?? this.performanceCount,
      versions: versions ?? this.versions,
      recordingNotes: recordingNotes ?? this.recordingNotes,
    );
  }
}

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

  SongVersion({
    required this.id,
    required this.name,
    this.audioPath,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'audioPath': audioPath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SongVersion.fromJson(Map<String, dynamic> json) {
    return SongVersion(
      id: json['id'],
      name: json['name'],
      audioPath: json['audioPath'],
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

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

  RecordingNote({
    required this.id,
    required this.note,
    required this.addedBy,
    required this.createdAt, String? timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'addedBy': addedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RecordingNote.fromJson(Map<String, dynamic> json) {
    return RecordingNote(
      id: json['id'],
      note: json['note'],
      addedBy: json['addedBy'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
