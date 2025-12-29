import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';

class ManageSongVersions {
  final SongRepository repository;

  ManageSongVersions(this.repository);

  Future<void> addVersion(String songId, SongVersion version) async {
    return await repository.addSongVersion(songId, version);
  }

  Future<void> deleteVersion(String songId, String versionId) async {
    return await repository.deleteSongVersion(songId, versionId);
  }
}
