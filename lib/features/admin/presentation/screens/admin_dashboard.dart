import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/features/admin/admin_routes.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_state.dart';
import 'package:praise_choir_app/features/admin/presentation/widgets/system_health.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';

import '../cubit/admin_cubit.dart';

// Ensure your imports for AuthCubit, AdminCubit, and Routes are correct here

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    // 1. Safety check
    _checkAdminAccess();
    // 2. Load the data (Note: If you already do this in the Router, this is a backup)
    _loadStats();
  }

  void _checkAdminAccess() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      if (authState.user.role != AppConstants.roleLeader) {
        // Use your AppConstants.roleLeader here
        Navigator.pop(context);
      }
    }
  }

  void _loadStats() {
    context.read<AdminCubit>().loadAdminStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leader Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
          IconButton(
            icon: const Icon(Icons.how_to_reg),
            tooltip: 'Approvals',
            onPressed: () => Navigator.pushNamed(context, '/admin/approvals'),
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AdminStatsLoaded) {
            // This calls our beautiful grid layout
            return _buildDashboardContent(context, state);
          } else if (state is AdminError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return const Center(child: Text('Initializing Dashboard...'));
        },
      ),
    );
  }

  // --- UI COMPONENTS (The Beautiful Grid) ---

  Widget _buildDashboardContent(BuildContext context, AdminStatsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Performance Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 16),

          // STAT CARDS
          Row(
            children: [
              _buildStatCard(
                "Members",
                state.stats.totalMembers.toString(),
                Icons.people,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                "Leaders",
                state.stats.adminCount.toString(),
                Icons.shield,
                Colors.purple,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                "Active",
                state.stats.activeMembers.toString(),
                Icons.bolt,
                Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 32),

          const Text(
            "Management Categories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          // 2x2 GRID
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildCategoryCard(
                context,
                "Member Management",
                "Manage roles & status",
                Icons.group_work_rounded,
                Colors.orange,
                () => Navigator.pushNamed(context, '/admin/members'),
              ),
              _buildCategoryCard(
                context,
                "Usage Analytics",
                "View song activity",
                Icons.bar_chart_rounded,
                Colors.indigo,
                () => Navigator.pushNamed(context, '/admin/analytics'),
              ),
              _buildCategoryCard(
                context,
                "System Settings",
                "Global app config",
                Icons.settings_applications_rounded,
                Colors.blueGrey,
                () => Navigator.pushNamed(context, '/admin/settings'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "System Diagnostic",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 16),
          SystemHealth(
            onHealthCheck: () => context.read<AdminCubit>().checkSystemHealth(),
            onCleanup: () => _confirmCleanup(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues()),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 20,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

void _confirmCleanup(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Cleanup Local Cache?'),
      content: const Text(
        'This will clear your local Hive database and redownload everything from Firestore. Use this if you see data errors.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white, // Ensure text is visible
          ),
          onPressed: () async {
            // 1. Close the dialog first so the user sees the dashboard again
            Navigator.pop(dialogContext);

            // 2. Trigger the cleanup and wait for it
            // This will trigger the CircularProgressIndicator you have in SystemHealth
            await context.read<AdminCubit>().cleanupData();

            // 3. Optional: Show a snackbar when done
            if (context.mounted) {
              Navigator.pushNamed(context, AdminRoutes.adminDashboard);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('System re-synced successfully!')),
              );
            }
          },
          child: const Text('Clear & Sync'),
        ),
      ],
    ),
  );
}



// class AdminDashboard extends StatefulWidget {
//   const AdminDashboard({super.key});

//   @override
//   State<AdminDashboard> createState() => _AdminDashboardState();
// }

// class _AdminDashboardState extends State<AdminDashboard> {
//   @override
//   void initState() {
//     super.initState();
//     _checkAdminAccess();
//     _loadStats();
//   }

//   void _checkAdminAccess() {
//     final authState = context.read<AuthCubit>().state;
//     if (authState is AuthAuthenticated) {
//       final user = authState.user;
//       if (user.role != AppConstants.roleLeader) {
//         Navigator.pop(context); // Go back if not leader
//       }
//     }
//   }

