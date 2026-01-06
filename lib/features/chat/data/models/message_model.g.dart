// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 20;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      chatId: fields[1] as String,
      senderId: fields[2] as String,
      senderName: fields[3] as String,
      content: fields[4] as String,
      type: fields[5] as MessageType,
      timestamp: fields[6] as DateTime,
      status: fields[7] as MessageStatus,
      replyToId: fields[8] as String?,
      readBy: (fields[9] as List).cast<String>(),
      attachmentPath: fields[10] as String?,
      metadata: (fields[11] as Map?)?.cast<String, dynamic>(),
      isEdited: fields[12] == null ? false : fields[12] as bool,
      isDeleted: fields[13] == null ? false : fields[13] as bool,
      senderProfileImage: fields[14] as String?,
      reactions: (fields[15] as Map?)?.map(
        (dynamic k, dynamic v) =>
            MapEntry(k as String, (v as List).cast<String>()),
      ),
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.chatId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.senderName)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.replyToId)
      ..writeByte(9)
      ..write(obj.readBy)
      ..writeByte(10)
      ..write(obj.attachmentPath)
      ..writeByte(11)
      ..write(obj.metadata)
      ..writeByte(12)
      ..write(obj.isEdited)
      ..writeByte(13)
      ..write(obj.isDeleted)
      ..writeByte(14)
      ..write(obj.senderProfileImage)
      ..writeByte(15)
      ..write(obj.reactions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VoiceMessageModelAdapter extends TypeAdapter<VoiceMessageModel> {
  @override
  final int typeId = 21;

  @override
  VoiceMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VoiceMessageModel(
      id: fields[0] as String,
      messageId: fields[1] as String,
      filePath: fields[2] as String,
      duration: fields[3] as Duration,
      fileSize: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, VoiceMessageModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.messageId)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.fileSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 22;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.voice;
      case 2:
        return MessageType.image;
      case 3:
        return MessageType.file;
      case 4:
        return MessageType.system;
      case 5:
        return MessageType.audio;
      default:
        return MessageType.text;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    switch (obj) {
      case MessageType.text:
        writer.writeByte(0);
        break;
      case MessageType.voice:
        writer.writeByte(1);
        break;
      case MessageType.image:
        writer.writeByte(2);
        break;
      case MessageType.file:
        writer.writeByte(3);
        break;
      case MessageType.system:
        writer.writeByte(4);
        break;
      case MessageType.audio:
        writer.writeByte(5);
        break;
      case MessageType.song:
        throw UnimplementedError();
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageStatusAdapter extends TypeAdapter<MessageStatus> {
  @override
  final int typeId = 23;

  @override
  MessageStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageStatus.sending;
      case 1:
        return MessageStatus.sent;
      case 2:
        return MessageStatus.delivered;
      case 3:
        return MessageStatus.read;
      case 4:
        return MessageStatus.failed;
      default:
        return MessageStatus.sending;
    }
  }

  @override
  void write(BinaryWriter writer, MessageStatus obj) {
    switch (obj) {
      case MessageStatus.sending:
        writer.writeByte(0);
        break;
      case MessageStatus.sent:
        writer.writeByte(1);
        break;
      case MessageStatus.delivered:
        writer.writeByte(2);
        break;
      case MessageStatus.read:
        writer.writeByte(3);
        break;
      case MessageStatus.failed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
