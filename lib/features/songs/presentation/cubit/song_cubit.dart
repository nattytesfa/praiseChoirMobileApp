import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/widgets/common/network/sync_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';
import 'song_state.dart';

class SongCubit extends Cubit<SongState> {
  final SongRepository songRepository;
  final AuthCubit authCubit;
  StreamSubscription? _authSubscription;

  SongCubit({SongRepository? repository, required this.authCubit})
    : songRepository = repository ?? SongRepository(SyncCubit()),
      super(SongInitial()) {
    // Listen to auth changes to reload songs with correct favorites
    _authSubscription = authCubit.stream.listen((authState) {
      loadSongs();
    });

    loadSongs();
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  String? get _currentUserId {
    final state = authCubit.state;
    if (state is AuthAuthenticated) {
      return state.user.id;
    }
    return null;
  }

  void loadSongs() async {
    emit(SongLoading());
    try {
      final songs = await songRepository.getAllSongs(userId: _currentUserId);
      emit(SongLoaded(songs));
    } catch (e) {
      emit(SongError('Failed to load songs'));
    }
  }

  void searchSongs(String query) async {
    if (query.isEmpty) {
      final currentState = state;
      if (currentState is SongLoaded) {
        emit(SongLoaded(currentState.songs));
      }
      return;
    }

    try {
      final results = await songRepository.searchSongs(
        query,
        userId: _currentUserId,
      );
      emit(SongSearchResults(results));
    } catch (e) {
      emit(SongError('Failed to search songs'));
    }
  }

  void filterSongsByTag(String tag) async {
    emit(SongLoading());
    try {
      final songs = await songRepository.getSongsByTag(
        tag,
        userId: _currentUserId,
      );
      final currentState = state;
      if (currentState is SongLoaded) {
        emit(SongLoaded(currentState.songs, filteredSongs: songs));
      }
    } catch (e) {
      emit(SongError('Failed to filter songs'));
    }
  }

  void getNeglectedSongs() async {
    emit(SongLoading());
    try {
      final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
      final neglectedSongs = await songRepository.getNeglectedSongs(
        threeMonthsAgo,
        daysThreshold: 90,
        userId: _currentUserId,
      );
      final currentState = state;
      if (currentState is SongLoaded) {
        emit(SongLoaded(currentState.songs, filteredSongs: neglectedSongs));
      }
    } catch (e) {
      emit(SongError('Failed to get neglected songs'));
    }
  }

  void addSong(SongModel song) async {
    try {
      await songRepository.addSong(song);
      loadSongs(); // Reload the list
    } catch (e) {
      emit(SongError('Failed to add song'));
    }
  }

  void updateSong(SongModel song) async {
    try {
      await songRepository.updateSong(song);
      loadSongs(); // Reload the list
    } catch (e) {
      emit(SongError('Failed to update song'));
    }
  }

  void deleteSong(String songId) async {
    final currentState = state;
    try {
      if (kDebugMode) {
        print('SongCubit: Attempting to delete song $songId');
      }
      await songRepository.deleteSong(songId);
      if (kDebugMode) {
        print('SongCubit: Delete successful, reloading songs');
      }
      loadSongs(); // Reload the list
    } catch (e) {
      if (kDebugMode) {
        print('SongCubit: Delete failed with error: $e');
      }
      if (currentState is SongLoaded) {
        emit(
          SongLoaded(
            currentState.songs,
            filteredSongs: currentState.filteredSongs,
            errorMessage: 'Failed to delete song: $e',
          ),
        );
      } else {
        emit(SongError('Failed to delete song: $e'));
      }
    }
  }

  void toggleFavorite(String songId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return; // Or handle guest favorites differently

      await songRepository.toggleLocalFavorite(songId, userId);
      loadSongs(); // Reload to update the UI with new favorite status
    } catch (e) {
      emit(SongError('Failed to toggle favorite'));
    }
  }

  void markSongPerformed(String songId) async {
    try {
      await songRepository.markSongPerformed(songId);
      loadSongs(); // Reload to update last performed date
    } catch (e) {
      emit(SongError('Failed to mark song as performed'));
    }
  }

  void markSongPracticed(String songId) async {
    try {
      await songRepository.markSongPracticed(songId);
      loadSongs(); // Reload to update last practiced date
    } catch (e) {
      emit(SongError('Failed to mark song as practiced'));
    }
  }

  void addSongVersion(String songId, SongVersion version) async {
    try {
      await songRepository.addSongVersion(songId, version);
      loadSongs(); // Reload to include new version
    } catch (e) {
      emit(SongError('Failed to add song version'));
    }
  }

  void deleteSongVersion(String songId, String versionId) async {
    try {
      await songRepository.deleteSongVersion(songId, versionId);
      loadSongs(); // Reload to remove version
    } catch (e) {
      emit(SongError('Failed to delete song version'));
    }
  }

  void addRecordingNote(String songId, RecordingNote note) async {
    try {
      await songRepository.addRecordingNote(songId, note);
      loadSongs(); // Reload to include new note
    } catch (e) {
      emit(SongError('Failed to add recording note'));
    }
  }
}
