import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/config/routes.dart';
import 'package:praise_choir_app/core/services/connectivity_service.dart';
import 'package:praise_choir_app/core/theme/app_theme.dart' show AppTheme;
import 'package:praise_choir_app/core/theme/theme_cubit.dart';
import 'package:praise_choir_app/core/widgets/common/network/sync_cubit.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/events/data/repositories/event_repository_impl.dart';
import 'package:praise_choir_app/features/events/domain/repositories/event_repository.dart';
import 'package:praise_choir_app/features/events/presentation/cubit/event_cubit.dart';
import 'package:praise_choir_app/features/payment/data/payment_repository.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_cubit.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';
import 'package:praise_choir_app/features/chat/data/chat_repository.dart';
import 'package:praise_choir_app/features/chat/presentation/cubit/chat_cubit.dart';

class ChoirApp extends StatelessWidget {
  const ChoirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SyncCubit(),
      child: ChangeNotifierProvider(
        create: (context) => ConnectivityService(),
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider(create: (context) => AuthRepository()),
            RepositoryProvider(
              create: (context) => SongRepository(context.read<SyncCubit>()),
            ),
            RepositoryProvider(create: (context) => PaymentRepository()),
            RepositoryProvider<EventRepository>(
              create: (context) => EventRepositoryImpl(
                connectivityService: context.read<ConnectivityService>(),
              ),
            ),
            RepositoryProvider(create: (context) => ChatRepository()),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => PaymentCubit()),
              BlocProvider(create: (context) => ThemeCubit()),
              BlocProvider(
                create: (context) =>
                    AuthCubit(context.read<AuthRepository>())..appStarted(),
              ),
              BlocProvider(
                create: (context) => AdminCubit(
                  context.read<AuthRepository>(),
                  context.read<SongRepository>(),
                ),
              ),
              BlocProvider(
                create: (context) => SongCubit(
                  repository: context.read<SongRepository>(),
                  authCubit: context.read<AuthCubit>(),
                ),
              ),
              BlocProvider(
                create: (context) =>
                    EventCubit(eventRepository: context.read<EventRepository>())
                      ..loadEvents(),
              ),
              BlocProvider(
                create: (context) =>
                    ChatCubit(repository: context.read<ChatRepository>()),
              ),
            ],

            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return MaterialApp(
                  locale: context.locale,
                  title: 'PCS',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  onGenerateRoute: Routes.onGenerateRoute,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  initialRoute: Routes.splash,
                  debugShowCheckedModeBanner: false,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
