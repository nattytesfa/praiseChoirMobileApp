import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';
import '../../data/chat_repository.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository chatRepository;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _typingSubscription;
  List<MessageModel> _currentMessages = [];
  List<String> _currentTypingUsers = [];

  ChatCubit({ChatRepository? repository})
    : chatRepository = repository ?? ChatRepository(),
      super(ChatInitial());

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    return super.close();
  }

  void loadChats(String userId) async {
    emit(ChatLoading());
    try {
      final chats = await chatRepository.getChatsForUser(userId);
      emit(ChatLoaded(chats));
    } catch (e) {
      emit(ChatError('Failed to load chats'));
    }
  }

  Future<void> joingroupChat(String userId) async {
    emit(ChatLoading());
    try {
      await chatRepository.ensuregroupChatExists();
      const groupChatId = 'general';
      loadMessages(groupChatId);
    } catch (e) {
      emit(ChatError('Failed to join general chat'));
    }
  }

  void loadMessages(String chatId, {bool showLoading = true}) {
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    if (showLoading) emit(ChatLoading());

    _messagesSubscription = chatRepository
        .getMessagesStream(chatId)
        .listen(
          (messages) {
            _currentMessages = messages;
            emit(MessagesLoaded(messages, typingUsers: _currentTypingUsers));
          },
          onError: (error) {
            emit(ChatError('Failed to load messages'));
          },
        );

    _typingSubscription = chatRepository.watchTypingUsers(chatId).listen((
      users,
    ) {
      _currentTypingUsers = users;
      if (state is MessagesLoaded) {
        emit(MessagesLoaded(_currentMessages, typingUsers: users));
      }
    });
  }

  void setTyping(String chatId, String userId, bool isTyping) {
    chatRepository.setTypingStatus(chatId, userId, isTyping);
  }

  void sendTextMessage(
    String chatId,
    String senderId,
    String content, {
    String senderName = '',
    String? senderProfileImage,
    String? replyToId,
  }) async {
    try {
      final message = MessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        senderId: senderId,
        content: content,
        type: MessageType.text,
        timestamp: DateTime.now(),
        senderName: senderName,
        senderProfileImage: senderProfileImage,
        replyToId: replyToId,
      );

      await chatRepository.sendMessage(message);
      // Stream will update UI
    } catch (e) {
      emit(ChatError('Failed to send message'));
    }
  }

  void sendVoiceMessage(
    String chatId,
    String senderId,
    String audioPath, {
    String senderName = '',
    String? senderProfileImage,
    String? replyToId,
  }) async {
    try {
      final message = MessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        senderId: senderId,
        content: 'Voice message',
        type: MessageType.voice,
        timestamp: DateTime.now(),
        attachmentPath: audioPath,
        senderName: senderName,
        senderProfileImage: senderProfileImage,
        replyToId: replyToId,
      );

      await chatRepository.sendMessage(message);
      // Stream will update UI
    } catch (e) {
      emit(ChatError('Failed to send voice message'));
    }
  }

  void createGroupChat(
    String name,
    List<String> memberIds,
    ChatType type,
  ) async {
    try {
      await chatRepository.createGroupChat(name, memberIds, type);
      // Reload chats for all members
      for (final memberId in memberIds) {
        loadChats(memberId);
      }
    } catch (e) {
      emit(ChatError('Failed to create group chat'));
    }
  }

  void editMessage(String messageId, String newContent) async {
    try {
      await chatRepository.editMessage(messageId, newContent);
    } catch (e) {
      emit(ChatError('Failed to edit message'));
    }
  }

  void deleteMessage(String messageId) async {
    try {
      await chatRepository.deleteMessage(messageId);
    } catch (e) {
      emit(ChatError('Failed to delete message'));
    }
  }

  void deleteMessages(List<String> messageIds) async {
    try {
      await chatRepository.deleteMessages(messageIds);
    } catch (e) {
      emit(ChatError('Failed to delete messages'));
    }
  }

  void markMessageAsRead(String messageId, String userId) async {
    try {
      await chatRepository.markMessageAsRead(messageId, userId);
    } catch (e) {
      // Don't emit error for read receipts
    }
  }

  void toggleReaction(String messageId, String userId, String emoji) async {
    try {
      await chatRepository.toggleReaction(messageId, userId, emoji);
    } catch (e) {
      // Don't emit error for reactions
    }
  }

  List<UserModel> getUsers(List<String> userIds) {
    return chatRepository.getUsers(userIds);
  }
}
