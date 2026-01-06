// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      email: fields[1] as String,
      name: fields[2] as String,
      role: fields[3] as String,
      joinDate: fields[4] as DateTime,
      isActive: fields[5] == null ? true : fields[5] as bool,
      profileImagePath: fields[6] as String?,
      lastLogin: fields[7] as DateTime?,
      emailVerified: fields[8] == null ? false : fields[8] as bool,
      approvalStatus: fields[9] == null ? 'approved' : fields[9] as String,
      adminMessage: fields[10] as String?,
      statusUpdatedAt: fields[11] as DateTime?,
      metadata: (fields[12] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.joinDate)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.profileImagePath)
      ..writeByte(7)
      ..write(obj.lastLogin)
      ..writeByte(8)
      ..write(obj.emailVerified)
      ..writeByte(9)
      ..write(obj.approvalStatus)
      ..writeByte(10)
      ..write(obj.adminMessage)
      ..writeByte(11)
      ..write(obj.statusUpdatedAt)
      ..writeByte(12)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
