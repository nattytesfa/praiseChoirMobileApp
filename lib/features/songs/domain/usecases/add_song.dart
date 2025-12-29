import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';

class AddSong {
  final SongRepository repository;

  AddSong(this.repository);

  Future<void> call(SongModel song) async {
    return await repository.addSong(song);
  }
}
