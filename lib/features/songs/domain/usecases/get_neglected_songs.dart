import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';

class GetNeglectedSongs {
  final SongRepository repository;

  GetNeglectedSongs(this.repository);

  Future<List<SongModel>> call(
    DateTime thresholdDate, {
    required int daysThreshold,
    String? userId,
  }) async {
    return await repository.getNeglectedSongs(
      thresholdDate,
      daysThreshold: daysThreshold,
      userId: userId,
    );
  }
}
