import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/widgets/common/network_status_indicator.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          0.6, // Takes 80% width, 100% height
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
//   Widget _buildProfileMenu(BuildContext context, dynamic user) {
//     return IconButton(
//       icon: const Icon(Icons.menu, color: Colors.white),
//       onPressed: () {
//         showModalBottomSheet(
//           context: context,
//           isScrollControlled: false, // This allows the sheet to go full screen
//           backgroundColor:
//               Colors.transparent, // We handle color in the container
//           builder: (context) => Container(
//             height:
//                 MediaQuery.of(context).size.height *
//                 0.9, // 90% of screen height
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//             ),
//             child: Column(
//               children: [
//                 // 1. The "Handle" at the top for a premium feel
//                 const SizedBox(height: 12),
//                 Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // 2. Profile Header Section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 35, // Bigger for full screen
//                         backgroundColor: Colors.blue.shade800,
//                         child: Text(
//                           user?.name[0].toUpperCase() ?? "U",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 24,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               user?.name ?? "User",
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 20,
//                               ),
//                             ),
//                             Text(
//                               user?.email ?? "",
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 14,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             _buildRoleBadge(user?.role),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 30),
//                 const Divider(),

//                 // 3. Navigation Items (Large and clickable)
//                 Expanded(
//                   child: ListView(
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     children: [
//                       _buildListTile(Icons.person_outline, "My Profile", () {}),
//                       _buildListTile(Icons.favorite_border, "Favorites", () {}),
//                       _buildListTile(Icons.payment, "Payment History", () {}),
//                       _buildListTile(
//                         Icons.settings_outlined,
//                         "Settings",
//                         () {},
//                       ),
//                       _buildListTile(Icons.help_outline, "Support", () {}),
//                     ],
//                   ),
//                 ),

//                 // 4. Footer
//                 const Text(
//                   "Version 1.0.0",
//                   style: TextStyle(color: Colors.grey, fontSize: 12),
//                 ),
//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Helper for the List Tiles
//   Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
//     return ListTile(
//       leading: Icon(icon, size: 28, color: Colors.blueGrey[800]),
//       title: Text(
//         title,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//       ),
//       onTap: onTap,
//       trailing: const Icon(Icons.chevron_right, size: 20),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//     );
//   }

//   // Helper for the Badge
//   Widget _buildRoleBadge(String? role) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         role?.toUpperCase() ?? "GUEST",
//         style: const TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.bold,
//           color: Colors.blue,
//         ),
//       ),
//     );
//   }
// }
//   Widget _buildProfileMenu(BuildContext context, dynamic user) {
//     return PopupMenuButton(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       // 1. Changed to Hamburger Icon
//       icon: const Icon(Icons.menu, color: Colors.white),
//       itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
//         PopupMenuItem(
//           enabled: false,
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   // 2. Profile Photo moved inside here
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundColor: Colors.blue.shade800,
//                     child: Text(
//                       user?.name[0].toUpperCase() ?? "U",
//                       style: const TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   // Name and Email
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           user?.name ?? "User",
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                             fontSize: 14,
//                           ),
//                         ),
//                         Text(
//                           user?.email ?? "",
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey.shade600,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               // Role Badge
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   child: Text(
//                     user?.role.toUpperCase() ?? "GUEST",
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: Colors.blue.shade900,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const Divider(height: 20),
//             ],
//           ),
//         ),
//         // ... rest of your menu items
//         const PopupMenuItem(
//           child: ListTile(
//             leading: Icon(Icons.person_outline),
//             title: Text("My Profile"),
//             contentPadding: EdgeInsets.zero, // Clean up the alignment
//           ),
//         ),
//         const PopupMenuItem(
//           child: ListTile(
//             leading: Icon(Icons.favorite_border),
//             title: Text("Favorites"),
//             contentPadding: EdgeInsets.zero,
//           ),
//         ),
//         const PopupMenuItem(
//           child: ListTile(
//             leading: Icon(Icons.payment),
//             title: Text("Payment History"),
//             contentPadding: EdgeInsets.zero,
//           ),
//         ),
//         const PopupMenuItem(
//           child: ListTile(
//             leading: Icon(Icons.settings),
//             title: Text("Settings"),
//             contentPadding: EdgeInsets.zero,
//           ),
//         ),
//         const PopupMenuDivider(),
//         const PopupMenuItem(
//           enabled: false,
//           child: Center(
//             child: Text("Version 1.0.0", style: TextStyle(fontSize: 10)),
//           ),
//         ),
//       ],
//     );
//   }
// }

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
