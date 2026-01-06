import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
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
      case 'this_round':
        return 'This Round';
      default:
        return tag;
    }
  }

  Widget _buildTags() {
    final displayTags = song.tags.where((tag) => tag != 'favorite').toList();
    if (displayTags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      children: displayTags.map((tag) {
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
        if (song.likeCount > 0) ...[
          Row(
            children: [
              const Icon(Icons.favorite, size: 14, color: AppColors.error),
              const SizedBox(width: 4),
              Text(song.likeCount.toString(), style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(width: 12),
        ],

        if (song.audioPath != null)
          const Icon(Icons.audio_file, size: 14, color: AppColors.primary),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deleteSong'.tr()),
        content: Text('areYouSureYouWantToDeleteThisSong'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete?.call();
    }
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
          color: Theme.of(context).listTileTheme.tileColor,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          clipBehavior: Clip.antiAlias,
          child: Slidable(
            endActionPane: isAdmin
                ? ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _confirmDelete(context),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'delete'.tr(),
                      ),
                      SlidableAction(
                        onPressed: _openSongDetail,
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        icon: Icons.details,
                        label: 'songDetail'.tr(),
                      ),
                      SlidableAction(
                        onPressed: (_) => onPerformed(),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.share_rounded,
                        label: 'share'.tr(),
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
                        label: 'songDetail'.tr(),
                      ),
                      SlidableAction(
                        onPressed: (_) => onPerformed(),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.share_rounded,
                        label: 'share'.tr(),
                      ),
                    ],
                  ),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: AppTextStyles.songTitle,
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
                  song.tags.contains('favorite'.tr())
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: song.tags.contains('favorite'.tr())
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
