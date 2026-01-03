import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/config/routes.dart';
import 'package:praise_choir_app/core/utils/validators.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/songs/song_routes.dart';

import '../../../../core/theme/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'member';
  final bool isLoading = false;
  String? _errorMessage;

  final List<Map<String, String>> _roles = [
    {'value': 'member', 'label': 'member'},
    {'value': 'guest', 'label': 'guest'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<AuthCubit>().signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: _selectedRole,
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _textFieldDecoration({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required String? Function(String?)? validator,
    String? hintText,
    bool obscureText = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        hintText: hintText,
      ),
      controller: controller,
      validator: validator,
      obscureText: obscureText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToLogin,
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            if (user.role == 'guest') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                SongRoutes.songLibrary,
                (route) => false,
              );
            } else if (user.approvalStatus == 'pending') {
              // Members go to the waiting room
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.pendingUser,
                (route) => false,
              );
            } else {
              // Approved members/leaders go home
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.mainNavigationShell,
                (route) => false,
              );
            }
          } else if (state is AuthError) {
            // Handle the error state here too
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      'joinPraiseChoir'.tr(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'createAccountSubtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _textFieldDecoration(
                      controller: _nameController,
                      labelText: 'fullName'.tr(),
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enterNameError'.tr();
                        }
                        if (value.length < 2) {
                          return 'nameLengthError'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _textFieldDecoration(
                      controller: _emailController,
                      labelText: 'emailAddress'.tr(),
                      prefixIcon: Icons.email,
                      validator: (value) {
                        return Validators.email(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _textFieldDecoration(
                      controller: _passwordController,
                      labelText: 'password'.tr(),
                      prefixIcon: Icons.lock,
                      hintText: 'passwordHint'.tr(),
                      obscureText: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),
                    _textFieldDecoration(
                      controller: _confirmPasswordController,
                      labelText: 'confirmPassword'.tr(),
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'passwordsDoNotMatch'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Role selection
                    Text(
                      'selectRole'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'roleDisclaimer1'.tr(),
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'roleDisclaimer2'.tr(),
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    DropdownMenu<String>(
                      expandedInsets: EdgeInsets.zero,
                      initialSelection: _selectedRole,
                      leadingIcon: const Icon(Icons.group),
                      alignmentOffset: Offset(0, 10),
                      menuStyle: MenuStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          AppColors.darkBackground,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      dropdownMenuEntries: [
                        for (var role in _roles)
                          DropdownMenuEntry<String>(
                            value: role['value']!,
                            label: role['label']!.tr(),
                          ),
                      ],
                      onSelected: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 60),

                    // Sign up button
                    ElevatedButton(
                      onPressed: isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            )
                          : Text(
                              'createAccount'.tr(),
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
