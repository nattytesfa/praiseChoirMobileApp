import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'song_model.g.dart';

@HiveType(typeId: 1)
class SongModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String lyrics;

  @HiveField(3)
  final String language; // 'kembatgna' or 'amharic'

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

  @HiveField(13)
  final String? songNumber;

  @HiveField(14)
  final int likeCount;

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
    this.songNumber,
    this.likeCount = 0,
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
      'songNumber': songNumber,
      'likeCount': likeCount,
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    } else if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    } else if (value is DateTime) {
      return value;
    }
    return null;
  }

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      lyrics: json['lyrics']?.toString() ?? '',
      language: json['language']?.toString() ?? 'en',
      tags: json['tags'] != null
          ? (json['tags'] as List).map((e) => e.toString()).toList()
          : [],
      audioPath: json['audioPath']?.toString(),
      addedBy: json['addedBy']?.toString() ?? 'Unknown',
      songNumber: json['songNumber']?.toString(),
      dateAdded: _parseDate(json['dateAdded']),
      lastPerformed: _parseNullableDate(json['lastPerformed']),
      lastPracticed: _parseNullableDate(json['lastPracticed']),
      performanceCount: json['performanceCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      versions: json['versions'] != null
          ? (json['versions'] as List)
                .whereType<Map>()
                .map((v) => SongVersion.fromJson(Map<String, dynamic>.from(v)))
                .toList()
          : [],
      recordingNotes: json['recordingNotes'] != null
          ? (json['recordingNotes'] as List)
                .whereType<Map>()
                .map(
                  (n) => RecordingNote.fromJson(Map<String, dynamic>.from(n)),
                )
                .toList()
          : [],
    );
  }

  SongModel copyWith({
    String? title,
    String? lyrics,
    String? language,
    List<String>? tags,
    String? audioPath,
    String? songNumber,
    DateTime? lastPerformed,
    DateTime? lastPracticed,
    int? performanceCount,
    List<SongVersion>? versions,
    List<RecordingNote>? recordingNotes,
    int? likeCount,
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
      songNumber: songNumber ?? this.songNumber,
      likeCount: likeCount ?? this.likeCount,
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
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      audioPath: json['audioPath']?.toString(),
      notes: json['notes']?.toString() ?? '',
      createdAt: SongModel._parseDate(json['createdAt']),
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
    required this.createdAt,
    String? timestamp,
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
      id: json['id']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      addedBy: json['addedBy']?.toString() ?? 'Unknown',
      createdAt: SongModel._parseDate(json['createdAt']),
    );
  }
}
