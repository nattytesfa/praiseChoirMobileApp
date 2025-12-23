import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:praise_choir_app/core/widgets/common/home_screen.dart';
import 'package:praise_choir_app/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/samples/announcement_screen.dart';
import 'package:praise_choir_app/samples/chat_screen.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the user role from AuthCubit to decide which tabs to show
    final authState = context.watch<AuthCubit>().state;
    final role = (authState is AuthAuthenticated)
        ? authState.user.role
        : 'guest';

    return Scaffold(
      extendBody: true,
      body: PersistentTabView(
        tabs: [
          // TAB 1: ALWAYS VISIBLE
          PersistentTabConfig(
            screen: const HomeScreen(), // Your existing HomeScreen code
            item: ItemConfig(
              icon: const Icon(Icons.music_note),
              title: "Songs",
            ),
          ),

          // TAB 2 & 3: HIDDEN FROM GUESTS
          if (role != 'guest') ...[
            PersistentTabConfig(
              screen: const AnnouncementScreen(),
              item: ItemConfig(icon: const Icon(Icons.campaign), title: "News"),
            ),
            PersistentTabConfig(
              screen: const ChatScreen(),
              item: ItemConfig(icon: const Icon(Icons.chat), title: "Chat"),
            ),
          ],

          // TAB 4: ONLY FOR ADMINS
          if (role == 'admin' || role == 'leader')
            PersistentTabConfig(
              screen: const AdminDashboard(),
              item: ItemConfig(
                icon: const Icon(Icons.security),
                title: "Admin",
              ),
            ),
        ],

        navBarBuilder: (navBarConfig) =>
            Style1BottomNavBar(navBarConfig: navBarConfig),
      ),
    );
  }
}
