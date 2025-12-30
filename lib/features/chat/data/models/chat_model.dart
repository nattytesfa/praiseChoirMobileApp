import 'package:hive/hive.dart';
import 'message_model.dart';

part 'chat_model.g.dart';

@HiveType(typeId: 6)
class ChatModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final ChatType type;

  @HiveField(3)
  final List<String> memberIds;

  @HiveField(4)
  final MessageModel? lastMessage;

  @HiveField(5)
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.name,
    required this.type,
    required this.memberIds,
    this.lastMessage,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'memberIds': memberIds,
      'lastMessage': lastMessage?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      name: json['name'],
      type: ChatType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ChatType.group,
      ),
      memberIds: List<String>.from(json['memberIds']),
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

@HiveType(typeId: 8)
enum ChatType {
  @HiveField(0)
  group,

  @HiveField(1)
  private,

  @HiveField(2)
  announcement,
}
