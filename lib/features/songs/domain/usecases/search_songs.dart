import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';

class SearchSongs {
  final SongRepository repository;

  SearchSongs(this.repository);

  Future<List<SongModel>> call(String query) async {
    if (query.isEmpty) {
      return await repository.getAllSongs();
    }
    return await repository.searchSongs(query);
  }
}
