import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 20)
class MessageModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String chatId;

  @HiveField(2)
  final String senderId;

  @HiveField(3)
  final String senderName;

  @HiveField(4)
  final String content;

  @HiveField(5)
  final MessageType type;

  @HiveField(6)
  final DateTime timestamp;

  @HiveField(7)
  final MessageStatus status;

  @HiveField(8)
  final String? replyToId;

  @HiveField(9)
  final List<String> readBy;

  @HiveField(10)
  final String? attachmentPath;

  @HiveField(11)
  final Map<String, dynamic>? metadata;

  @HiveField(12, defaultValue: false)
  final bool isEdited;

  @HiveField(13, defaultValue: false)
  final bool isDeleted;

  @HiveField(14)
  final String? senderProfileImage;

  @HiveField(15)
  final Map<String, List<String>>? reactions;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.replyToId,
    this.readBy = const [],
    this.attachmentPath,
    this.metadata,
    this.isEdited = false,
    this.isDeleted = false,
    this.senderProfileImage,
    this.reactions,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(),
      'replyToId': replyToId,
      'readBy': readBy,
      'attachmentPath': attachmentPath,
      'metadata': metadata,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'senderProfileImage': senderProfileImage,
      'reactions': reactions,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      replyToId: json['replyToId'],
      readBy: List<String>.from(json['readBy'] ?? []),
      attachmentPath: json['attachmentPath'],
      metadata: json['metadata'],
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      senderProfileImage: json['senderProfileImage'],
      reactions: (json['reactions'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ),
    );
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    String? replyToId,
    List<String>? readBy,
    String? attachmentPath,
    Map<String, dynamic>? metadata,
    bool? isEdited,
    bool? isDeleted,
    String? senderProfileImage,
    Map<String, List<String>>? reactions,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      readBy: readBy ?? this.readBy,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      metadata: metadata ?? this.metadata,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      senderProfileImage: senderProfileImage ?? this.senderProfileImage,
      reactions: reactions ?? this.reactions,
    );
  }
}

@HiveType(typeId: 21)
class VoiceMessageModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String messageId;

  @HiveField(2)
  final String filePath;

  @HiveField(3)
  final Duration duration;

  @HiveField(4)
  final int fileSize;

  VoiceMessageModel({
    required this.id,
    required this.messageId,
    required this.filePath,
    required this.duration,
    required this.fileSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messageId': messageId,
      'filePath': filePath,
      'duration': duration.inMilliseconds,
      'fileSize': fileSize,
    };
  }

  factory VoiceMessageModel.fromJson(Map<String, dynamic> json) {
    return VoiceMessageModel(
      id: json['id'],
      messageId: json['messageId'],
      filePath: json['filePath'],
      duration: Duration(milliseconds: json['duration']),
      fileSize: json['fileSize'],
    );
  }
}

@HiveType(typeId: 22)
enum MessageType {
  @HiveField(0)
  text,

  @HiveField(1)
  voice,

  @HiveField(2)
  image,

  @HiveField(3)
  file,

  @HiveField(4)
  system,
  @HiveField(5)
  audio,
  song,
}

@HiveType(typeId: 23)
enum MessageStatus {
  @HiveField(0)
  sending,

  @HiveField(1)
  sent,

  @HiveField(2)
  delivered,

  @HiveField(3)
  read,

  @HiveField(4)
  failed,
}
