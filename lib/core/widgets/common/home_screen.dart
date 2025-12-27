import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/theme_cubit.dart';
import 'package:praise_choir_app/core/widgets/common/network/network_status_indicator.dart';
import 'package:praise_choir_app/core/widgets/common/network/sync_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_cubit.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/favorites_screen.dart';
import 'package:praise_choir_app/features/songs/presentation/widgets/song_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // SCENARIO 1: App Startup
    // Trigger sync as soon as the home screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSync();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // SCENARIO 3: On Resume
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back from background (e.g., user checked a text then came back)
      _performSync();
    }
  }

  Future<void> _performSync() async {
    try {
      context.read<SyncCubit>().setSyncing(true);
    } catch (_) {
      // If SyncCubit isn't available for some reason, proceed without updating UI
    }

    try {
      await context.read<SongRepository>().syncEverything();
    } catch (e) {
      // Log or handle sync error if desired; avoid crashing the app
    } finally {
      try {
        if (mounted) {
          context.read<SyncCubit>().setSyncing(false);
        }
      } catch (_) {
        // ignore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SyncCubit, SyncStatus>(
      listener: (context, state) {
        if (state == SyncStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sync failed. Please check your connection.'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state == SyncStatus.synced) {
          // Reload songs when sync is complete
          context.read<SongCubit>().loadSongs();
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          extendBodyBehindAppBar: false,
          extendBody: true,
          drawer: _buildFullVerticalMenu(context),
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            // RIGHT: Profile Menu
            actions: [
              Row(
                children: [
                  BlocBuilder<SyncCubit, SyncStatus>(
                    builder: (context, state) {
                      if (state == SyncStatus.updating) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                      return IconButton(
                        icon: const Icon(Icons.sync),
                        onPressed: () {
                          // This triggers the repository method we updated earlier
                          context.read<SongRepository>().syncEverything();
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      // Logic: If dark mode is active, show the "Sun" icon, else "Moon"
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // This calls your Cubit to toggle the global state
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    onPressed: () => context.read<AuthCubit>().logout(context),
                  ),
                ],
              ),
            ],

            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),

            // MIDDLE: Network Status Animation
            title: const NetworkStatusIndicator(),
            centerTitle: true,
            // TABS: For English and Amharic Song Filtering
            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: "Kembatgna"),
                Tab(text: "Amharic"),
              ],
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [
                        AppColors.darkBackground,
                        AppColors.gray900,
                      ] // Dark mode gradient
                    : [
                        AppColors.primary,
                        AppColors.primaryLight,
                      ], // Light mode gradient
              ),
            ),
            child: TabBarView(
              children: const [
                SongListView(language: 'en'),
                SongListView(language: 'am'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullVerticalMenu(BuildContext context) {
    // Access user from your AuthCubit
    final authState = context.watch<AuthCubit>().state;
    final user = (authState is AuthAuthenticated) ? authState.user : null;

    return Drawer(
      width:
          MediaQuery.of(context).size.width *
          0.6, // Takes 60% width, 100% height
      child: Column(
        children: [
          // 1. Full Height Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade900),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name[0].toUpperCase() ?? "U",
                style: TextStyle(fontSize: 24, color: Colors.blue.shade900),
              ),
            ),
            accountName: Text(
              user?.name ?? "User",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(user?.email ?? ""),
          ),

          // 2. Scrollable Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.person_outline, "My Profile", () {}),
                _drawerItem(Icons.favorite_border, "Favorites", () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  );
                }),
                _drawerItem(Icons.payment, "Payment History", () {}),
                _drawerItem(Icons.settings_outlined, "Settings", () {}),
                const Divider(),
                _drawerItem(Icons.help_outline, "Support", () {}),
                _drawerItem(Icons.info_outline, "About App", () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
