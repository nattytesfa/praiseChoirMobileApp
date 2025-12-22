// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      timestamp: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecordingNote obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.note)
      ..writeByte(2)
      ..write(obj.addedBy)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.timestamp);
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
