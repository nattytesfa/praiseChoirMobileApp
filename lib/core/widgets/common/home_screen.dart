import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/widgets/common/network/network_status_indicator.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/songs/data/song_repository.dart';

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
      context.read<SongRepository>().syncEverything();
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
      context.read<SongRepository>().syncEverything();
    }
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        drawer: _buildFullVerticalMenu(context),
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          leadingWidth: 100,
          // RIGHT: Profile Menu
          actions: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.brightness_4_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  onPressed: () => context.read<AuthCubit>().logout(context),
                ),
              ],
            ),
          ],

          // LEFT: Logout and Theme Toggle
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
              Tab(text: "English"),
              Tab(text: "አማርኛ"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // ... must match the number of widgets here!
            Center(child: Text("English Song List")), // Widget for Tab 1
            Center(child: Text("የአማርኛ መዝሙር ዝርዝር")), // Widget for Tab 2
            // SongListView(language: 'en'), // Placeholder for English songs
            // SongListView(language: 'am'), // Placeholder for Amharic songs
          ],
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
                _drawerItem(Icons.favorite_border, "Favorites", () {}),
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
