import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';

class FilterSongs {
  final SongRepository repository;

  FilterSongs(this.repository);

  Future<List<SongModel>> byTag(String tag, {String? userId}) async {
    return await repository.getSongsByTag(tag, userId: userId);
  }
}
