// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongModelAdapter extends TypeAdapter<SongModel> {
  @override
  final int typeId = 1;

  @override
  SongModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongModel(
      id: fields[0] as String,
      title: fields[1] as String,
      lyrics: fields[2] as String,
      language: fields[3] as String,
      tags: (fields[4] as List).cast<String>(),
      audioPath: fields[5] as String?,
      addedBy: fields[6] as String,
      dateAdded: fields[7] as DateTime,
      lastPerformed: fields[8] as DateTime?,
      lastPracticed: fields[9] as DateTime?,
      performanceCount: fields[10] as int,
      versions: (fields[11] as List).cast<SongVersion>(),
      recordingNotes: (fields[12] as List).cast<RecordingNote>(),
      songNumber: fields[13] as String?,
      likeCount: fields[14] as int? ?? 0,
      practiceCount: fields[15] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, SongModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.lyrics)
      ..writeByte(3)
      ..write(obj.language)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.audioPath)
      ..writeByte(6)
      ..write(obj.addedBy)
      ..writeByte(7)
      ..write(obj.dateAdded)
      ..writeByte(8)
      ..write(obj.lastPerformed)
      ..writeByte(9)
      ..write(obj.lastPracticed)
      ..writeByte(10)
      ..write(obj.performanceCount)
      ..writeByte(11)
      ..write(obj.versions)
      ..writeByte(12)
      ..write(obj.recordingNotes)
      ..writeByte(13)
      ..write(obj.songNumber)
      ..writeByte(14)
      ..write(obj.likeCount)
      ..writeByte(15)
      ..write(obj.practiceCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SongVersionAdapter extends TypeAdapter<SongVersion> {
  @override
  final int typeId = 2;

  @override
  SongVersion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongVersion(
      id: fields[0] as String,
      name: fields[1] as String,
      audioPath: fields[2] as String?,
      notes: fields[3] as String,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SongVersion obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.audioPath)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongVersionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecordingNoteAdapter extends TypeAdapter<RecordingNote> {
  @override
  final int typeId = 3;

  @override
  RecordingNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecordingNote(
      id: fields[0] as String,
      note: fields[1] as String,
      addedBy: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RecordingNote obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.note)
      ..writeByte(2)
      ..write(obj.addedBy)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
