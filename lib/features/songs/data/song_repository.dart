import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/core/services/song_service.dart';
import 'package:praise_choir_app/core/widgets/common/network/sync_cubit.dart';
import 'package:praise_choir_app/features/songs/domain/entities/song_entity.dart';
import 'models/song_model.dart';

class SongRepository {
  late Box<SongModel> _songBox;
  late Box _favoritesBox;
  final SyncCubit? syncCubit;
  DateTime? _lastSyncTime;
  final SongService _songService = SongService();

  SongRepository(this.syncCubit) {
    _songBox = Hive.box<SongModel>(HiveBoxes.songs);
    _favoritesBox = Hive.box('favorites');
  }

  Future<List<SongModel>> getAllSongs({String? userId}) async {
    final songs = _songBox.values.where((s) => !s.isDeleted).toList();

    return songs.map((song) {
      // If no user is logged in, don't show any favorites (or use a 'guest' key if desired)
      if (userId == null) {
        // Ensure 'favorite' tag is removed for guests so they don't see others' favorites
        if (song.tags.contains('favorite')) {
          final newTags = List<String>.from(song.tags)..remove('favorite');
          return song.copyWith(tags: newTags);
        }
        return song;
      }

      final key = '${userId}_${song.id}';
      final isFavorite = _favoritesBox.containsKey(key);

      // If it's a favorite locally for THIS user, ensure 'favorite' tag is present
      if (isFavorite && !song.tags.contains('favorite')) {
        return song.copyWith(tags: [...song.tags, 'favorite']);
      }

      // If it's NOT a favorite locally for THIS user, ensure 'favorite' tag is ABSENT
      if (!isFavorite && song.tags.contains('favorite')) {
        final newTags = List<String>.from(song.tags)..remove('favorite');
        return song.copyWith(tags: newTags);
      }

      return song;
    }).toList();
  }

  Future<void> toggleLocalFavorite(String songId, String userId) async {
    final key = '${userId}_$songId';
    final isFavorite = _favoritesBox.containsKey(key);

    if (isFavorite) {
      await _favoritesBox.delete(key);
    } else {
      await _favoritesBox.put(key, true);
    }

    // Update global like count
    final song = _songBox.values.cast<SongModel?>().firstWhere(
      (s) => s?.id == songId,
      orElse: () => null,
    );

    if (song != null) {
      final currentLikes = song.likeCount;
      final newLikes = isFavorite ? currentLikes - 1 : currentLikes + 1;
      final safeLikes = newLikes < 0 ? 0 : newLikes;

      final updatedSong = song.copyWith(likeCount: safeLikes);
      await updateSong(updatedSong);
    }
  }

  Future<List<SongModel>> getSongsByTag(String tag, {String? userId}) async {
    final allSongs = await getAllSongs(userId: userId);
    return allSongs.where((song) => song.tags.contains(tag)).toList();
  }

  Future<List<SongModel>> searchSongs(String query, {String? userId}) async {
    final allSongs = await getAllSongs(userId: userId);
    final lowercaseQuery = query.toLowerCase();

    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowercaseQuery) ||
          song.lyrics.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<List<SongModel>> getNeglectedSongs(
    DateTime thresholdDate, {
    required int daysThreshold,
    String? userId,
  }) async {
    final allSongs = await getAllSongs(userId: userId);
    return allSongs.where((song) {
      final lastUsed =
          song.lastPerformed ?? song.lastPracticed ?? song.dateAdded;
      return lastUsed.isBefore(thresholdDate);
    }).toList();
  }

  Future<void> addSong(SongModel song) async {
    // 1. Add to Remote (Firebase)
    try {
      await _songService.addSong(song);
    } catch (e) {
      debugPrint('Failed to add to remote: $e');
      throw Exception('Failed to add to server: $e');
    }

    // 2. Add to local Hive
    // We use put with ID to ensure consistency with sync
    await _songBox.put(song.id, song);
  }

  Future<void> updateSong(SongModel song) async {
    // Ensure we don't save 'favorite' tag to the shared model
    final tagsToSave = List<String>.from(song.tags)..remove('favorite');

    // Set updatedAt
    final songToSave = song.copyWith(
      tags: tagsToSave,
      updatedAt: DateTime.now(),
    );

    // 1. Update Remote (Firebase)
    try {
      await _songService.updateSong(songToSave);
    } catch (e) {
      debugPrint('Failed to update remote: $e');
      throw Exception('Failed to update server: $e');
    }

    final existingSong = _songBox.values.cast<SongModel?>().firstWhere(
      (s) => s?.id == song.id,
      orElse: () => null,
    );

    if (existingSong != null) {
      await _songBox.put(existingSong.key, songToSave);
    } else {
      await _songBox.put(song.id, songToSave);
    }
  }

