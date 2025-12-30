// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PollModelAdapter extends TypeAdapter<PollModel> {
  @override
  final int typeId = 12;

  @override
  PollModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PollModel(
      id: fields[0] as String,
      question: fields[1] as String,
      options: (fields[2] as List).cast<PollOption>(),
      createdBy: fields[3] as String,
      createdAt: fields[4] as DateTime,
      expiresAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PollModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.options)
      ..writeByte(3)
      ..write(obj.createdBy)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PollModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PollOptionAdapter extends TypeAdapter<PollOption> {
  @override
  final int typeId = 13;

  @override
  PollOption read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PollOption(
      id: fields[0] as String,
      text: fields[1] as String,
      voterIds: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PollOption obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.voterIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PollOptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
