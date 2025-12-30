import 'package:equatable/equatable.dart';

import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatModel> chats;

  const ChatLoaded(this.chats);

  @override
  List<Object> get props => [chats];
}

class MessagesLoaded extends ChatState {
  final List<MessageModel> messages;
  final List<String> typingUsers;

  const MessagesLoaded(this.messages, {this.typingUsers = const []});

  @override
  List<Object> get props => [messages, typingUsers];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

class MessageSent extends ChatState {
  final MessageModel message;

  const MessageSent(this.message);

  @override
  List<Object> get props => [message];
}

class RecordingState extends ChatState {
  final bool isRecording;
  final Duration? duration;

  const RecordingState({required this.isRecording, this.duration});

  @override
  List<Object> get props => [isRecording, duration ?? Duration.zero];
}
