import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';

class SearchSongs {
  final SongRepository repository;

  SearchSongs(this.repository);

  Future<List<SongModel>> call(String query, {String? userId}) async {
    if (query.isEmpty) {
      return await repository.getAllSongs(userId: userId);
    }
    return await repository.searchSongs(query, userId: userId);
  }
}
