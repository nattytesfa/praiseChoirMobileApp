import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/core/widgets/common/empty_state.dart';
import 'package:praise_choir_app/core/widgets/common/loading_indicator.dart';
import 'package:praise_choir_app/core/widgets/display/role_badge.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_state.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/song_detail_screen.dart';
import 'package:praise_choir_app/features/songs/song_routes.dart';
import '../widgets/song_list_item.dart';
import '../widgets/song_filter_sheet.dart';
import '../cubit/song_cubit.dart';

class SongLibraryScreen extends StatefulWidget {
  const SongLibraryScreen({super.key});

  @override
  State<SongLibraryScreen> createState() => _SongLibraryScreenState();
}

class _SongLibraryScreenState extends State<SongLibraryScreen> {
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    // AuthCubit may be disabled while testing; guard the read.
    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        _currentUser = authState.user;
      }
    } catch (_) {
      _currentUser = null;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SongFilterSheet(
        onTagSelected: (tag) {
          context.read<SongCubit>().filterSongsByTag(tag);
        },
        onNeglectedSongs: () {
          context.read<SongCubit>().getNeglectedSongs();
        },
      ),
    );
  }

  void _addNewSong() {
    // Navigate to add song screen
    Navigator.pushNamed(context, SongRoutes.add);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('songLibrary'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, SongRoutes.search),
          ),
          if (_currentUser != null) RoleBadge(role: _currentUser!.role),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocListener<SongCubit, SongState>(
              listener: (context, state) {
                if (state is SongLoaded && state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: BlocBuilder<SongCubit, SongState>(
                builder: (context, state) {
                  if (state is SongLoading) {
                    return const LoadingIndicator();
                  } else if (state is SongError) {
                    return Center(child: Text(state.message));
                  } else if (state is SongLoaded ||
                      state is SongSearchResults) {
                    List<SongModel> songsToShow = [];

                    if (state is SongLoaded) {
                      songsToShow = state.filteredSongs ?? state.songs;
                    } else if (state is SongSearchResults) {
                      songsToShow = state.results;
                    }

                    if (songsToShow.isEmpty) {
                      return const EmptyState(
                        message: 'No songs found',
                        icon: Icons.music_off,
                        title: '',
                      );
                    }

                    return ListView.builder(
                      itemCount: songsToShow.length,
                      itemBuilder: (context, index) {
                        final song = songsToShow[index];
                        return SongListItem(
                          song: song,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SongDetailScreen(song: song),
                              ),
                            );
                          },
                          onPerformed: () {
                            context.read<SongCubit>().markSongPerformed(
                              song.id,
                            );
                          },
                          onPracticed: () {
                            context.read<SongCubit>().markSongPracticed(
                              song.id,
                            );
                          },
                          onDelete: () {
                            context.read<SongCubit>().deleteSong(song.id);
                          },
                          onFavorite: () {
                            context.read<SongCubit>().toggleFavorite(song.id);
                          },
                        );
                      },
                    );
                  }
                  return const EmptyState(
                    message: 'No songs available',
                    icon: Icons.music_note,
                    title: '',
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated &&
                  (state.user.role == 'admin' ||
                      state.user.role == 'songwriter')) {
                return FloatingActionButton(
                  onPressed: _addNewSong,
                  child: const Icon(Icons.add),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
