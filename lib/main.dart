import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:praise_choir_app/choir_app.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();

  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(SongModelAdapter());
  Hive.registerAdapter(SongVersionAdapter());
  Hive.registerAdapter(RecordingNoteAdapter());

  await Hive.openBox('settings');
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<SongModel>('songs');
  runApp(ChoirApp());
}
