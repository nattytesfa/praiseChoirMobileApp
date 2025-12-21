import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/config/routes.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationcontroller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Initialize animations here
    context.read<AuthCubit>().appStarted();
  }

  void _initializeAnimations() {
    _animationcontroller = AnimationController(
      vsync: this,
      duration: Duration(microseconds: 5000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationcontroller,
        curve: const Interval(0.5, 0.1, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationcontroller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animationcontroller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // As soon as the Cubit emits a result, navigate!
        if (state is AuthAuthenticated) {
          // 1. Check Guest Role first
          if (state.user.role == 'guest') {
            Navigator.pushReplacementNamed(context, Routes.home);
          }

          // 2. Check Approval Status
          if (state.user.approvalStatus == 'pending' ||
              state.user.approvalStatus == 'denied') {
            Navigator.pushReplacementNamed(context, Routes.pendingUser);
          }
        } else if (state is AuthUnauthenticated || state is AuthError) {
          Navigator.pushReplacementNamed(context, Routes.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryLight,
        body: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationcontroller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
                // }, child: Column(mainAxisSize: MainAxisSize.min, children: [Image.asset('assets/images/splash_logo.png', width: 150, height: 150,), SizedBox(height: 20,), Text('Praise Choir', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),)],
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.music_note,
                      size: 64,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Praise Choir',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Harmony in Worship',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
