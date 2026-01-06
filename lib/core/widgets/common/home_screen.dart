import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/widgets/common/network/network_status_indicator.dart';
import 'package:praise_choir_app/core/widgets/common/network/sync_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/song_cubit.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/favorites_screen.dart';
import 'package:praise_choir_app/features/songs/presentation/widgets/song_list_view.dart';
import 'package:praise_choir_app/features/songs/song_routes.dart';
import 'package:praise_choir_app/features/payment/payment_routes.dart';
import 'package:praise_choir_app/config/routes.dart';
import 'package:easy_localization/easy_localization.dart';

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
    return MultiBlocListener(
      listeners: [
        BlocListener<SyncCubit, SyncStatus>(
          listener: (context, state) {
            if (state == SyncStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please check your connection.'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state == SyncStatus.synced) {
              context.read<SongCubit>().loadSongs();
            }
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated || state is AuthError) {
              Navigator.pushReplacementNamed(context, Routes.login);
            } else if (state is AuthAuthenticated) {
              // Optional: Check if pending/guest
              if (state.user.role == 'guest') {
                // handle guest
              }
              if (state.user.approvalStatus == 'pending') {
                Navigator.pushReplacementNamed(context, Routes.pendingUser);
              }
            }
          },
        ),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          extendBodyBehindAppBar: false,
          extendBody: true,
          drawer: _buildFullVerticalMenu(context),
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: AppColors.primary,
            elevation: 0,
            actions: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => SongRoutes.navigateToAdd(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () =>
                        Navigator.pushNamed(context, SongRoutes.search),
                  ),
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
                ],
              ),
            ],

            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: const NetworkStatusIndicator(),
            centerTitle: true,
            bottom: TabBar(
              indicatorColor: AppColors.white,
              dividerColor: Colors.transparent,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white70,
              tabs: [
                Tab(text: "kembatgna".tr()),
                Tab(text: "amharic".tr()),
              ],
            ),
          ),
          body: Container(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.gray300
                : null,
            child: const TabBarView(
              children: [
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
    final authState = context.watch<AuthCubit>().state;
    final user = (authState is AuthAuthenticated) ? authState.user : null;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue.shade900,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.name[0].toUpperCase() ?? "U",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? "User",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user?.email ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.person_outline, "myProfile".tr(), () {}),
                _drawerItem(Icons.favorite_border, "favorites".tr(), () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  );
                }),
                _drawerItem(Icons.payment, "paymentHistory".tr(), () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    PaymentRoutes.userPaymentHistory,
                  );
                }),
                _drawerItem(Icons.settings_outlined, "settings".tr(), () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.userSettings);
                }),
                _drawerItem(Icons.help_outline, "support".tr(), () {}),
                _coolDivider(context),
                _drawerItem(
                  Icons.logout_rounded,
                  "logOut".tr(),
                  () => context.read<AuthCubit>().logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      tileColor: Theme.of(context).drawerTheme.backgroundColor,
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}

Widget _coolDivider(BuildContext context) {
  final color = Theme.of(context).colorScheme.onSurface;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.withValues(color, 0.0),
                  AppColors.withValues(color, 0.12),
                  AppColors.withValues(color, 0.0),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    ),
  );
}
