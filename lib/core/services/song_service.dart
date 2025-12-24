import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';

class SongService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<SongModel>> fetchAllSongs() async {
    try {
      // Fetching from 'songs' collection
      final snapshot = await _firestore.collection('songs').get();

      return snapshot.docs.map((doc) {
        // We pass the data and the doc ID to our model's factory
        return SongModel.fromJson(doc.data()..['id'] = doc.id);
      }).toList();
    } catch (e) {
      throw Exception("Failed to fetch songs from Firebase: $e");
    }
  }
}
