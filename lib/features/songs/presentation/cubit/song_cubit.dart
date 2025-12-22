import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';
import 'song_state.dart';

class SongCubit extends Cubit<SongState> {
  final SongRepository songRepository;

  SongCubit({SongRepository? repository})
    : songRepository = repository ?? SongRepository(),
      super(SongInitial()) {
    loadSongs();
  }

  void loadSongs() async {
    emit(SongLoading());
    try {
      final songs = await songRepository.getAllSongs();
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
      final results = await songRepository.searchSongs(query);
      emit(SongSearchResults(results));
    } catch (e) {
      emit(SongError('Failed to search songs'));
    }
  }

  void filterSongsByTag(String tag) async {
    emit(SongLoading());
    try {
      final songs = await songRepository.getSongsByTag(tag);
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

  void addRecordingNote(String songId, RecordingNote note) async {
    try {
      await songRepository.addRecordingNote(songId, note);
      loadSongs(); // Reload to include new note
    } catch (e) {
      emit(SongError('Failed to add recording note'));
    }
  }
}
