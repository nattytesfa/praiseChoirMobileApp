// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnnouncementModelAdapter extends TypeAdapter<AnnouncementModel> {
  @override
  final int typeId = 11;

  @override
  AnnouncementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnnouncementModel(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      createdBy: fields[3] as String,
      createdAt: fields[4] as DateTime,
      isUrgent: fields[5] as bool,
      authorName: fields[6] as String?,
      expiresAt: fields[7] as DateTime?,
      targetRoles: (fields[8] as List).cast<String>(),
      priority: fields[9] as int,
      readBy: (fields[10] as List).cast<String>(),
      isEdited: fields[11] == null ? false : fields[11] as bool,
      isDeleted: fields[12] == null ? false : fields[12] as bool,
      metadata: (fields[13] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AnnouncementModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.createdBy)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isUrgent)
      ..writeByte(6)
      ..write(obj.authorName)
      ..writeByte(7)
      ..write(obj.expiresAt)
      ..writeByte(8)
      ..write(obj.targetRoles)
      ..writeByte(9)
      ..write(obj.priority)
      ..writeByte(10)
      ..write(obj.readBy)
      ..writeByte(11)
      ..write(obj.isEdited)
      ..writeByte(12)
      ..write(obj.isDeleted)
      ..writeByte(13)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
