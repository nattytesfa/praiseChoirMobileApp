// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stats_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdminStatsModelAdapter extends TypeAdapter<AdminStatsModel> {
  @override
  final int typeId = 15;

  @override
  AdminStatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdminStatsModel(
      totalMembers: fields[0] as int,
      activeMembers: fields[1] as int,
      totalSongs: fields[2] as int,
      songsWithAudio: fields[3] as int,
      monthlyCollectionRate: fields[4] as double,
      unreadMessages: fields[5] as int,
      upcomingEvents: fields[6] as int,
      lastUpdated: fields[7] as DateTime,
      adminCount: fields[8] as int,
      lastSynced: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AdminStatsModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.totalMembers)
      ..writeByte(1)
      ..write(obj.activeMembers)
      ..writeByte(2)
      ..write(obj.totalSongs)
      ..writeByte(3)
      ..write(obj.songsWithAudio)
      ..writeByte(4)
      ..write(obj.monthlyCollectionRate)
      ..writeByte(5)
      ..write(obj.unreadMessages)
      ..writeByte(6)
      ..write(obj.upcomingEvents)
      ..writeByte(7)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminStatsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
