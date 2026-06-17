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
    // If the song was edited, EditSongScreen drops the old lyrics/audio into metadata
    // and stores the new lyrics/audio in the main object.
    final bool hasEditedLyrics =
        song.metadata?.containsKey('originalLyrics') ?? false;
    final originalLyrics = hasEditedLyrics
        ? song.metadata!['originalLyrics'] as String
        : song.lyrics;
    final updatedLyrics = hasEditedLyrics ? song.lyrics : null;

    final bool hasEditedAudio =
        song.metadata?.containsKey('originalAudio') ?? false;
    final originalAudio = hasEditedAudio
        ? song.metadata!['originalAudio'] as String?
        : song.audioPath;
    final updatedAudio = hasEditedAudio ? song.audioPath : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildActionCard(
            context,
            icon: Icons.history_edu,
            title: 'originalLyrics'.tr(),
            onTap: () {
              if (originalLyrics.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('noOriginalLyrics'.tr())),
                );
              } else {
                _showContentDialog(
                  context,
                  title: 'originalLyrics'.tr(),
                  content: originalLyrics,
                );
              }
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            icon: Icons.edit_note,
            title: 'updatedLyrics'.tr(),
            onTap: () {
              if (updatedLyrics == null || updatedLyrics.trim().isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('notUpdated'.tr())));
              } else {
                _showContentDialog(
                  context,
                  title: 'updatedLyrics'.tr(),
                  content: updatedLyrics,
                );
              }
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            icon: Icons.library_music,
            title: 'originalAudio'.tr(),
            onTap: () {
              if (originalAudio == null || originalAudio.trim().isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('noOriginalAudio'.tr())));
              } else {
                _showContentDialog(
                  context,
                  title: 'originalAudio'.tr(),
                  content: originalAudio,
                );
              }
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            icon: Icons.audio_file,
            title: 'updatedAudio'.tr(),
            onTap: () {
              if (updatedAudio == null || updatedAudio.trim().isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('notUpdated'.tr())));
              } else {
                _showContentDialog(
                  context,
                  title: 'updatedAudio'.tr(),
                  content: updatedAudio,
                );
              }
            },
          ),
        ],
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

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