  Future<void> deleteSong(String songId) async {
    if (kDebugMode) {
      print('SongRepository: Deleting song $songId');
    }

    // 1. Find local song to prepare soft delete object
    final songToDelete = _songBox.values.cast<SongModel?>().firstWhere(
      (s) => s?.id == songId,
      orElse: () => null,
    );

    if (songToDelete == null) {
      if (kDebugMode) {
        print('SongRepository: Local song not found, cannot soft delete');
      }
      return;
    }

    final deletedSong = songToDelete.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
      metadata: {'deletedAt': DateTime.now().toIso8601String()},
    );

    // 2. Update Remote (Firebase) - Soft Delete
    try {
      if (kDebugMode) {
        print('SongRepository: Calling SongService.updateSong (Soft Delete)');
      }
      // Use updateSong instead of deleteSong to preserve history
      await _songService.updateSong(deletedSong);

      if (kDebugMode) {
        print('SongRepository: Remote soft delete successful');
      }
    } catch (e) {
      debugPrint('Failed to update remote: $e');
      throw Exception('Failed to delete from server: $e');
    }

    // 3. Update local Hive
    await _songBox.put(songToDelete.key, deletedSong);
  }

  Future<void> markSongPerformed(String songId) async {
    final song = _songBox.values.cast<SongModel?>().firstWhere(
      (s) => s?.id == songId,
      orElse: () => null,
    );

    if (song != null) {
      final updatedSong = song.copyWith(
        lastPerformed: DateTime.now(),
        performanceCount: song.performanceCount + 1,
      );
      await _songBox.put(song.key, updatedSong);
    }
  }

  Future<void> markSongPracticed(String songId) async {
    final song = _songBox.values.cast<SongModel?>().firstWhere(
      (s) => s?.id == songId,
      orElse: () => null,
    );

    if (song != null) {
      final updatedSong = song.copyWith(
        lastPracticed: DateTime.now(),
        practiceCount: song.practiceCount + 1,
      );
      await _songBox.put(song.key, updatedSong);
    }
  }

  Future<void> addSongVersion(String songId, SongVersion version) async {
    final song = _songBox.values.cast<SongModel?>().firstWhere(
      (s) => s?.id == songId,
      orElse: () => null,
    );

    if (song != null) {
      final updatedVersions = List<SongVersion>.from(song.versions)
        ..add(version);
      final updatedSong = song.copyWith(versions: updatedVersions);
      await _songBox.put(song.key, updatedSong);
    } else {
      throw Exception('Song not found: $songId');
    }
  }

  Future<void> deleteSongVersion(String songId, String versionId) async {
    final song = _songBox.values.cast<SongModel?>().firstWhere(
      (s) => s?.id == songId,
      orElse: () => null,
    );

    if (song != null) {
      final updatedVersions = song.versions
          .where((v) => v.id != versionId)
          .toList();
      final updatedSong = song.copyWith(versions: updatedVersions);
      await _songBox.put(song.key, updatedSong);
    }
  }

  Future<void> addRecordingNote(String songId, RecordingNote note) async {
    final song = _songBox.values.cast<SongModel?>().firstWhere(
      (s) => s?.id == songId,
      orElse: () => null,
    );

    if (song != null) {
      final updatedNotes = List<RecordingNote>.from(song.recordingNotes)
        ..add(note);
      final updatedSong = song.copyWith(recordingNotes: updatedNotes);
      await _songBox.put(song.key, updatedSong);
    }
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

  Future<void> syncEverything() async {
    if (_lastSyncTime != null &&
        DateTime.now().difference(_lastSyncTime!).inMinutes < 10) {
      return;
    }

    syncCubit?.updateStatus(SyncStatus.updating);

    try {
      // 2. Get data from Firebase
      List<SongModel> remoteSongs = await _songService.fetchAllSongs();

      // 3. Save to Hive (Update if exists, add if new)
      for (var remoteSong in remoteSongs) {
        final localSong = _songBox.get(remoteSong.id);

        // If we have a local version, preserve the likeCount if the remote one is 0
        // (This is a workaround for when the backend doesn't support likeCount yet)
        if (localSong != null && remoteSong.likeCount == 0) {
          final mergedSong = remoteSong.copyWith(
            likeCount: localSong.likeCount,
          );
          await _songBox.put(remoteSong.id, mergedSong);
        } else {
          await _songBox.put(remoteSong.id, remoteSong);
        }
      }
      _lastSyncTime = DateTime.now();
      syncCubit?.updateStatus(SyncStatus.synced);
    } catch (e, stackTrace) {
      debugPrint('Sync Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      syncCubit?.updateStatus(SyncStatus.error);
    }
  }
}
