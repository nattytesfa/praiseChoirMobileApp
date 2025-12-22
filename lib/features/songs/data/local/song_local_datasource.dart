import 'package:hive/hive.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';

class SongLocalDataSource {
  late Box<SongModel> _songBox;

  Future<void> init() async {
    _songBox = Hive.box<SongModel>(HiveBoxes.songs);
  }

  // Create
  Future<void> addSong(SongModel song) async {
    await _songBox.put(song.id, song);
  }

  Future<void> addSongs(List<SongModel> songs) async {
    await _songBox.addAll(songs);
  }

  // Read
  Future<List<SongModel>> getAllSongs() async {
    return _songBox.values.toList();
  }

  Future<SongModel?> getSongById(String id) async {
    try {
      return _songBox.values.firstWhere((song) => song.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<SongModel>> getSongsByLanguage(String language) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.language == language).toList();
  }

  Future<List<SongModel>> getSongsByTag(String tag) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.tags.contains(tag)).toList();
  }

  Future<List<SongModel>> getSongsWithAudio() async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.audioPath != null).toList();
  }

  Future<List<SongModel>> getFavoriteSongs() async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.tags.contains('favorite')).toList();
  }

  // Update
  Future<void> updateSong(SongModel song) async {
    await _songBox.put(song.id, song);
  }

  Future<void> updateSongField(
    String songId,
    dynamic Function(SongModel) update,
  ) async {
    final song = await getSongById(songId);
    if (song != null) {
      final updatedSong = update(song);
      await updateSong(updatedSong);
    }
  }

  // Delete
  Future<void> deleteSong(String id) async {
    await _songBox.delete(id);
  }

  Future<void> deleteAllSongs() async {
    await _songBox.clear();
  }

  // Search
  Future<List<SongModel>> searchSongs(String query) async {
    final allSongs = await getAllSongs();
    final lowercaseQuery = query.toLowerCase();

    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowercaseQuery) ||
          song.lyrics.toLowerCase().contains(lowercaseQuery) ||
          song.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Statistics
  Future<Map<String, dynamic>> getSongStatistics() async {
    final allSongs = await getAllSongs();

    return {
      'totalSongs': allSongs.length,
      'songsWithAudio': allSongs.where((s) => s.audioPath != null).length,
      'amharicSongs': allSongs.where((s) => s.language == 'amharic').length,
      'kembatignaSongs': allSongs
          .where((s) => s.language == 'kembatigna')
          .length,
      'favoriteSongs': allSongs
          .where((s) => s.tags.contains('favorite'))
          .length,
      'oldSongs': allSongs.where((s) => s.tags.contains('old')).length,
      'newSongs': allSongs.where((s) => s.tags.contains('new')).length,
    };
  }

  // Neglected songs (not used in 3+ months)
  Future<List<SongModel>> getNeglectedSongs() async {
    final allSongs = await getAllSongs();
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));

    return allSongs.where((song) {
      final lastUsed =
          song.lastPerformed ?? song.lastPracticed ?? song.dateAdded;
      return lastUsed.isBefore(threeMonthsAgo);
    }).toList();
  }

  // Recently used songs
  Future<List<SongModel>> getRecentlyUsedSongs({int limit = 10}) async {
    final allSongs = await getAllSongs();
    allSongs.sort((a, b) {
      final aLastUsed = a.lastPerformed ?? a.lastPracticed ?? a.dateAdded;
      final bLastUsed = b.lastPerformed ?? b.lastPracticed ?? b.dateAdded;
      return bLastUsed.compareTo(aLastUsed);
    });

    return allSongs.take(limit).toList();
  }

  // Most performed songs
  Future<List<SongModel>> getMostPerformedSongs({int limit = 10}) async {
    final allSongs = await getAllSongs();
    allSongs.sort((a, b) => b.performanceCount.compareTo(a.performanceCount));
    return allSongs.take(limit).toList();
  }

  // Cleanup duplicate songs
  Future<int> cleanupDuplicates() async {
    final allSongs = await getAllSongs();
    final uniqueSongs = <String, SongModel>{};
    int duplicates = 0;

    for (final song in allSongs) {
      final key = '${song.title.toLowerCase()}_${song.language}';
      if (!uniqueSongs.containsKey(key)) {
        uniqueSongs[key] = song;
      } else {
        duplicates++;
      }
    }

    if (duplicates > 0) {
      await _songBox.clear();
      await _songBox.addAll(uniqueSongs.values);
    }

    return duplicates;
  }

  // Export songs to JSON
  Future<String> exportSongsToJson() async {
    final allSongs = await getAllSongs();
    final songsJson = allSongs.map((song) => song.toJson()).toList();
    return songsJson.toString();
  }

  // Import songs from JSON
  Future<void> importSongsFromJson(List<dynamic> jsonList) async {
    final songs = jsonList.map((json) => SongModel.fromJson(json)).toList();
    await addSongs(songs);
  }
}
