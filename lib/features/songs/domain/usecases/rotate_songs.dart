import 'package:praise_choir_app/features/songs/data/song_repository.dart';
import 'package:praise_choir_app/features/songs/domain/entities/song_entity.dart';

class RotateSongs {
  final SongRepository repository;

  RotateSongs(this.repository);

  Future<List<SongEntity>> call({
    int oldSongsCount = 3,
    int newSongsCount = 2,
    int favoriteSongsCount = 2,
  }) async {
    return await repository.getRotatedSongs(
      oldSongsCount: oldSongsCount,
      newSongsCount: newSongsCount,
      favoriteSongsCount: favoriteSongsCount,
    );
  }
}
