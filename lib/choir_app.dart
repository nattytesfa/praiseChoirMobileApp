import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
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
import 'package:praise_choir_app/update_checker.dart';

class _AppLifeCycleWrapper extends StatefulWidget {
  final Widget child;
  const _AppLifeCycleWrapper({required this.child});

  @override
  _AppLifeCycleWrapperState createState() => _AppLifeCycleWrapperState();
}

class _AppLifeCycleWrapperState extends State<_AppLifeCycleWrapper> {
  Timer? _autoGenTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateChecker.checkForUpdates(context);
      _scheduleAutoGeneration();
    });
  }

  @override
  void dispose() {
    _autoGenTimer?.cancel();
    super.dispose();
  }

  Future<void> _scheduleAutoGeneration() async {
    await _tryAutoGenerate();

    _autoGenTimer = Timer.periodic(const Duration(hours: 6), (_) {
      _tryAutoGenerate();
    });
  }

  Future<void> _tryAutoGenerate() async {
    try {
      final authRepo = AuthRepository();
      final paymentRepo = PaymentRepository();
      final allUsers = await authRepo.getAllUsers();
      final activeIds = allUsers
          .where((u) => u.isActive)
          .map((u) => u.id)
          .toList();
      await paymentRepo.generateIfDue(activeIds);
    } catch (_) {
      // Silently fail - auto-generation is best-effort
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

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
                final isAmharic = context.locale.languageCode == 'am';
                final fontFamily = isAmharic ? 'Benaiah' : null;

                ThemeData theme = AppTheme.lightTheme;
                ThemeData darkTheme = AppTheme.darkTheme;

                if (fontFamily != null) {
                  theme = theme.copyWith(
                    textTheme: theme.textTheme.apply(fontFamily: fontFamily),
                    primaryTextTheme: theme.primaryTextTheme.apply(
                      fontFamily: fontFamily,
                    ),
                  );
                  darkTheme = darkTheme.copyWith(
                    textTheme: darkTheme.textTheme.apply(
                      fontFamily: fontFamily,
                    ),
                    primaryTextTheme: darkTheme.primaryTextTheme.apply(
                      fontFamily: fontFamily,
                    ),
                  );
                }

                return MaterialApp(
                  locale: context.locale,
                  title: 'PCS',
                  theme: theme,
                  darkTheme: darkTheme,
                  themeMode: themeMode,
                  onGenerateRoute: Routes.onGenerateRoute,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  initialRoute: Routes.login,
                  debugShowCheckedModeBanner: false,
                  builder: (context, child) =>
                      _AppLifeCycleWrapper(child: child!),
                  onUnknownRoute: (settings) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => SystemNavigator.pop(),
                    );
                    return MaterialPageRoute(
                      builder: (_) => const SizedBox.shrink(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
