import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/core/widgets/common/empty_state.dart';
import 'package:praise_choir_app/core/widgets/common/loading_indicator.dart';
import 'package:praise_choir_app/core/widgets/display/role_badge.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_state.dart';
import '../widgets/song_card.dart';
import '../widgets/song_filter_sheet.dart';
import '../cubit/song_cubit.dart';

class SongLibraryScreen extends StatefulWidget {
  const SongLibraryScreen({super.key});

  @override
  State<SongLibraryScreen> createState() => _SongLibraryScreenState();
}

class _SongLibraryScreenState extends State<SongLibraryScreen> {
  final _searchController = TextEditingController();
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
    Navigator.pushNamed(context, '/add-song');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Library'),
        actions: [
          if (_currentUser != null) RoleBadge(role: _currentUser!.role),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search songs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                context.read<SongCubit>().searchSongs(value);
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<SongCubit, SongState>(
              builder: (context, state) {
                if (state is SongLoading) {
                  return const LoadingIndicator();
                } else if (state is SongError) {
                  return Center(child: Text(state.message));
                } else if (state is SongLoaded || state is SongSearchResults) {
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
                      return SongCard(
                        song: song,
                        onTap: () {
                          // Navigate to song detail
                          // Navigator.pushNamed(context, '/song-detail', arguments: song);
                        },
                        onPerformed: () {
                          context.read<SongCubit>().markSongPerformed(song.id);
                        },
                        onPracticed: () {
                          context.read<SongCubit>().markSongPracticed(song.id);
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
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          try {
            // If AuthCubit is not provided (testing mode), this will throw.
            // In that case we simply don't show the FAB.
            context.read<AuthCubit>();
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  final user = authState.user;
                  if (user.role == AppConstants.roleLeader ||
                      user.role == AppConstants.roleSongwriter) {
                    return FloatingActionButton(
                      onPressed: _addNewSong,
                      child: const Icon(Icons.add),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            );
          } catch (_) {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
