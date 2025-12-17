import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:praise_choir_app/config/routes.dart';
import 'package:praise_choir_app/core/theme/app_theme.dart' show AppTheme;
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/l10n/arb/app_localizations.dart';

class ChoirApp extends StatelessWidget {
  const ChoirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: MultiBlocProvider(
        providers: [
          // In ChoirApp build method
          BlocProvider(
            create: (context) => AuthCubit(AuthRepository())..appStarted(),
          ),
          BlocProvider(create: (context) => AdminCubit(AuthRepository())),
        ],

        child: MaterialApp(
          title: 'PCS',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          onGenerateRoute: Routes.generateRoute,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US'), Locale('am', 'ET')],
          initialRoute: Routes.splash,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
