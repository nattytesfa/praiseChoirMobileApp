import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/config/routes.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/songs/song_routes.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAuthNavigation(context, state.user);
      });
    }
  }

  void _handleAuthNavigation(BuildContext context, dynamic user) {
    if (user.approvalStatus == 'pending' || user.approvalStatus == 'denied') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.pendingUser,
        (route) => false,
      );
    } else if (user.role == 'guest') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        SongRoutes.songLibrary,
        (route) => false,
      );
    } else {
      Navigator.pushReplacementNamed(context, Routes.mainNavigationShell);
    }
  }

  void _submitEmailAndPassword() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      context.read<AuthCubit>().emailSignIn(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.gray50
          : null,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.blue.withValues(),
            ),
          ),

          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                _handleAuthNavigation(context, state.user);
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is AuthLoading || state is AuthAuthenticated) {
                return const Center(child: CircularProgressIndicator());
              }
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Language switch
                        Align(
                          alignment: Alignment.topRight,
                          child: _buildLanguageToggle(context),
                        ),
                        const SizedBox(height: 40),

                        // Music Icon with Neon Glow
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accent,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.music_note_rounded,
                            size: 50,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'welcomeMessage'.tr(),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'enterCredentials'.tr(),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _textFieldDecoration(
                          controller: _emailController,
                          controllerIcon: Icons.alternate_email_rounded,
                          label: 'email',
                          keyboardType: TextInputType.emailAddress,
                          errorMessage: 'enterEmail',
                        ),
                        const SizedBox(height: 20),
                        _textFieldDecoration(
                          controller: _passwordController,
                          controllerIcon: Icons.lock_person_rounded,
                          label: 'password',
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          errorMessage: 'enterPassword',
                        ),
                        const SizedBox(height: 40),
                        if (state is AuthLoading)
                          CircularProgressIndicator(color: AppColors.accent)
                        else ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitEmailAndPassword,
                              child: Text(
                                'signIn'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Sign up link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('noAccount'.tr()),
                              const SizedBox(width: 15),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                ),
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/signup'),
                                child: Text('signUp'.tr()),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    final isAmharic = context.locale.languageCode == 'am';
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langChip(
            'EN',
            !isAmharic,
            () => context.setLocale(const Locale('en')),
          ),
          _langChip(
            'አማ',
            isAmharic,
            () => context.setLocale(const Locale('am')),
          ),
          const SizedBox(height: 5),
          IconButton(
            icon: Icon(
              // Logic: If dark mode is active, show the "Sun" icon, else "Moon"
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  Widget _langChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? Colors.white
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _textFieldDecoration({
    required TextEditingController controller,
    required controllerIcon,
    required String label,
    required TextInputType keyboardType,
    required String errorMessage,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(controllerIcon),
        labelText: label.tr(),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return errorMessage.tr();
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
