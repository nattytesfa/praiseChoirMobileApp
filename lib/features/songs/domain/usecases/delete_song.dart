import 'package:praise_choir_app/features/songs/data/song_repository.dart';

class DeleteSong {
  final SongRepository repository;

  DeleteSong(this.repository);

  Future<void> call(String songId) async {
    return await repository.deleteSong(songId);
  }
}
