import 'package:praise_choir_app/features/songs/data/song_repository.dart';

class TrackSongUsage {
  final SongRepository repository;

  TrackSongUsage(this.repository);

  Future<void> markPerformed(String songId) async {
    return await repository.markSongPerformed(songId);
  }

  Future<void> markPracticed(String songId) async {
    return await repository.markSongPracticed(songId);
  }
}
