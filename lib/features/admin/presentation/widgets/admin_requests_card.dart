import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import '../../../auth/data/models/user_model.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminRequestsCard extends StatelessWidget {
  final int requestCount;

  const AdminRequestsCard({super.key, required this.requestCount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showRequestsModal(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor,
                isDark
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.blue.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
            ],
            border: Border.all(
              color: requestCount > 0
                  ? Colors.orange.withValues(alpha: 0.5)
                  : (isDark ? Colors.white12 : Colors.white),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _buildIconWithBadge(context, isDark),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "manageRequests".tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      requestCount > 0
                          ? "newRequestsCount".tr(
                              args: [requestCount.toString()],
                            )
                          : "noNewRequests".tr(),
                      style: TextStyle(
                        fontSize: 14,
                        color: requestCount > 0
                            ? (isDark ? Colors.orange[300] : Colors.orange[800])
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: requestCount > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? Colors.white70 : Colors.blueGrey,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithBadge(BuildContext context, bool isDark) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.blue.withValues(alpha: 0.2)
                : Colors.blue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.people_alt_rounded,
            color: Colors.blue,
            size: 32,
          ),
        ),
        if (requestCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '$requestCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showRequestsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _RequestsModalContent(),
    );
  }
}

class _RequestsModalContent extends StatefulWidget {
  const _RequestsModalContent();

  @override
  State<_RequestsModalContent> createState() => _RequestsModalContentState();
}

class _RequestsModalContentState extends State<_RequestsModalContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Text(
                      "membershipRequests".tr(),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.all(4),
                  tabs: [
                    Tab(text: "pending".tr()),
                    Tab(text: "approved".tr()),
                    Tab(text: "denied".tr()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<AdminCubit, AdminState>(
                  builder: (context, state) {
                    if (state is! AdminStatsLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final pending = state.members
                        .where((u) => u.approvalStatus == 'pending')
                        .toList();
                    final approved = state.members
                        .where((u) => u.approvalStatus == 'approved')
                        .toList();
                    final denied = state.members
                        .where((u) => u.approvalStatus == 'denied')
                        .toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildUserList(context, pending, 'pending'),
                        _buildUserList(context, approved, 'approved'),
                        _buildUserList(context, denied, 'denied'),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList(
    BuildContext context,
    List<UserModel> users,
    String type,
  ) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "noRequestsFound".tr(),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _UserRequestCard(user: users[index]);
      },
    );
  }
}

class _UserRequestCard extends StatelessWidget {
  final UserModel user;

  const _UserRequestCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (user.approvalStatus == 'denied' &&
                (user.adminMessage?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${'reason'.tr()}: ${user.adminMessage}",
                        style: TextStyle(
                          color: isDark ? Colors.red[200] : Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (user.approvalStatus != 'denied')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDenyDialog(context, user.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(
                          color: isDark ? Colors.redAccent : Colors.red,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text("deny".tr()),
                    ),
                  ),
                if (user.approvalStatus != 'denied' &&
                    user.approvalStatus != 'approved')
                  const SizedBox(width: 12),
                if (user.approvalStatus != 'approved')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<AdminCubit>().respondToRequest(
                          user.id,
                          true,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text("approve".tr()),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDenyDialog(BuildContext context, String userId) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("reasonForDenial".tr()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "enterReason".tr(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("cancel".tr()),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text("deny".tr()),
          ),
        ],
      ),
    );
  }
}
