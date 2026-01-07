import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/features/admin/admin_routes.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_state.dart';
import 'package:praise_choir_app/features/admin/presentation/screens/activity_analytics.dart';
import 'package:praise_choir_app/features/admin/presentation/widgets/system_health.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/payment/payment_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/admin_cubit.dart';
import '../widgets/admin_requests_card.dart';

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
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text('leaderDashboard'.tr()),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
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
          return Center(child: Text('initializingDashboard'.tr()));
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
          AdminRequestsCard(requestCount: pendingCount),
          const SizedBox(height: 24),

          Text(
            "membersOverview".tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),

          // STAT CARDS
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "members".tr(),
                  state.stats.totalMembers.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "leaders".tr(),
                  state.stats.adminCount.toString(),
                  Icons.shield,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "songsOverview".tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "totalSongs".tr(),
                  state.stats.totalSongs.toString(),
                  Icons.music_note,
                  Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "withAudio".tr(),
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
                  "amharic".tr(),
                  state.amharicSongsCount.toString(),
                  Icons.language,
                  Colors.brown,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "kembatgna".tr(),
                  state.kembatgnaSongsCount.toString(),
                  Icons.language,
                  Colors.indigo,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            "managementCategories".tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                "memberManagement".tr(),
                Icons.group_work_rounded,
                Colors.orange,
                () => Navigator.pushNamed(context, '/admin/members'),
              ),
              _buildCategoryCard(
                context,
                "usageAnalytics".tr(),
                Icons.bar_chart_rounded,
                Colors.indigo,
                () => Navigator.pushNamed(context, '/admin/analytics'),
              ),
              _buildCategoryCard(
                context,
                "systemSettings".tr(),
                Icons.settings_applications_rounded,
                Colors.blueGrey,
                () => Navigator.pushNamed(context, '/admin/settings'),
              ),
              _buildCategoryCard(
                context,
                "paymentInformation".tr(),
                Icons.payments_rounded,
                Colors.green,
                () => Navigator.pushNamed(context, PaymentRoutes.dashboard),
              ),
              _buildCategoryCard(
                context,
                "Activity Timeline",
                Icons.timeline,
                Colors.teal,
                () =>
                    Navigator.pushNamed(context, AdminRoutes.activityTimeline),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            "systemDiagnostics".tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SystemHealth(
            onHealthCheck: () => context.read<AdminCubit>().checkSystemHealth(),
            onCleanup: () => _confirmCleanup(context),
          ),
          const SizedBox(height: 24),
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
        color: Theme.of(context).cardColor,
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
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
      title: Text('cleanUpLocalCache'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('cancel'.tr()),
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('systemResynced'.tr())));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('clearAndSync'.tr()),
          ),
        ),
      ],
    ),
  );
}
