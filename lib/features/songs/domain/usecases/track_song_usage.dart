import 'package:praise_choir_app/features/songs/data/song_repository.dart';

class TrackSongUsage {
  final SongRepository repository;

  TrackSongUsage(this.repository);

  Future<void> call(String songId, {bool isPerformance = false}) async {
    if (isPerformance) {
      await repository.markSongPerformed(songId);
    } else {
      await repository.markSongPracticed(songId);
    }
  }
}
