import 'package:flutter/material.dart';
import 'package:praise_choir_app/features/chat/presentation/screens/chat_list_screen.dart';
import 'data/models/chat_model.dart';
import 'presentation/screens/group_chat_screen.dart';
import 'presentation/screens/voice_message_screen.dart';

class ChatRoutes {
  static const String list = '/chat';
  static const String groupChat = '/chat/group';
  static const String voiceMessage = '/chat/voice';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case list:
        return MaterialPageRoute(
          builder: (_) => const ChatListScreen(),
          settings: settings,
        );

      case groupChat:
        final ChatModel chat = settings.arguments as ChatModel;
        return MaterialPageRoute(
          builder: (_) => GroupChatScreen(chat: chat),
          settings: settings,
        );

      case voiceMessage:
        final Map<String, dynamic> args =
            settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VoiceMessageScreen(
            filePath: args['filePath'],
            duration: args['duration'],
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No chat route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Map<String, WidgetBuilder> getRoutes() {
    return {list: (context) => const ChatListScreen()};
  }

  // Navigation helper methods
  static void navigateToList(BuildContext context) {
    Navigator.pushNamed(context, list);
  }

  static void navigateToGroupChat(BuildContext context, ChatModel chat) {
    Navigator.pushNamed(context, groupChat, arguments: chat);
  }

  static void navigateToVoiceMessage(
    BuildContext context, {
    required String filePath,
    required Duration duration,
  }) {
    Navigator.pushNamed(
      context,
      voiceMessage,
      arguments: {'filePath': filePath, 'duration': duration},
    );
  }
}
