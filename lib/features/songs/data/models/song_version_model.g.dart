// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_version_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      createdBy: fields[5] as String,
      metadata: (fields[6] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SongVersion obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.audioPath)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.createdBy)
      ..writeByte(6)
      ..write(obj.metadata);
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
