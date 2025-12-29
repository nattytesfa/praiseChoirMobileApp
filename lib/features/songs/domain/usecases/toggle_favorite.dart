import 'package:praise_choir_app/features/songs/data/song_repository.dart';

class ToggleFavorite {
  final SongRepository repository;

  ToggleFavorite(this.repository);

  Future<void> call(String songId, String userId) async {
    return await repository.toggleLocalFavorite(songId, userId);
  }
}
