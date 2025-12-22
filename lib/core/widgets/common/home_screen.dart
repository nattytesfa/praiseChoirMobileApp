import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/widgets/common/network_status_indicator.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We watch the AuthCubit to get user info for the Profile Menu
    final authState = context.watch<AuthCubit>().state;
    final user = (authState is AuthAuthenticated) ? authState.user : null;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          leadingWidth: 100,
          // RIGHT: Profile Menu
          actions: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  onPressed: () => context.read<AuthCubit>().logout(context),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.brightness_4_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],

          // LEFT: Logout and Theme Toggle
          leading: _buildProfileMenu(context, user),
          
          // MIDDLE: Network Status Animation
          title: const NetworkStatusIndicator(),
          centerTitle: true,
          // actions: [_buildProfileMenu(context, user)],
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
            // SongListView(language: 'en'), // Placeholder for English songs
            // SongListView(language: 'am'), // Placeholder for Amharic songs
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context, dynamic user) {
    return PopupMenuButton(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white24,
          child: Text(
            user?.name[0].toUpperCase() ?? "U",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
      itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? "User",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(user?.email ?? "", style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  user?.role.toUpperCase() ?? "GUEST",
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              const Divider(),
            ],
          ),
        ),
        const PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.person_outline),
            title: Text("My Profile"),
          ),
        ),
        const PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text("Favorites"),
          ),
        ),
        const PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.payment),
            title: Text("Payment History"),
          ),
        ),
        const PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          enabled: false,
          child: Center(
            child: Text("Version 1.0.0", style: TextStyle(fontSize: 10)),
          ),
        ),
      ],
    );
  }
}

//   Widget _buildHeader(BuildContext context) {
//     return SliverAppBar(
//       expandedHeight: 200,
//       pinned: true,
//       backgroundColor: AppColors.primaryLight,
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 AppColors.primaryLight,
//                 AppColors.primaryLight.withValues(),
//               ],
//             ),
//           ),
//           child: BlocBuilder<AuthCubit, AuthState>(
//             builder: (context, state) {
//               String name = "Singer";
//               if (state is AuthAuthenticated) name = state.user.name;

//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 40),
//                   const CircleAvatar(
//                     radius: 35,
//                     backgroundColor: Colors.white24,
//                     child: Icon(Icons.person, color: Colors.white, size: 40),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     "Welcome, $name!",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     state is AuthAuthenticated
//                         ? state.user.role.toUpperCase()
//                         : "",
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 12,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.logout_rounded, color: Colors.white),
//           onPressed: () => context.read<AuthCubit>().logout(context),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionCard(
//     BuildContext context, {
//     required String title,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: color),
//             const SizedBox(height: 10),
//             Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLeaderCard(BuildContext context) {
//     return BlocBuilder<AuthCubit, AuthState>(
//       builder: (context, state) {
//         if (state is AuthAuthenticated &&
//             state.user.role == AppConstants.roleLeader) {
//           return _buildActionCard(
//             context,
//             title: "Leader Tools",
//             icon: Icons.admin_panel_settings_rounded,
//             color: Colors.redAccent,
//             onTap: () => _navigateToAdmin(context),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }
// }
