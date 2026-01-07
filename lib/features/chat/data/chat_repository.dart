import 'dart:async';
import 'package:hive/hive.dart';
import '../../auth/data/models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import 'models/chat_model.dart';
import 'models/message_model.dart';

class ChatRepository {
  late Box<ChatModel> _chatBox;
  late Box<MessageModel> _messageBox;
  late Box<UserModel> _userBox;

  ChatRepository() {
    _chatBox = Hive.box<ChatModel>(HiveBoxes.chat);
    _messageBox = Hive.box<MessageModel>('messages');
    _userBox = Hive.box<UserModel>('users');
  }

  List<UserModel> getUsers(List<String> userIds) {
    return _userBox.values.where((user) => userIds.contains(user.id)).toList();
  }

  Future<List<ChatModel>> getChatsForUser(String userId) async {
    final allChats = _chatBox.values.toList();
    return allChats.where((chat) => chat.memberIds.contains(userId)).toList();
  }

  Future<List<MessageModel>> getMessagesForChat(
    String chatId,
    String userId,
  ) async {
    final allMessages = _messageBox.values.toList();
    return allMessages
        .where((message) {
          final deletedBy =
              (message.metadata?['deletedBy'] as List?)?.cast<String>() ?? [];
          return message.chatId == chatId &&
              !deletedBy.contains(userId) &&
              !message.isDeleted;
        })
        .toList()
        .reversed
        .toList(); // Reverse to show latest first
  }

  Stream<List<MessageModel>> getMessagesStream(
    String chatId,
    String userId,
  ) async* {
    // Yield initial messages
    yield await getMessagesForChat(chatId, userId);

    // Yield updates
    yield* _messageBox.watch().map((event) {
      final allMessages = _messageBox.values.toList();
      return allMessages
          .where((message) {
            final deletedBy =
                (message.metadata?['deletedBy'] as List?)?.cast<String>() ?? [];
            return message.chatId == chatId &&
                !deletedBy.contains(userId) &&
                !message.isDeleted;
          })
          .toList()
          .reversed
          .toList();
    });
  }

  Future<void> sendMessage(MessageModel message) async {
    await _messageBox.add(message);

    // Update last message in chat
    try {
      final chat = _chatBox.values.firstWhere((c) => c.id == message.chatId);
      final updatedChat = ChatModel(
        id: chat.id,
        name: chat.name,
        type: chat.type,
        memberIds: chat.memberIds,
        lastMessage: message,
        createdAt: chat.createdAt,
      );

      final index = _chatBox.values.toList().indexWhere((c) => c.id == chat.id);
      if (index != -1) {
        await _chatBox.putAt(index, updatedChat);
      }
    } catch (e) {
      // Chat not found or other error updating chat model
      // We ignore this for now as the message is already sent
    }
  }

  Future<void> ensuregroupChatExists() async {
    const groupChatId = 'general';
    final exists = _chatBox.values.any((c) => c.id == groupChatId);

    if (!exists) {
      final chat = ChatModel(
        id: groupChatId,
        name: 'General Chat',
        type: ChatType.group,
        memberIds: [], // Open to everyone
        createdAt: DateTime.now(),
      );
      await _chatBox.add(chat);
    }
  }

  Future<void> createGroupChat(
    String name,
    List<String> memberIds,
    ChatType type,
  ) async {
    final chat = ChatModel(
      id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      memberIds: memberIds,
      createdAt: DateTime.now(),
    );
    await _chatBox.add(chat);
  }

  Future<void> editMessage(String messageId, String newContent) async {
    final message = _messageBox.values.firstWhere((m) => m.id == messageId);

    final metadata = Map<String, dynamic>.from(message.metadata ?? {});
    metadata['previousContent'] = message.content;
    metadata['editedAt'] = DateTime.now().toIso8601String();

    final updatedMessage = message.copyWith(
      content: newContent,
      isEdited: true,
      metadata: metadata,
    );

    final index = _messageBox.values.toList().indexWhere(
      (m) => m.id == messageId,
    );
    if (index != -1) {
      await _messageBox.putAt(index, updatedMessage);
    }
  }

