import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/config/routes.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Inside your HomeScreen or Sidebar
  void _navigateToAdmin(BuildContext context) {
    // We check the role one last time for safety before navigating
    final state = context.read<AuthCubit>().state;

    if (state is AuthAuthenticated && state.user.role == 'admin') {
      // This string must match the one in your AdminRoutes
      Navigator.pushNamed(context, Routes.adminDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      body: CustomScrollView(
        slivers: [
          // 1. Beautiful Header
          _buildHeader(context),

          // 2. Dashboard Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Actions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // Grid of Actions
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      _buildActionCard(
                        context,
                        title: "Song Library",
                        icon: Icons.music_note_rounded,
                        color: AppColors.primaryLight,
                        onTap: () => Navigator.pushNamed(context, Routes.home),
                      ),
                      _buildActionCard(
                        context,
                        title: "Rehearsals",
                        icon: Icons.event_rounded,
                        color: Colors.orangeAccent,
                        onTap: () {}, // Future feature
                      ),

                      // THE LEADER TOOLS CARD (Conditional)
                      _buildLeaderCard(context),

                      _buildActionCard(
                        context,
                        title: "My Profile",
                        icon: Icons.person_rounded,
                        color: Colors.blueAccent,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primaryLight,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryLight,
                AppColors.primaryLight.withValues(),
              ],
            ),
          ),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              String name = "Singer";
              if (state is AuthAuthenticated) name = state.user.name;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Welcome, $name!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    state is AuthAuthenticated
                        ? state.user.role.toUpperCase()
                        : "",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () => context.read<AuthCubit>().logout(),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderCard(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated && state.user.role == 'admin') {
          return _buildActionCard(
            context,
            title: "Leader Tools",
            icon: Icons.admin_panel_settings_rounded,
            color: Colors.redAccent,
            onTap: () => _navigateToAdmin(context),
          );
        }
        return const SizedBox.shrink(); // Hide if not admin
      },
    );
  }
}
