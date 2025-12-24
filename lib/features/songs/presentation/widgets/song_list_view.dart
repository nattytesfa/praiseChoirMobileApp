import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_cubit.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_state.dart';
import 'package:praise_choir_app/features/songs/presentation/widgets/song_list_item.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/song_detail_screen.dart';

class SongListView extends StatefulWidget {
  final String language;

  const SongListView({super.key, required this.language});

  @override
  State<SongListView> createState() => _SongListViewState();
}

class _SongListViewState extends State<SongListView> {
  @override
  void initState() {
    super.initState();
    // Ensure songs are loaded when this view is built
    context.read<SongCubit>().loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) {
        if (state is SongLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SongLoaded) {
          final songs = state.songs.where((song) {
            // Assuming 'am' for Amharic and 'en' for English/Kembatgna or others
            // Adjust logic based on actual language codes in SongModel
            if (widget.language == 'am') {
              return song.language == 'amharic';
            } else {
              return song.language != 'amharic';
            }
          }).toList();

          if (songs.isEmpty) {
            return Center(
              child: Text(
                widget.language == 'am' ? 'ምንም መዝሙሮች አልተገኙም' : 'No songs found',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
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
                  // Handle performed action
                },
                onPracticed: () {
                  // Handle practiced action
                },
              );
            },
          );
        } else if (state is SongError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
