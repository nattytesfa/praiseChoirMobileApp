import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/announcement_model.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final Function(String) onMarkAsRead;
  final Function(AnnouncementModel)? onEdit;
  final Function(String)? onDelete;
  final Function(AnnouncementModel)? onViewReaders;
  final bool showMarkAsRead;
  final bool isAdmin;
  final String currentUserId;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onMarkAsRead,
    this.onEdit,
    this.onDelete,
    this.onViewReaders,
    this.showMarkAsRead = true,
    this.isAdmin = false,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = _getTextColor();
    final footerColor = textColor != null
        ? AppColors.withValues(textColor, 0.7)
        : AppColors.textSecondary;

    return Card(
      elevation: 2,
      color: _getCardColor(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                if (announcement.isUrgent) ...[
                  const Icon(Icons.warning, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    announcement.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (announcement.isHighPriority) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'highPriority'.tr(),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
                if (isAdmin)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: textColor),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call(announcement);
                          break;
                        case 'delete':
                          onDelete?.call(announcement.id);
                          break;
                        case 'readers':
                          onViewReaders?.call(announcement);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 20),
                              const SizedBox(width: 8),
                              Text('edit'.tr()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'delete'.tr(),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'readers',
                          child: Row(
                            children: [
                              const Icon(Icons.visibility, size: 20),
                              const SizedBox(width: 8),
                              Text('viewReaders'.tr()),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Content
            Text(
              announcement.content,
              style: AppTextStyles.bodyMedium.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),
            // Footer
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'postedBy'.tr(args: [announcement.authorName ?? announcement.createdBy])} • ${_formatDate(announcement.createdAt)}',
                    style: AppTextStyles.caption.copyWith(color: footerColor),
                  ),
                ),
                if (showMarkAsRead &&
                    !announcement.readBy.contains(currentUserId))
                  TextButton(
                    onPressed: () => onMarkAsRead(announcement.id),
                    child: Text(
                      'markAsRead'.tr(),
                      style: AppTextStyles.caption.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (announcement.expiresAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'expiresAt'.tr(args: [_formatDate(announcement.expiresAt!)]),
                style: AppTextStyles.caption.copyWith(
                  color: footerColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color? _getCardColor() {
    if (announcement.isUrgent) {
      return AppColors.withValues(Colors.red, 0.1);
    } else if (announcement.isHighPriority) {
      return AppColors.withValues(Colors.orange, 0.1);
    }
    return null;
  }

  Color? _getTextColor() {
    if (announcement.isUrgent || announcement.isHighPriority) {
      return Colors.black;
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes < 1) {
          return 'justNow'.tr();
        }
        return 'minutesAgoShort'.tr(args: [difference.inMinutes.toString()]);
      }
      return 'hoursAgoShort'.tr(args: [difference.inHours.toString()]);
    } else if (difference.inDays == 1) {
      return 'yesterday'.tr();
    } else if (difference.inDays < 7) {
      return 'daysAgoShort'.tr(args: [difference.inDays.toString()]);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
