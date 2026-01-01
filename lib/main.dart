import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:praise_choir_app/choir_app.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_model.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_report_model.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/events/data/models/announcement_model.dart';
import 'package:praise_choir_app/features/chat/data/models/chat_model.dart';
import 'package:praise_choir_app/features/chat/data/models/message_model.dart';
import 'package:praise_choir_app/firebase_options.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();

  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(SongModelAdapter());
  Hive.registerAdapter(SongVersionAdapter());
  Hive.registerAdapter(RecordingNoteAdapter());
  Hive.registerAdapter(PaymentModelAdapter());
  Hive.registerAdapter(PaymentStatusAdapter());
  Hive.registerAdapter(PaymentReportModelAdapter());

  // Chat adapters
  Hive.registerAdapter(ChatModelAdapter());
  Hive.registerAdapter(ChatTypeAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(VoiceMessageModelAdapter());
  Hive.registerAdapter(MessageTypeAdapter());
  Hive.registerAdapter(MessageStatusAdapter());

  // Event adapters
  Hive.registerAdapter(AnnouncementModelAdapter());

  await Hive.openBox('settings');
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<SongModel>('songs');
  await Hive.openBox('favorites');
  await Hive.openBox<PaymentModel>('payments');

  // Chat boxes
  await Hive.openBox<ChatModel>(HiveBoxes.chat);
  await Hive.openBox<MessageModel>('messages');

  // Event boxes
  await Hive.openBox<AnnouncementModel>('announcements');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('am')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ChoirApp(),
    ),
  );
}
