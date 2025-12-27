import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:praise_choir_app/config/locale_cubit.dart';
import 'package:praise_choir_app/config/routes.dart';
import 'package:praise_choir_app/core/theme/app_theme.dart' show AppTheme;
import 'package:praise_choir_app/core/theme/theme_cubit.dart';
import 'package:praise_choir_app/core/widgets/common/network/sync_cubit.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_cubit.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';
import 'package:praise_choir_app/l10n/arb/app_localizations.dart';

class ChoirApp extends StatelessWidget {
  const ChoirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SyncCubit(),
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) => AuthRepository()),
          RepositoryProvider(
            create: (context) => SongRepository(context.read<SyncCubit>()),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => ThemeCubit()),
            BlocProvider(create: (context) => LocaleCubit()),
            BlocProvider(
              create: (context) =>
                  AuthCubit(context.read<AuthRepository>())..appStarted(),
            ),
            BlocProvider(
              create: (context) => AdminCubit(context.read<AuthRepository>()),
            ),
            BlocProvider(
              create: (context) => SongCubit(
                repository: context.read<SongRepository>(),
                authCubit: context.read<AuthCubit>(),
              ),
            ),
          ],

          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return BlocBuilder<LocaleCubit, LocaleState>(
                builder: (context, state) {
                  return MaterialApp(
                    locale: state
                        .locale, // This ensures the app actually changes language
                    title: 'PCS',
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeMode,
                    onGenerateRoute: Routes.onGenerateRoute,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: const [Locale('en'), Locale('am')],
                    initialRoute: Routes.splash,
                    debugShowCheckedModeBanner: false,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
