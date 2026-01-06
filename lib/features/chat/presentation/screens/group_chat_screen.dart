import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class GroupChatScreen extends StatefulWidget {
  final ChatModel chat;

  const GroupChatScreen({super.key, required this.chat});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
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
        setState(() {
          _currentUserId = authState.user.id;
        });
      }
      context.read<ChatCubit>().loadMessages(widget.chat.id, _currentUserId);
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isNotEmpty) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        if (_editingMessage != null) {
          context.read<ChatCubit>().editMessage(
            _editingMessage!.id,
            text.trim(),
          );
          setState(() {
            _editingMessage = null;
          });
        } else {
          context.read<ChatCubit>().sendTextMessage(
            widget.chat.id,
            authState.user.id,
            text.trim(),
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
    }
  }

  void _sendVoiceMessage(String audioPath) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<ChatCubit>().sendVoiceMessage(
        widget.chat.id,
        authState.user.id,
        audioPath,
        senderName: authState.user.name,
        senderProfileImage: authState.user.profileImagePath,
        replyToId: _replyingTo?.id,
      );
      setState(() {
        _replyingTo = null;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${widget.chat.memberIds.length} ${'members'.tr()}',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
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
                            widget.chat.id,
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
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                final messages = state is MessagesLoaded ? state.messages : [];

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == _currentUserId;
                        final showAvatar =
                            index == 0 ||
                            messages[index - 1].senderId != message.senderId;
                        final authState = context.read<AuthCubit>().state;
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
                        if (!isMe &&
                            !message.readBy.contains(_currentUserId) &&
                            message.status != MessageStatus.read) {
                          context.read<ChatCubit>().markMessageAsRead(
                            message.id,
                            _currentUserId,
                          );
                        }

                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                          isAdmin: isAdmin,
                          showAvatar: !isMe && showAvatar,
                          repliedMessage: repliedMsg,
                          isSelected: _selectedMessageIds.contains(message.id),
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
                        );
                      },
                    ),
                    if (state is MessagesLoaded &&
                        state.typingUsers
                            .where((id) => id != _currentUserId)
                            .isNotEmpty)
                      const Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: TypingIndicator(),
                      ),
                  ],
                );
              },
            ),
          ),
          ChatInput(
            controller: _messageController,
            onTyping: (isTyping) {
              if (_currentUserId.isNotEmpty) {
                context.read<ChatCubit>().setTyping(
                  widget.chat.id,
                  _currentUserId,
                  isTyping,
                );
              }
            },
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
            onSendMessage: _sendMessage,
            onVoiceMessage: _sendVoiceMessage,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
