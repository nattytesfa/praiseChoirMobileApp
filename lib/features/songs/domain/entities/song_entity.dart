import 'package:equatable/equatable.dart';

class SongEntity extends Equatable {
  final String id;
  final String title;
  final String lyrics;
  final String language;
  final List<String> tags;
  final String? audioPath;
  final String addedBy;
  final DateTime dateAdded;
  final DateTime? lastPerformed;
  final DateTime? lastPracticed;
  final int performanceCount;
  final List<SongVersionEntity> versions;
  final List<RecordingNoteEntity> recordingNotes;

  const SongEntity({
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

  // Factory method to create from model
  factory SongEntity.fromModel(dynamic model) {
    return SongEntity(
      id: model.id,
      title: model.title,
      lyrics: model.lyrics,
      language: model.language,
      tags: List<String>.from(model.tags),
      audioPath: model.audioPath,
      addedBy: model.addedBy,
      dateAdded: model.dateAdded,
      lastPerformed: model.lastPerformed,
      lastPracticed: model.lastPracticed,
      performanceCount: model.performanceCount,
      versions: (model.versions as List)
          .map((v) => SongVersionEntity.fromModel(v))
          .toList(),
      recordingNotes: (model.recordingNotes as List)
          .map((n) => RecordingNoteEntity.fromModel(n))
          .toList(),
    );
  }

  // Convert to model (for persistence)
  Map<String, dynamic> toModel() {
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
      'versions': versions.map((v) => v.toModel()).toList(),
      'recordingNotes': recordingNotes.map((n) => n.toModel()).toList(),
    };
  }

  // Helper methods
  bool get hasAudio => audioPath != null && audioPath!.isNotEmpty;
  bool get isFavorite => tags.contains('favorite');
  bool get isNew => tags.contains('new');
  bool get isThisRound => tags.contains('this_round');

  bool get hasVersions => versions.isNotEmpty;
  bool get hasRecordingNotes => recordingNotes.isNotEmpty;

  DateTime get lastUsed => lastPerformed ?? lastPracticed ?? dateAdded;

  bool get isNeglected {
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    return lastUsed.isBefore(threeMonthsAgo);
  }

  SongEntity copyWith({
    String? id,
    String? title,
    String? lyrics,
    String? language,
    List<String>? tags,
    String? audioPath,
    String? addedBy,
    DateTime? dateAdded,
    DateTime? lastPerformed,
    DateTime? lastPracticed,
    int? performanceCount,
    List<SongVersionEntity>? versions,
    List<RecordingNoteEntity>? recordingNotes,
  }) {
    return SongEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      lyrics: lyrics ?? this.lyrics,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      audioPath: audioPath ?? this.audioPath,
      addedBy: addedBy ?? this.addedBy,
      dateAdded: dateAdded ?? this.dateAdded,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      performanceCount: performanceCount ?? this.performanceCount,
      versions: versions ?? this.versions,
      recordingNotes: recordingNotes ?? this.recordingNotes,
    );
  }

  SongEntity markAsPerformed() {
    return copyWith(
      lastPerformed: DateTime.now(),
      performanceCount: performanceCount + 1,
    );
  }

  SongEntity markAsPracticed() {
    return copyWith(lastPracticed: DateTime.now());
  }

  SongEntity addTag(String tag) {
    final newTags = List<String>.from(tags)..add(tag);
    return copyWith(tags: newTags);
  }

  SongEntity removeTag(String tag) {
    final newTags = List<String>.from(tags)..remove(tag);
    return copyWith(tags: newTags);
  }

  SongEntity toggleFavorite() {
    if (isFavorite) {
      return removeTag('favorite');
    } else {
      return addTag('favorite');
    }
  }

  @override
  List<Object?> get props => [
    id,
    title,
    lyrics,
    language,
    tags,
    audioPath,
    addedBy,
    dateAdded,
    lastPerformed,
    lastPracticed,
    performanceCount,
    versions,
    recordingNotes,
  ];
}

class SongVersionEntity extends Equatable {
  final String id;
  final String name;
  final String? audioPath;
  final String notes;
  final DateTime createdAt;
  final String createdBy;
  final Map<String, dynamic>? metadata;

  const SongVersionEntity({
    required this.id,
    required this.name,
    this.audioPath,
    required this.notes,
    required this.createdAt,
    required this.createdBy,
    this.metadata,
  });

  factory SongVersionEntity.fromModel(dynamic model) {
    return SongVersionEntity(
      id: model.id,
      name: model.name,
      audioPath: model.audioPath,
      notes: model.notes,
      createdAt: model.createdAt,
      createdBy: model.createdBy,
      metadata: model.metadata != null
          ? Map<String, dynamic>.from(model.metadata!)
          : null,
    );
  }

  Map<String, dynamic> toModel() {
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

  bool get hasAudio => audioPath != null && audioPath!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    audioPath,
    notes,
    createdAt,
    createdBy,
    metadata,
  ];
}

class RecordingNoteEntity extends Equatable {
  final String id;
  final String note;
  final String addedBy;
  final DateTime createdAt;
  final String? timestamp;

  const RecordingNoteEntity({
    required this.id,
    required this.note,
    required this.addedBy,
    required this.createdAt,
    this.timestamp,
  });

  factory RecordingNoteEntity.fromModel(dynamic model) {
    return RecordingNoteEntity(
      id: model.id,
      note: model.note,
      addedBy: model.addedBy,
      createdAt: model.createdAt,
      timestamp: model.timestamp,
    );
  }

  Map<String, dynamic> toModel() {
    return {
      'id': id,
      'note': note,
      'addedBy': addedBy,
      'createdAt': createdAt.toIso8601String(),
      'timestamp': timestamp,
    };
  }

  bool get hasTimestamp => timestamp != null && timestamp!.isNotEmpty;

  @override
  List<Object?> get props => [id, note, addedBy, createdAt, timestamp];
}
