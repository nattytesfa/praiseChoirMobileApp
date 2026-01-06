import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/widgets/common/empty_state.dart';
import 'package:praise_choir_app/core/widgets/common/loading_indicator.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_cubit.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_state.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/song_detail_screen.dart';
import 'package:praise_choir_app/features/songs/presentation/widgets/song_list_item.dart';

import '../../../../core/theme/app_colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('favorites'.tr()),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocBuilder<SongCubit, SongState>(
        builder: (context, state) {
          if (state is SongLoading) {
            return const LoadingIndicator();
          } else if (state is SongLoaded) {
            final favoriteSongs = state.songs
                .where((song) => song.tags.contains('favorite'))
                .toList();

            if (favoriteSongs.isEmpty) {
              return EmptyState(
                message: 'noFavoriteSongsYet'.tr(),
                icon: Icons.favorite_border,
                title: 'favorites'.tr(),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: favoriteSongs.length,
                itemBuilder: (context, index) {
                  final song = favoriteSongs[index];
                  return SongListItem(
                    song: song,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongDetailScreen(song: song),
                        ),
                      );
                    },
                    onPerformed: () {
                      context.read<SongCubit>().markSongPerformed(song.id);
                    },
                    onPracticed: () {
                      context.read<SongCubit>().markSongPracticed(song.id);
                    },
                    onFavorite: () {
                      context.read<SongCubit>().toggleFavorite(song.id);
                    },
                    onDelete: () {
                      context.read<SongCubit>().deleteSong(song.id);
                    },
                  );
                },
              ),
            );
          } else if (state is SongError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