  Future<void> deleteMessage(
    String messageId,
    String currentUserId, {
    bool isAdmin = false,
  }) async {
    final message = _messageBox.values.firstWhere((m) => m.id == messageId);
    final index = _messageBox.values.toList().indexWhere(
      (m) => m.id == messageId,
    );

    if (index != -1) {
      if (message.senderId == currentUserId || isAdmin) {
        // Soft delete for everyone
        final metadata = Map<String, dynamic>.from(message.metadata ?? {});
        metadata['deletedAt'] = DateTime.now().toIso8601String();

        final updatedMessage = message.copyWith(
          isDeleted: true,
          metadata: metadata,
        );
        await _messageBox.putAt(index, updatedMessage);
      } else {
        // Delete only for me if it's someone else's message
        final metadata = Map<String, dynamic>.from(message.metadata ?? {});
        final deletedBy = List<String>.from(metadata['deletedBy'] ?? []);

        if (!deletedBy.contains(currentUserId)) {
          deletedBy.add(currentUserId);
          metadata['deletedBy'] = deletedBy;

          final updatedMessage = message.copyWith(metadata: metadata);
          await _messageBox.putAt(index, updatedMessage);
        }
      }
    }
  }

  Future<void> deleteMessages(
    List<String> messageIds,
    String currentUserId, {
    bool isAdmin = false,
  }) async {
    for (final id in messageIds) {
      await deleteMessage(id, currentUserId, isAdmin: isAdmin);
    }
  }

  Future<void> clearChatHistory(String chatId, String userId) async {
    final messages = await getMessagesForChat(chatId, userId);
    final messageIds = messages.map((m) => m.id).toList();
    await deleteMessages(messageIds, userId);
  }

  Future<void> markMessageAsRead(String messageId, String userId) async {
    final message = _messageBox.values.firstWhere((m) => m.id == messageId);

    if (!message.readBy.contains(userId)) {
      final updatedReadBy = List<String>.from(message.readBy)..add(userId);
      final updatedMessage = message.copyWith(
        readBy: updatedReadBy,
        status: MessageStatus.read,
      );

      final index = _messageBox.values.toList().indexWhere(
        (m) => m.id == messageId,
      );
      if (index != -1) {
        await _messageBox.putAt(index, updatedMessage);
      }
    }
  }

  Future<void> toggleReaction(
    String messageId,
    String userId,
    String emoji,
  ) async {
    final message = _messageBox.values.firstWhere((m) => m.id == messageId);
    final reactions = Map<String, List<String>>.from(message.reactions ?? {});

    if (reactions.containsKey(emoji)) {
      final users = List<String>.from(reactions[emoji]!);
      if (users.contains(userId)) {
        users.remove(userId);
        if (users.isEmpty) {
          reactions.remove(emoji);
        } else {
          reactions[emoji] = users;
        }
      } else {
        users.add(userId);
        reactions[emoji] = users;
      }
    } else {
      reactions[emoji] = [userId];
    }

    final updatedMessage = message.copyWith(reactions: reactions);
    final index = _messageBox.values.toList().indexWhere(
      (m) => m.id == messageId,
    );
    if (index != -1) {
      await _messageBox.putAt(index, updatedMessage);
    }
  }

  Future<List<MessageModel>> getUnreadMessages(String userId) async {
    final userChats = await getChatsForUser(userId);
    final allMessages = _messageBox.values.toList();

    return allMessages.where((message) {
      final isInUserChat = userChats.any((chat) => chat.id == message.chatId);
      return isInUserChat &&
          !message.readBy.contains(userId) &&
          message.senderId != userId;
    }).toList();
  }

  Stream<int> watchUnreadCount(String userId) async* {
    // Initial count
    final initialMessages = await getUnreadMessages(userId);
    yield initialMessages.length;

    // Watch for changes
    yield* _messageBox.watch().asyncMap((_) async {
      final messages = await getUnreadMessages(userId);
      return messages.length;
    });
  }

  // Typing status management
  final _typingController =
      StreamController<Map<String, Set<String>>>.broadcast();
  final Map<String, Set<String>> _typingStatus = {};

  Stream<List<String>> watchTypingUsers(String chatId) {
    return _typingController.stream.map((status) {
      return status[chatId]?.toList() ?? [];
    });
  }

  void setTypingStatus(String chatId, String userId, bool isTyping) {
    if (!_typingStatus.containsKey(chatId)) {
      _typingStatus[chatId] = {};
    }

    if (isTyping) {
      _typingStatus[chatId]!.add(userId);
    } else {
      _typingStatus[chatId]!.remove(userId);
    }

    _typingController.add(_typingStatus);
  }
}
