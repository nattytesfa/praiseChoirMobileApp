import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/core/utils/date_utils.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/song_detail_screen.dart';

class SongListItem extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback onPerformed;
  final VoidCallback onPracticed;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;
  final bool showStats;

  const SongListItem({
    super.key,
    required this.song,
    required this.onTap,
    required this.onPerformed,
    required this.onPracticed,
    this.onDelete,
    this.onFavorite,
    this.showStats = true,
  });

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'new':
        return AppColors.success;
      case 'favorite':
        return AppColors.error;
      case 'this_round':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  String _getTagDisplayName(String tag) {
    switch (tag) {
      case 'new':
        return 'New';
      case 'favorite':
        return 'Favorite';
      case 'this_round':
        return 'This Round';
      default:
        return tag;
    }
  }

  String _getLastUsedText() {
    final lastUsed = song.lastPerformed ?? song.lastPracticed;
    if (lastUsed == null) return 'Never used';
    return DateUtils.formatRelativeTime(lastUsed);
  }

  Widget _buildTags() {
    if (song.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      children: song.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.withValues(_getTagColor(tag), 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _getTagColor(tag)),
          ),
          child: Text(
            _getTagDisplayName(tag),
            style: AppTextStyles.caption.copyWith(
              color: _getTagColor(tag),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStats() {
    if (!showStats) return const SizedBox.shrink();

    return Row(
      children: [
        // Performance Count
        if (song.performanceCount > 0) ...[
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(
                song.performanceCount.toString(),
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],

        // Audio Indicator
        if (song.audioPath != null)
          const Icon(Icons.audio_file, size: 14, color: AppColors.primary),

        // Last Used
        Expanded(
          child: Text(
            _getLastUsedText(),
            style: AppTextStyles.caption,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _openSongDetail(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => SongDetailScreen(song: song)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isAdmin =
            authState is AuthAuthenticated && authState.user.role == 'admin';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          clipBehavior: Clip.antiAlias,
          child: Slidable(
            endActionPane: isAdmin
                ? ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => onDelete?.call(),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                      SlidableAction(
                        onPressed: _openSongDetail,
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        icon: Icons.details,
                        label: 'Song Detail',
                      ),
                      SlidableAction(
                        onPressed: (_) => onPerformed(),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.share_rounded,
                        label: 'Share',
                      ),
                    ],
                  )
                : ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: _openSongDetail,
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        icon: Icons.details,
                        label: 'Song Detail',
                      ),
                      SlidableAction(
                        onPressed: (_) => onPerformed(),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.share_rounded,
                        label: 'Share',
                      ),
                    ],
                  ),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  _buildTags(),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const SizedBox(height: 10), _buildStats()],
              ),
              trailing: IconButton(
                icon: Icon(
                  song.tags.contains('favorite')
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: song.tags.contains('favorite')
                      ? AppColors.error
                      : Colors.grey,
                ),
                onPressed: onFavorite,
              ),
              onTap: onTap,
            ),
          ),
        );
      },
    );
  }
}
