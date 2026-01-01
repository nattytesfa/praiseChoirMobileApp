import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_state.dart';

class SystemHealth extends StatelessWidget {
  final VoidCallback? onHealthCheck;
  final VoidCallback? onCleanup;

  const SystemHealth({super.key, this.onHealthCheck, this.onCleanup});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        final stats = (state is AdminStatsLoaded) ? state.stats : null;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'systemHealth'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Inside SystemHealth Column
                if (stats != null)
                  Text(
                    '${'lastSynced'.tr()}: ${DateFormat('hh:mm a').format(stats.lastSynced)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),

                const SizedBox(height: 12),
                if (state is SystemHealthChecked) ...[
                  _buildHealthItem(
                    'usersDatabase'.tr(),
                    state.healthStatus['users_box'],
                  ),
                  _buildHealthItem(
                    'songsDatabase'.tr(),
                    state.healthStatus['songs_box'],
                  ),
                  _buildHealthItem(
                    'paymentsDatabase'.tr(),
                    state.healthStatus['payments_box'],
                  ),
                  _buildHealthItem(
                    'noDuplicateUsers'.tr(),
                    !state.healthStatus['duplicate_users'],
                  ),
                  _buildHealthItem(
                    'storageHealthy'.tr(),
                    state.healthStatus['storage_healthy'],
                  ),

                  const SizedBox(height: 16),
                  Text(
                    '${'totalUsers'.tr()}: ${state.healthStatus['total_users']}',
                  ),
                  Text(
                    '${'totalSongs'.tr()}: ${state.healthStatus['total_songs']}',
                  ),
                  Text(
                    '${'totalPayments'.tr()}: ${state.healthStatus['total_payments']}',
                  ),
                ] else if (state is AdminLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else ...[
                  Text('clickCheckHealth'.tr()),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onHealthCheck,
                        icon: const Icon(Icons.health_and_safety),
                        label: Text('checkHealth'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onCleanup,
                        icon: const Icon(Icons.cleaning_services),
                        label: Text('cleanUpData'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthItem(String label, bool isHealthy) {
    return Row(
      children: [
        Icon(
          isHealthy ? Icons.check_circle : Icons.error,
          color: isHealthy ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
