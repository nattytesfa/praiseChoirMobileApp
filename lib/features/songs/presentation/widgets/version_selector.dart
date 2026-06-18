import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';

class VersionSelector extends StatelessWidget {
  final SongModel song;
  final Function(SongVersion)? onVersionAdded;
  final Function(String)? onVersionDeleted;

  const VersionSelector({
    super.key,
    required this.song,
    this.onVersionAdded,
    this.onVersionDeleted,
  });

  @override
  Widget build(BuildContext context) {
    // Determine history from metadata
    final List<dynamic> history =
        song.metadata?['history'] as List<dynamic>? ?? [];

    final bool hasHistory = history.isNotEmpty;
    final originalLyrics = hasHistory
        ? history.first['lyrics'] as String
        : song.lyrics;
    final originalAudio = hasHistory
        ? history.first['audioPath'] as String?
        : song.audioPath;

    // The most up-to-date lyrics/audio string is always stored directly on the song
    final latestLyrics = song.lyrics;
    final latestAudio = song.audioPath;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'versions'.tr(),
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Original Version (always exists)
          _buildHistoryCard(
            context,
            title: 'originalVersion'.tr(),
            subtitle: hasHistory
                ? 'addedOn'.tr(
                    args: [
                      _formatDate(
                        DateTime.tryParse(history.first['timestamp']) ??
                            song.dateAdded,
                      ),
                    ],
                  )
                : 'addedOn'.tr(args: [_formatDate(song.dateAdded)]),
            lyricsContent: originalLyrics,
            audioContent: originalAudio,
          ),

          // Intermediary Versions
          if (hasHistory)
            ...List.generate(history.length - 1, (index) {
              final edit = history[index + 1];
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: _buildHistoryCard(
                  context,
                  title: 'version'.tr(args: [(index + 2).toString()]),
                  subtitle: 'editedOn'.tr(
                    args: [
                      _formatDate(
                        DateTime.tryParse(edit['timestamp']) ?? song.dateAdded,
                      ),
                    ],
                  ),
                  lyricsContent: edit['lyrics'] as String?,
                  audioContent: edit['audioPath'] as String?,
                ),
              );
            }),

          // The Latest / Current Version (only if there are edits)
          if (hasHistory) ...[
            const SizedBox(height: 16),
            _buildHistoryCard(
              context,
              title: 'latestVersion'.tr(),
              subtitle: 'editedOn'.tr(
                args: [_formatDate(song.updatedAt ?? DateTime.now())],
              ),
              lyricsContent: latestLyrics,
              audioContent: latestAudio,
              isLatest: true,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildHistoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String? lyricsContent,
    required String? audioContent,
    bool isLatest = false,
  }) {
    return Card(
      elevation: isLatest ? 4 : 1,
      color: isLatest ? AppColors.primary.withValues(alpha: 0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLatest
            ? BorderSide(color: AppColors.primary, width: 1.5)
            : BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isLatest
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLatest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'current'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionSmallButton(
                    context,
                    icon: Icons.history_edu,
                    label: 'viewLyrics'.tr(),
                    onTap: () {
                      if (lyricsContent == null ||
                          lyricsContent.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('noOriginalLyrics'.tr())),
                        );
                      } else {
                        _showContentDialog(
                          context,
                          title: '$title - ${'lyrics'.tr()}',
                          content: lyricsContent,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionSmallButton(
                    context,
                    icon: Icons.library_music,
                    label: 'viewAudio'.tr(),
                    onTap: () {
                      if (audioContent == null || audioContent.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('noOriginalAudio'.tr())),
                        );
                      } else {
                        _showContentDialog(
                          context,
                          title: '$title - ${'audio'.tr()}',
                          content: audioContent,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSmallButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContentDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            minHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(content, style: AppTextStyles.bodyLarge),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('close'.tr()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