//   void _loadStats() {
//     context.read<AdminCubit>().loadAdminStats();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (kDebugMode) {
//       print("UI DEBUG: AdminDashboard is building!");
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Dashboard'),
//         actions: [
//           IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
//           IconButton(
//             icon: const Icon(Icons.how_to_reg),
//             tooltip: 'Approvals',
//             onPressed: () =>
//                 Navigator.pushNamed(context, Routes.adminApprovals),
//           ),
//         ],
//       ),
//       body: BlocBuilder<AdminCubit, AdminState>(
//         builder: (context, state) {
//           if (state is AdminLoading) {
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//             // return const LoadingIndicator();
//           } else if (state is AdminError) {
//             return Center(child: Text(state.message));
//           } else if (state is AdminStatsLoaded) {
//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   UsageStats(stats: state.stats),
//                   const SizedBox(height: 20),
//                   MemberManagementCard(
//                     members: state.members,
//                     onRoleChanged: (memberId, newRole) {
//                       context.read<AdminCubit>().updateMemberRole(
//                         memberId,
//                         newRole,
//                       );
//                     },
//                     onMemberDeactivated: (memberId) {
//                       context.read<AdminCubit>().deactivateMember(memberId);
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   SystemHealth(
//                     onHealthCheck: () {
//                       context.read<AdminCubit>().checkSystemHealth();
//                     },
//                     onCleanup: () {
//                       // context.read<AdminCubit>().cleanupData();
//                     },
//                   ),
//                 ],
//               ),
//             );
//           }
//           return const Center(child: Text('No admin data available'));
//         },
//       ),
//     );
//   }
// }

// ///
// ///

// class AdminDashboardstless extends StatelessWidget {
//   const AdminDashboardstless({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Leader Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => context.read<AdminCubit>().loadAdminStats(),
//           ),
//         ],
//       ),
//       body: BlocBuilder<AdminCubit, AdminState>(
//         builder: (context, state) {
//           if (state is AdminLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is AdminStatsLoaded) {
//             return _buildDashboardContent(context, state);
//           } else if (state is AdminError) {
//             return Center(child: Text(state.message));
//           }
//           return const Center(child: Text('Initialize Dashboard...'));
//         },
//       ),
//     );
//   }

//   // REPLACE your _buildDashboardContent method with this:
//   Widget _buildDashboardContent(BuildContext context, AdminStatsLoaded state) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 1. STATS ROW (The Numbers)
//           const Text(
//             "Performance Overview",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueGrey,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               _buildStatCard(
//                 "Members",
//                 state.stats.totalMembers.toString(),
//                 Icons.people,
//                 Colors.blue,
//               ),
//               const SizedBox(width: 12),
//               _buildStatCard(
//                 "Leaders",
//                 state.stats.adminCount.toString(),
//                 Icons.shield,
//                 Colors.purple,
//               ),
//               const SizedBox(width: 12),
//               _buildStatCard(
//                 "Active",
//                 state.stats.activeMembers.toString(),
//                 Icons.bolt,
//                 Colors.green,
//               ),
//             ],
//           ),

//           const SizedBox(height: 32),

//           // 2. MANAGEMENT CATEGORIES (The 2x2 Grid)
//           const Text(
//             "Management Categories",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueGrey,
//             ),
//           ),
//           const SizedBox(height: 16),
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 2,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             childAspectRatio: 1.1,
//             children: [
//               _buildCategoryCard(
//                 context,
//                 "Member Management",
//                 "Manage roles & status",
//                 Icons.group_work_rounded,
//                 Colors.orange,
//                 () => Navigator.pushNamed(context, '/admin/members'),
//               ),
//               _buildCategoryCard(
//                 context,
//                 "Usage Analytics",
//                 "View song activity",
//                 Icons.bar_chart_rounded,
//                 Colors.indigo,
//                 () => Navigator.pushNamed(context, '/admin/analytics'),
//               ),
//               _buildCategoryCard(
//                 context,
//                 "System Health",
//                 "Database integrity",
//                 Icons.health_and_safety_rounded,
//                 Colors.teal,
//                 () => context.read<AdminCubit>().checkSystemHealth(),
//               ),
//               _buildCategoryCard(
//                 context,
//                 "System Settings",
//                 "Global app config",
//                 Icons.settings_applications_rounded,
//                 Colors.blueGrey,
//                 () => Navigator.pushNamed(context, '/admin/settings'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper Widget for the Small Stats at the top
//   Widget _buildStatCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 20),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               title,
//               style: TextStyle(fontSize: 11, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper Widget for the Large 2x2 Category Cards
//   Widget _buildCategoryCard(
//     BuildContext context,
//     String title,
//     String subtitle,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color.withValues(),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: color.withValues()),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(
//               backgroundColor: color,
//               radius: 20,
//               child: Icon(icon, color: Colors.white, size: 20),
//             ),
//             const Spacer(),
//             Text(
//               title,
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               subtitle,
//               style: TextStyle(fontSize: 10, color: Colors.grey[700]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


/////
///
  // Widget _buildDashboardContent(BuildContext context, AdminStatsLoaded state) {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           "Choir Overview",
  //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 16),

  //         // Row of Summary Cards
  //         Row(
  //           children: [
  //             _buildStatCard(
  //               "Total Members",
  //               state.stats.totalMembers.toString(),
  //               Icons.people,
  //               Colors.blue,
  //             ),
  //             const SizedBox(width: 16),
  //             _buildStatCard(
  //               "Active Now",
  //               state.stats.activeMembers.toString(),
  //               Icons.check_circle,
  //               Colors.green,
  //             ),
  //           ],
  //         ),
  //         // Inside _buildDashboardContent in AdminDashboard.dart
  //         Row(
  //           children: [
  //             _buildStatCard(
  //               "Members",
  //               state.stats.totalMembers.toString(),
  //               Icons.people,
  //               Colors.blue,
  //             ),
  //             const SizedBox(width: 8),
  //             _buildStatCard(
  //               "Leaders",
  //               state.stats.adminCount.toString(), // <--- DISPLAY THE DATA
  //               Icons.admin_panel_settings,
  //               Colors.purple,
  //             ),
  //             const SizedBox(width: 8),
  //             _buildStatCard(
  //               "Active",
  //               state.stats.activeMembers.toString(),
  //               Icons.check_circle,
  //               Colors.green,
  //             ),
  //           ],
  //         ),

  //         const SizedBox(height: 24),
  //         const Text(
  //           "Management Tools",
  //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 16),

  //         // Navigation List
  //         _buildMenuTile(
  //           context,
  //           "Member Management",
  //           "Promote, demote, or remove members",
  //           Icons.manage_accounts,
  //           () => Navigator.pushNamed(context, '/admin/members'),
  //         ),
  //         _buildMenuTile(
  //           context,
  //           "System Health",
  //           "Check database and storage status",
  //           Icons.health_and_safety,
  //           () => context.read<AdminCubit>().checkSystemHealth(),
  //         ),
  //         _buildMenuTile(
  //           context,
  //           "Usage Analytics",
  //           "See song downloads and activity",
  //           Icons.analytics,
  //           () {}, // We'll build this later
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStatCard(
  //   String title,
  //   String value,
  //   IconData icon,
  //   Color color,
  // ) {
  //   return Expanded(
  //     child: Container(
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: color.withValues(),
  //         borderRadius: BorderRadius.circular(16),
  //         border: Border.all(color: color.withValues()),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Icon(icon, color: color),
  //           const SizedBox(height: 12),
  //           Text(
  //             value,
  //             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //           ),
  //           Text(title, style: TextStyle(color: Colors.grey[700])),
  //         ],
  //       ),
  //     ),
  //   );
  // }



  // Widget _buildMenuTile(
  //   BuildContext context,
  //   String title,
  //   String sub,
  //   IconData icon,
  //   VoidCallback onTap,
  // ) {
  //   return Card(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: ListTile(
  //       leading: Icon(icon, color: Colors.blueGrey),
  //       title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
  //       subtitle: Text(sub),
  //       trailing: const Icon(Icons.chevron_right),
  //       onTap: onTap,
  //     ),
  //   );
  // }

