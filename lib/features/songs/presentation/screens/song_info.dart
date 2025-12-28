import 'package:flutter/material.dart' hide DateUtils;
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/core/utils/date_utils.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';

class SongInfo extends StatelessWidget {
  final SongModel song;

  const SongInfo({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('General Info', [
            _buildInfoRow('Song Number', song.songNumber ?? '-'),
            _buildInfoRow('Language', song.language),
            _buildInfoRow('Added By', song.addedBy),
            _buildInfoRow('Date Added', DateUtils.formatDate(song.dateAdded)),
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('Statistics', [
            _buildInfoRow('Likes', song.likeCount.toString()),
            _buildInfoRow(
              'Performance Count',
              song.performanceCount.toString(),
            ),
            _buildInfoRow(
              'Last Performed',
              song.lastPerformed != null
                  ? DateUtils.formatDate(song.lastPerformed!)
                  : 'Never',
            ),
            _buildInfoRow(
              'Last Practiced',
              song.lastPracticed != null
                  ? DateUtils.formatDate(song.lastPracticed!)
                  : 'Never',
            ),
            _buildInfoRow(
              'Times Practiced',
              song.practiceCount.toString(),
            ),
          ]),
          const SizedBox(height: 24),
          if (song.tags.isNotEmpty) ...[
            Text(
              'Tags',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: song.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: AppColors.primary),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
