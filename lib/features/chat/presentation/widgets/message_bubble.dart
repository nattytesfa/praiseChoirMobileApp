import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/message_model.dart';
import 'voice_player.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;
  final Function() onTap;
  final Function()? onAvatarTap;
  final Function(MessageModel)? onEdit;
  final Function(String)? onDelete;
  final Function(MessageModel)? onReply;
  final Function(String emoji)? onReaction;
  final Function(MessageModel)? onInfo;
  final MessageModel? repliedMessage;
  final bool isAdmin;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onToggleSelection;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.onTap,
    this.onAvatarTap,
    this.onEdit,
    this.onDelete,
    this.onReply,
    this.onReaction,
    this.onInfo,
    this.repliedMessage,
    this.isAdmin = false,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onToggleSelection,
  });

  void _showOptions(BuildContext context, Offset globalPosition) {
    if (message.isDeleted) return;

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & Size.zero,
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['👍', '❤️', '😂', '😮', '😢'].map((emoji) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onReaction?.call(emoji);
                },
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              );
            }).toList(),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'reply',
          child: Row(
            children: [
              Icon(Icons.reply, color: Colors.black54),
              SizedBox(width: 8),
              Text('Reply'),
            ],
          ),
        ),
        if (isMe && message.type == MessageType.text)
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.black54),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
        if (isMe || isAdmin)
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        if (isMe && DateTime.now().difference(message.timestamp).inHours < 24)
          const PopupMenuItem<String>(
            value: 'info',
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.black54),
                SizedBox(width: 8),
                Text('Info'),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (value == 'reply') {
        onReply?.call(message);
      } else if (value == 'edit') {
        onEdit?.call(message);
      } else if (value == 'delete') {
        onDelete?.call(message.id);
      } else if (value == 'info') {
        onInfo?.call(message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onToggleSelection,
      onTap: () {
        if (isSelectionMode) {
          onToggleSelection?.call();
        }
      },
      child: Container(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe && showAvatar)
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 16,
                      backgroundImage: message.senderProfileImage != null
                          ? NetworkImage(message.senderProfileImage!)
                          : null,
                      child: message.senderProfileImage == null
                          ? Text(
                              message.senderName.isNotEmpty
                                  ? message.senderName
                                        .substring(0, 1)
                                        .toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              Flexible(
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (!isMe && showAvatar)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 12),
                        child: Text(
                          message.senderName,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTapUp: (details) {
                        if (isSelectionMode) {
                          onToggleSelection?.call();
                        } else {
                          _showOptions(context, details.globalPosition);
                        }
                      },
                      onLongPress: onToggleSelection,
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: message.isDeleted
                                    ? Colors.grey[300]
                                    : (isMe
                                          ? AppColors.primary
                                          : Colors.grey[200]),
                                borderRadius: BorderRadius.circular(16),
                                border: message.isDeleted
                                    ? Border.all(color: Colors.grey)
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (repliedMessage != null)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? Colors.black.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border(
                                          left: BorderSide(
                                            color: isMe
                                                ? Colors.white
                                                : AppColors.primary,
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            repliedMessage!.senderName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                              color: isMe
                                                  ? Colors.white
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            repliedMessage!.content,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isMe
                                                  ? Colors.white
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  _buildMessageContent(),
                                ],
                              ),
                            ),
                          ),
                          if (message.reactions != null &&
                              message.reactions!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                spacing: 4,
                                children: message.reactions!.entries.map((
                                  entry,
                                ) {
                                  return GestureDetector(
                                    onTap: () => onReaction?.call(entry.key),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      child: Text(
                                        '${entry.key} ${entry.value.length}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 4,
                        left: 12,
                        right: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.timestamp),
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                          if (message.isEdited && !message.isDeleted) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(edited)',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.grey,
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            _buildStatusIcon(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.voice:
        final durationMs = message.metadata?['duration'];
        final duration = durationMs != null
            ? Duration(milliseconds: durationMs)
            : const Duration(seconds: 0);
        return VoicePlayer(
          filePath: message.attachmentPath ?? '',
          duration: duration,
          showWaveform: true,
          backgroundColor: isMe
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey[300]!,
          activeColor: isMe ? Colors.white : AppColors.primary,
          inactiveColor: isMe ? Colors.white70 : Colors.grey[600]!,
        );
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.attachmentPath != null)
              Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                  image: DecorationImage(
                    image: AssetImage(
                      message.attachmentPath!,
                    ), // Or FileImage if local
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            if (message.content.isNotEmpty && message.content != 'Image') ...[
              const SizedBox(height: 8),
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ],
        );
      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        );
      case MessageType.system:
        return Text(
          message.content,
          style: TextStyle(
            color: isMe ? Colors.white : AppColors.textPrimary,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        );
      default:
        return Text(
          message.content,
          style: TextStyle(
            color: message.isDeleted
                ? Colors.grey[600]
                : (isMe ? Colors.white : AppColors.textPrimary),
            fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
          ),
        );
    }
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: 12, color: Colors.grey);
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 12, color: Colors.grey);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 12, color: Colors.grey);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 12, color: Colors.blue);
      case MessageStatus.failed:
        return const Icon(Icons.error, size: 12, color: Colors.red);
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDay == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
