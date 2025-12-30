import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:praise_choir_app/choir_app.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_model.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_report_model.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/events/data/models/event_model.dart';
import 'package:praise_choir_app/features/events/data/models/event_type.dart';
import 'package:praise_choir_app/features/events/data/models/announcement_model.dart';
import 'package:praise_choir_app/features/events/data/models/poll_model.dart';
import 'package:praise_choir_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();

  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(SongModelAdapter());
  Hive.registerAdapter(SongVersionAdapter());
  Hive.registerAdapter(RecordingNoteAdapter());
  Hive.registerAdapter(PaymentModelAdapter());
  Hive.registerAdapter(PaymentStatusAdapter());
  Hive.registerAdapter(PaymentReportModelAdapter());

  // Event adapters
  Hive.registerAdapter(EventModelAdapter());
  Hive.registerAdapter(EventTypeAdapter());
  Hive.registerAdapter(AnnouncementModelAdapter());
  Hive.registerAdapter(PollModelAdapter());
  Hive.registerAdapter(PollOptionAdapter());

  await Hive.openBox('settings');
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<SongModel>('songs');
  await Hive.openBox('favorites');
  await Hive.openBox<PaymentModel>('payments');

  // Event boxes
  await Hive.openBox<EventModel>('events');
  await Hive.openBox<AnnouncementModel>('announcements');
  await Hive.openBox<PollModel>('polls');

  runApp(ChoirApp());
}
