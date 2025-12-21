import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
                const Text(
                  'System Health',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Inside SystemHealth Column
                if (stats != null)
                  Text(
                    'Last Synced: ${DateFormat('hh:mm a').format(stats.lastSynced)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),

                const SizedBox(height: 12),
                if (state is SystemHealthChecked) ...[
                  _buildHealthItem(
                    'Users Database',
                    state.healthStatus['users_box'],
                  ),
                  _buildHealthItem(
                    'Songs Database',
                    state.healthStatus['songs_box'],
                  ),
                  _buildHealthItem(
                    'Payments Database',
                    state.healthStatus['payments_box'],
                  ),
                  _buildHealthItem(
                    'No Duplicate Users',
                    !state.healthStatus['duplicate_users'],
                  ),
                  _buildHealthItem(
                    'Storage Healthy',
                    state.healthStatus['storage_healthy'],
                  ),

                  const SizedBox(height: 16),
                  Text('Total Users: ${state.healthStatus['total_users']}'),
                  Text('Total Songs: ${state.healthStatus['total_songs']}'),
                  Text(
                    'Total Payments: ${state.healthStatus['total_payments']}',
                  ),
                ] else if (state is AdminLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else ...[
                  const Text('Click "Check Health" to see system status'),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onHealthCheck,
                        icon: const Icon(Icons.health_and_safety),
                        label: const Text('Check Health'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onCleanup,
                        icon: const Icon(Icons.cleaning_services),
                        label: const Text('Cleanup Data'),
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
