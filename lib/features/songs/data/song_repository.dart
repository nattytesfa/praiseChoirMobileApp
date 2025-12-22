import 'package:hive/hive.dart';
import 'package:praise_choir_app/features/songs/domain/entities/song_entity.dart';
import 'models/song_model.dart';

class HiveBoxes {
  static const String songs = 'songs';
}

class SongRepository {
  late Box<SongModel> _songBox;

  SongRepository() {
    _songBox = Hive.box<SongModel>(HiveBoxes.songs);
  }

  Future<List<SongModel>> getAllSongs() async {
    return _songBox.values.toList();
  }

  Future<List<SongModel>> getSongsByTag(String tag) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.tags.contains(tag)).toList();
  }

  Future<List<SongModel>> searchSongs(String query) async {
    final allSongs = await getAllSongs();
    final lowercaseQuery = query.toLowerCase();

    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowercaseQuery) ||
          song.lyrics.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<List<SongModel>> getNeglectedSongs(
    DateTime thresholdDate, {
    required int daysThreshold,
  }) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) {
      final lastUsed =
          song.lastPerformed ?? song.lastPracticed ?? song.dateAdded;
      return lastUsed.isBefore(thresholdDate);
    }).toList();
  }

  Future<void> addSong(SongModel song) async {
    await _songBox.add(song);
  }

  Future<void> updateSong(SongModel song) async {
    final index = _songBox.values.toList().indexWhere((s) => s.id == song.id);
    if (index != -1) {
      await _songBox.putAt(index, song);
    }
  }

  Future<void> deleteSong(String songId) async {
    final index = _songBox.values.toList().indexWhere((s) => s.id == songId);
    if (index != -1) {
      await _songBox.deleteAt(index);
    }
  }

  Future<void> markSongPerformed(String songId) async {
    final song = _songBox.values.firstWhere((s) => s.id == songId);
    final updatedSong = song.copyWith(
      lastPerformed: DateTime.now(),
      performanceCount: song.performanceCount + 1,
    );
    await updateSong(updatedSong);
  }

  Future<void> markSongPracticed(String songId) async {
    final song = _songBox.values.firstWhere((s) => s.id == songId);
    final updatedSong = song.copyWith(lastPracticed: DateTime.now());
    await updateSong(updatedSong);
  }

  Future<void> addSongVersion(String songId, SongVersion version) async {
    final song = _songBox.values.firstWhere((s) => s.id == songId);
    final updatedVersions = List<SongVersion>.from(song.versions)..add(version);
    final updatedSong = song.copyWith(versions: updatedVersions);
    await updateSong(updatedSong);
  }

  Future<void> addRecordingNote(String songId, RecordingNote note) async {
    final song = _songBox.values.firstWhere((s) => s.id == songId);
    final updatedNotes = List<RecordingNote>.from(song.recordingNotes)
      ..add(note);
    final updatedSong = song.copyWith(recordingNotes: updatedNotes);
    await updateSong(updatedSong);
  }

  Future<List<SongEntity>> getRotatedSongs({
    int oldSongsCount = 3,
    int newSongsCount = 2,
    int favoriteSongsCount = 2,
  }) async {
    final allSongs = await getAllSongs();

    // Convert models to entities for domain use
    final entities = allSongs.map((m) => SongEntity.fromModel(m)).toList();

    // Favorites
    final favorites = entities
        .where((s) => s.isFavorite)
        .take(favoriteSongsCount)
        .toList();

    // New songs (tagged 'new')
    final newSongs = entities
        .where((s) => s.isNew && !favorites.contains(s))
        .take(newSongsCount)
        .toList();

    // Old songs: those with tag 'old' or oldest by lastUsed
    final candidates = entities
        .where((s) => !favorites.contains(s) && !newSongs.contains(s))
        .toList();
    candidates.sort((a, b) => a.lastUsed.compareTo(b.lastUsed));
    final oldSongs = candidates.take(oldSongsCount).toList();

    // Combine ensuring uniqueness and preserving order: old, new, favorites
    final result = <SongEntity>[];
    result.addAll(oldSongs);
    for (final s in newSongs) {
      if (!result.contains(s)) {
        result.add(s);
      }
    }
    for (final s in favorites) {
      if (!result.contains(s)) {
        result.add(s);
      }
    }

    return result;
  }
}
