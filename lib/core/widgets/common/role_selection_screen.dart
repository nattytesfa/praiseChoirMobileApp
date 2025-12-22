import 'package:flutter/material.dart';
import 'package:praise_choir_app/config/routes.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String email;
  // final String verificationId;
  final UserModel? user;

  const RoleSelectionScreen({
    super.key,
    required this.email,
    // required this.verificationId,
    this.user,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  final Map<String, Map<String, dynamic>> _roles = {
    'leader': {
      'title': 'Leader',
      'description':
          'Full administrative access to manage choir operations, members, and finances',
      'icon': Icons.admin_panel_settings,
      'color': AppColors.leader,
      'permissions': [
        'Manage all songs',
        'Manage members & roles',
        'View financial reports',
        'Send announcements',
        'System administration',
      ],
    },
    'songwriter': {
      'title': 'Songwriter Group',
      'description':
          'Song management privileges to prepare and organize choir songs',
      'icon': Icons.music_note,
      'color': AppColors.songwriter,
      'permissions': [
        'Add and edit songs',
        'Attach audio recordings',
        'Prepare song sets',
        'Coordinate with leaders',
      ],
    },
    'prayer_group': {
      'title': 'Prayer Group',
      'description':
          'Special access for prayer group activities and communications',
      'icon': Icons.people,
      'color': AppColors.prayerGroup,
      'permissions': [
        'Access prayer group chats',
        'View prayer schedules',
        'Coordinate group activities',
      ],
    },
    'member': {
      'title': 'Member',
      'description':
          'Standard access to view songs, make payments, and participate in choir activities',
      'icon': Icons.person,
      'color': AppColors.member,
      'permissions': [
        'View song library',
        'Make monthly payments',
        'Participate in chats',
        'View events calendar',
      ],
    },
  };

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
    });
  }



  void moveToAnotherPage() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.adminDashboard,
      (route) => false,
    );
  }

  // void _completeRegistration() {
  //   if (_selectedRole == null) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Please select a role')));
  //     return;
  //   }

  //   // Proceed with OTP verification (AuthCubit will create/save the user)
  //   // context.read<AuthCubit>().verifyOtp(widget.verificationId, 'demo_otp');
  // }

  Widget _buildRoleCard(String role, Map<String, dynamic> roleData) {
    final isSelected = _selectedRole == role;
    final color = roleData['color'] as Color;
    final icon = roleData['icon'] as IconData;
    final title = roleData['title'] as String;
    final description = roleData['description'] as String;
    final permissions = roleData['permissions'] as List<String>;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? color.withValues() : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : AppColors.borderLight,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _selectRole(role),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: color, size: 24),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Permissions
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permissions:',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...permissions.map(
                    (permission) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, color: color, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              permission,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.popAndPushNamed(context, Routes.login),
        ),
      ),
      // body: BlocListener<AuthCubit, AuthState>(
      //   listener: (context, state) {
      //     if (state is AuthAuthenticated) {
      //       Navigator.pushNamedAndRemoveUntil(
      //         context,
      //         '/songs',
      //         (route) => false,
      //       );
      //     } else if (state is AuthError) {
      //       ScaffoldMessenger.of(
      //         context,
      //       ).showSnackBar(SnackBar(content: Text(state.message)));
      //     }
      //   },
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Choose Your Role in the Choir',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your role determines what features you can access in the app. '
              'Leaders will verify your selection.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Role Selection
            Expanded(
              child: ListView(
                children: _roles.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRoleCard(entry.key, entry.value),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: moveToAnotherPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedRole != null
                    ? AppColors.getRoleColor(_selectedRole!)
                    : AppColors.gray400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _selectedRole != null
                    ? 'Continue as ${_roles[_selectedRole]!['title']}'
                    : 'Select a Role to Continue',
                style: AppTextStyles.buttonLarge,
              ),
            ),

            // Continue Button
            // BlocBuilder<AuthCubit, AuthState>(
            //   builder: (context, state) {
            //     if (state is AuthLoading) {
            //       return const LoadingIndicator();
            //     }

            //     return SizedBox(
            //       width: double.infinity,
            //       child: ElevatedButton(
            //         onPressed: _completeRegistration,
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: _selectedRole != null
            //               ? AppColors.getRoleColor(_selectedRole!)
            //               : AppColors.gray400,
            //           foregroundColor: Colors.white,
            //           padding: const EdgeInsets.symmetric(vertical: 16),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //         ),
            //         child: Text(
            //           _selectedRole != null
            //               ? 'Continue as ${_roles[_selectedRole]!['title']}'
            //               : 'Select a Role to Continue',
            //           style: AppTextStyles.buttonLarge,
            //         ),
            //       ),
            //     );
            // },
            // ),
            const SizedBox(height: 16),

            // Help Text
            // Text(
            //   'Note: Your role selection will be reviewed by choir leaders. '
            //   'You can request role changes later if needed.',
            //   style: AppTextStyles.caption.copyWith(
            //     color: AppColors.textDisabled,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
      // ),
    );
  }
}
