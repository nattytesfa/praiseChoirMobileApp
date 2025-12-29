import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';

class GetSongs {
  final SongRepository repository;

  GetSongs(this.repository);

  Future<List<SongModel>> call({String? userId}) async {
    return await repository.getAllSongs(userId: userId);
  }
}
