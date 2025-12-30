// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventTypeAdapter extends TypeAdapter<EventType> {
  @override
  final int typeId = 14;

  @override
  EventType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EventType.rehearsal;
      case 1:
        return EventType.performance;
      case 2:
        return EventType.meeting;
      case 3:
        return EventType.social;
      default:
        return EventType.rehearsal;
    }
  }

  @override
  void write(BinaryWriter writer, EventType obj) {
    switch (obj) {
      case EventType.rehearsal:
        writer.writeByte(0);
        break;
      case EventType.performance:
        writer.writeByte(1);
        break;
      case EventType.meeting:
        writer.writeByte(2);
        break;
      case EventType.social:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
