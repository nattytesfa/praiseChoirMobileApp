import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common/empty_state.dart';
import '../../../../core/widgets/common/loading_indicator.dart';
import '../../data/models/message_model.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatListScreen extends StatefulWidget {
  final ValueNotifier<bool>? isVisibleNotifier;
  const ChatListScreen({super.key, this.isVisibleNotifier});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _currentUserId = '';
  MessageModel? _replyingTo;
  MessageModel? _editingMessage;
  final Set<String> _selectedMessageIds = {};

  bool get _isSelectionMode => _selectedMessageIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        _currentUserId = authState.user.id;
        context.read<ChatCubit>().joingroupChat(_currentUserId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showReadInfo(MessageModel message) {
    final users = context.read<ChatCubit>().getUsers(message.readBy);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('readBy'.tr()),
        content: SizedBox(
          width: double.maxFinite,
          child: users.isEmpty
              ? Text('noOneRead'.tr())
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.profileImagePath != null
                            ? NetworkImage(user.profileImagePath!)
                            : null,
                        child: user.profileImagePath == null
                            ? Text(user.name[0].toUpperCase())
                            : null,
                      ),
                      title: Text(user.name),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation({
    required VoidCallback onConfirm,
    required String title,
    required String content,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'delete'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              title: Text('${_selectedMessageIds.length} ${'selected'.tr()}'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedMessageIds.clear();
                  });
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    final authState = context.read<AuthCubit>().state;
                    final isAdmin =
                        authState is AuthAuthenticated &&
                        (authState.user.role == 'leader' ||
                            authState.user.role == 'admin');
                    final chatState = context.read<ChatCubit>().state;
                    bool hasOthersMessages = false;
                    if (chatState is MessagesLoaded) {
                      hasOthersMessages = chatState.messages
                          .where((m) => _selectedMessageIds.contains(m.id))
                          .any((m) => m.senderId != _currentUserId);
                    }

                    String content = 'deleteMessagesConfirm'.tr();
                    if (isAdmin && hasOthersMessages) {
                      content = 'deleteMessagesConfirmForEveryone'.tr();
                    }

                    _showDeleteConfirmation(
                      title: 'deleteMessagesTitle'.tr(),
                      content: content,
                      onConfirm: () {
                        context.read<ChatCubit>().deleteMessages(
                          _selectedMessageIds.toList(),
                          _currentUserId,
                          isAdmin: isAdmin,
                        );
                        setState(() {
                          _selectedMessageIds.clear();
                        });
                      },
                    );
                  },
                ),
              ],
            )
          : AppBar(
              title: Text('groupChat'.tr()),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'clear') {
                      _showDeleteConfirmation(
                        title: 'clearHistory'.tr(),
                        content: 'clearHistoryConfirm'.tr(),
                        onConfirm: () {
                          context.read<ChatCubit>().clearHistory(
                            'general',
                            _currentUserId,
                          );
                        },
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'clear',
                        child: Text('clearHistory'.tr()),
                      ),
                    ];
                  },
                ),
              ],
            ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state is MessagesLoaded) {
                  // Messages are reversed in the list view, so we don't need to scroll to bottom
                  // unless we want to ensure we are at the start of the list
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const LoadingIndicator();
                }

                if (state is ChatError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<ChatCubit>()
                              .joingroupChat(_currentUserId),
                          child: Text('retry'.tr()),
                        ),
                      ],
                    ),
                  );
                }

                if (state is MessagesLoaded) {
                  final messages = state.messages;

                  if (messages.isEmpty) {
                    return EmptyState(
                      icon: Icons.chat,
                      title: 'noMessages'.tr(),
                      message: 'startConversation'.tr(),
                    );
                  }

                  return ValueListenableBuilder<bool>(
                    valueListenable:
                        widget.isVisibleNotifier ?? ValueNotifier(true),
                    builder: (context, isVisible, child) {
                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Show latest messages at the bottom
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final authState = context.read<AuthCubit>().state;
                          final currentUserId = (authState is AuthAuthenticated)
                              ? authState.user.id
                              : _currentUserId;
                          final isMe = message.senderId == currentUserId;
                          final isAdmin =
                              authState is AuthAuthenticated &&
                              (authState.user.role == 'leader' ||
                                  authState.user.role == 'admin');

                          MessageModel? repliedMsg;
                          if (message.replyToId != null) {
                            try {
                              repliedMsg = messages.firstWhere(
                                (m) => m.id == message.replyToId,
                              );
                            } catch (_) {}
                          }

                          // Mark as read if not me and not read
                          if (isVisible &&
                              currentUserId.isNotEmpty &&
                              !isMe &&
                              !message.readBy.contains(currentUserId) &&
                              message.status != MessageStatus.read) {
                            context.read<ChatCubit>().markMessageAsRead(
                              message.id,
                              currentUserId,
                            );
                          }

                          return MessageBubble(
                            message: message,
                            isMe: isMe,
                            isAdmin: isAdmin,
                            showAvatar: true,
                            repliedMessage: repliedMsg,
                            isSelected: _selectedMessageIds.contains(
                              message.id,
                            ),
                            isSelectionMode: _isSelectionMode,
                            onToggleSelection: () {
                              setState(() {
                                if (_selectedMessageIds.contains(message.id)) {
                                  _selectedMessageIds.remove(message.id);
                                } else {
                                  _selectedMessageIds.add(message.id);
                                }
                              });
                            },
                            onTap: () {},
                            onReply: (msg) {
                              setState(() {
                                _replyingTo = msg;
                                _editingMessage = null;
                              });
                            },
                            onReaction: (emoji) {
                              if (currentUserId.isNotEmpty) {
                                context.read<ChatCubit>().toggleReaction(
                                  message.id,
                                  currentUserId,
                                  emoji,
                                );
                              }
                            },
                            onInfo: _showReadInfo,
                            onEdit: (msg) {
                              setState(() {
                                _editingMessage = msg;
                                _replyingTo = null;
                                _messageController.text = msg.content;
                              });
                            },
                            onDelete: (id) {
                              String content =
                                  'Are you sure you want to delete this message?';
                              if (isAdmin && !isMe) {
                                content =
                                    'Are you sure you want to delete this message for everyone?';
                              }

                              _showDeleteConfirmation(
                                title: 'Delete Message',
                                content: content,
                                onConfirm: () {
                                  context.read<ChatCubit>().deleteMessage(
                                    id,
                                    _currentUserId,
                                    isAdmin: isAdmin,
                                  );
                                },
                              );
                            },
                            onAvatarTap: () {
                              // Avatar tap action disabled as private chat is not implemented
                            },
                          );
                        },
                      );
                    },
                  );
                }

                return const LoadingIndicator();
              },
            ),
          ),
          ChatInput(
            controller: _messageController,
            replyingTo: _replyingTo,
            onCancelReply: () {
              setState(() {
                _replyingTo = null;
              });
            },
            editingMessage: _editingMessage,
            onCancelEdit: () {
              setState(() {
                _editingMessage = null;
                _messageController.clear();
              });
            },
            onSendMessage: (text) {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                if (_editingMessage != null) {
                  context.read<ChatCubit>().editMessage(
                    _editingMessage!.id,
                    text,
                  );
                  setState(() {
                    _editingMessage = null;
                  });
                } else {
                  context.read<ChatCubit>().sendTextMessage(
                    'general',
                    authState.user.id,
                    text,
                    senderName: authState.user.name,
                    senderProfileImage: authState.user.profileImagePath,
                    replyToId: _replyingTo?.id,
                  );
                  setState(() {
                    _replyingTo = null;
                  });
                }
                _messageController.clear();
              }
            },
            onVoiceMessage: (path) {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                context.read<ChatCubit>().sendVoiceMessage(
                  'general',
                  authState.user.id,
                  path,
                  senderName: authState.user.name,
                  senderProfileImage: authState.user.profileImagePath,
                  replyToId: _replyingTo?.id,
                );
                setState(() {
                  _replyingTo = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
