import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:praise_choir_app/core/widgets/common/home_screen.dart';
import 'package:praise_choir_app/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/chat/data/chat_repository.dart';
import 'package:praise_choir_app/features/events/presentation/screens/announcement_board.dart';
import '../../../features/chat/presentation/screens/chat_list_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  final ValueNotifier<bool> _isChatVisible = ValueNotifier(false);

  @override
  void dispose() {
    _isChatVisible.dispose();
    super.dispose();
  }

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
        onTabChanged: (index) {
          // Determine if the new tab is the Chat tab
          // Chat tab index depends on role
          int chatIndex = -1;
          if (role != 'guest') {
            chatIndex = 2; // 0: Home, 1: Announcement, 2: Chat
          }

          _isChatVisible.value = (index == chatIndex);
        },
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
              screen: const AnnouncementBoard(),
              item: ItemConfig(
                icon: const Icon(Icons.announcement),
                title: "Announcements",
              ),
            ),
            PersistentTabConfig(
              screen: ChatListScreen(isVisibleNotifier: _isChatVisible),
              item: ItemConfig(
                icon: StreamBuilder<int>(
                  stream: (authState is AuthAuthenticated)
                      ? context.read<ChatRepository>().watchUnreadCount(
                          authState.user.id,
                        )
                      : const Stream.empty(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: const Icon(Icons.chat),
                    );
                  },
                ),
                title: "Chat",
              ),
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
