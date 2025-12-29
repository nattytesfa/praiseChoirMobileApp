import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/features/admin/admin_routes.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_state.dart';
import 'package:praise_choir_app/features/admin/presentation/screens/activity_analytics.dart';
import 'package:praise_choir_app/features/admin/presentation/widgets/system_health.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/payment/payment_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';

import '../cubit/admin_cubit.dart';

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
            // 1. Get the count from the state we just cast
            final int count = state.pendingCount;

            // 2. Pass it to your content builder
            return _buildDashboardContent(context, state, count);
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

  Widget _buildDashboardContent(
    BuildContext context,
    AdminStatsLoaded state,
    int pendingCount,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequestTile(context, pendingCount),
          const SizedBox(height: 24),

          const Text(
            "Performance Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 32),

          // STAT CARDS
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Members",
                  state.stats.totalMembers.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Leaders",
                  state.stats.adminCount.toString(),
                  Icons.shield,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Active",
                  state.stats.activeMembers.toString(),
                  Icons.bolt,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Songs Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Total Songs",
                  state.stats.totalSongs.toString(),
                  Icons.music_note,
                  Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "With Audio",
                  state.stats.songsWithAudio.toString(),
                  Icons.audio_file,
                  Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Amharic",
                  state.amharicSongsCount.toString(),
                  Icons.language,
                  Colors.brown,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Kembatgna",
                  state.kembatgnaSongsCount.toString(),
                  Icons.language,
                  Colors.indigo,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            "Management Categories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 24),

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
              _buildCategoryCard(
                context,
                "Payment Dashboard",
                "Manage finances",
                Icons.payments_rounded,
                Colors.green,
                () => Navigator.pushNamed(context, PaymentRoutes.dashboard),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            "System Diagnostic",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 24),
          SystemHealth(
            onHealthCheck: () => context.read<AdminCubit>().checkSystemHealth(),
            onCleanup: () => _confirmCleanup(context),
          ),
          ActivityAnalytics(members: state.members),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
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

// 1. The Badge Tile (Make sure to call this in your ListView/Column)
Widget _buildRequestTile(BuildContext context, int count) {
  return InkWell(
    onTap: () => _showRequestsModal(context),
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: count > 0
              ? Colors.orange.withValues()
              : Colors.blue.withValues(),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icon with a modern Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: count > 0
                      ? Colors.blue.withValues()
                      : Colors.blue.withValues(),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              if (count > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Text Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Manage Requests",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  count > 0
                      ? "$count new requests to review"
                      : "No new requests",
                  style: TextStyle(
                    fontSize: 13,
                    color: count > 0 ? Colors.orange[800] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    ),
  );
}

// 2. The Modal that shows the list of users
void _showRequestsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalContext) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state is! AdminStatsLoaded) {
              return const CircularProgressIndicator();
            }
            final pending = state.members
                .where((u) => u.approvalStatus == 'pending')
                .toList();
            final denied = state.members
                .where((u) => u.approvalStatus == 'denied')
                .toList();
            final approved = state.members
                .where((u) => u.approvalStatus == 'approved')
                .toList();
            // final allMembers = state.members.toList()
            //   ..sort((a, b) {
            //     // Logic to put pending/denied users at the top of the list
            //     if (a.approvalStatus == 'pending' &&
            //         b.approvalStatus != 'pending') {
            //       return -1;
            //     }
            //     return 1;
            //   });
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: ListView(
                controller: scrollController,
                children: [
                  // 1. PENDING SECTION
                  if (pending.isNotEmpty) ...[
                    _buildSectionHeader("Pending Requests", Colors.orange),
                    ...pending.map((u) => _buildUserTile(context, u)),
                  ],

                  // 2. DENIED SECTION
                  if (denied.isNotEmpty) ...[
                    _buildSectionHeader("Denied Members", Colors.red),
                    ...denied.map((u) => _buildUserTile(context, u)),
                  ],

                  // 3. APPROVED SECTION
                  if (approved.isNotEmpty) ...[
                    _buildSectionHeader("Approved Members", Colors.green),
                    ...approved.map((u) => _buildUserTile(context, u)),
                  ],

                  if (state.members.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text("No users found"),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}

Widget _buildSectionHeader(String title, Color color) {
  return Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: color.withValues(),
    width: double.infinity,
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        letterSpacing: 1.1,
      ),
    ),
  );
}

Widget _buildUserTile(BuildContext context, UserModel user) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: const Color.fromARGB(255, 61, 51, 51),
      child: Text(user.name[0].toUpperCase()),
    ),
    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(
      user.approvalStatus == 'denied'
          ? "Reason: ${user.adminMessage}"
          : user.email,
    ),
    trailing: Wrap(
      spacing: 8,
      children: [
        // Show APPROVE button if the user is NOT approved
        if (user.approvalStatus != 'approved')
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
            onPressed: () =>
                context.read<AdminCubit>().respondToRequest(user.id, true),
          ),
        // Show DENY button if the user is NOT denied
        if (user.approvalStatus != 'denied')
          IconButton(
            icon: const Icon(Icons.block, color: Colors.redAccent),
            onPressed: () => _showDenyDialog(context, user.id),
          ),
      ],
    ),
  );
}

// 3. The Deny Dialog (Must be defined inside the same State class)
void _showDenyDialog(BuildContext context, String userId) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text("Reason for Denial"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "Enter reason..."),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              context.read<AdminCubit>().respondToRequest(
                userId,
                false,
                message: controller.text.trim(),
              );
              Navigator.pop(dialogContext);
            }
          },
          child: const Text("Deny"),
        ),
      ],
    ),
  );
}
