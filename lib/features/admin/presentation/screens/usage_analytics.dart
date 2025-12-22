import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_state.dart';

class UsageAnalyticsScreen extends StatefulWidget {
  const UsageAnalyticsScreen({super.key});

  @override
  State<UsageAnalyticsScreen> createState() => _UsageAnalyticsScreenState();
}

class _UsageAnalyticsScreenState extends State<UsageAnalyticsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().loadAdminStats();
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        if (!mounted) return;
        setState(() {
          _selectedDate = date;
        });
        // Reload stats for selected date
        context.read<AdminCubit>().loadAdminStats();
      }
    });
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double value, Color color) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor: color.withValues(),
      valueColor: AlwaysStoppedAnimation<Color>(color),
      minHeight: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usage Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AdminStatsLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  _buildAnalyticsCard(
                    'Active Members',
                    '${state.stats.activeMembers}/${state.stats.totalMembers}',
                    '${((state.stats.activeMembers / state.stats.totalMembers) * 100).toStringAsFixed(1)}% active',
                    Icons.people,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildAnalyticsCard(
                    'Song Completion',
                    '${state.stats.songsWithAudio}/${state.stats.totalSongs}',
                    '${((state.stats.songsWithAudio / state.stats.totalSongs) * 100).toStringAsFixed(1)}% with audio',
                    Icons.music_note,
                    Colors.purple,
                  ),
                  const SizedBox(height: 12),
                  _buildAnalyticsCard(
                    'Payment Collection',
                    '${state.stats.monthlyCollectionRate.toStringAsFixed(1)}%',
                    'Monthly collection rate',
                    Icons.payment,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildAnalyticsCard(
                    'System Usage',
                    '${state.stats.unreadMessages}',
                    'Unread messages',
                    Icons.chat,
                    Colors.orange,
                  ),

                  const SizedBox(height: 24),

                  // Detailed Analytics
                  const Text(
                    'Detailed Analytics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Member Activity
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Member Activity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildActivityItem(
                            'Total Members',
                            state.stats.totalMembers.toString(),
                            Icons.people,
                          ),
                          _buildActivityItem(
                            'Active Members',
                            state.stats.activeMembers.toString(),
                            Icons.person,
                          ),
                          _buildActivityItem(
                            'Inactive Members',
                            (state.stats.totalMembers -
                                    state.stats.activeMembers)
                                .toString(),
                            Icons.person_off,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Song Library Health
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Song Library Health',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSongHealthItem(
                            'Total Songs',
                            state.stats.totalSongs,
                          ),
                          _buildSongHealthItem(
                            'Songs with Audio',
                            state.stats.songsWithAudio,
                          ),
                          _buildSongHealthItem(
                            'Songs without Audio',
                            state.stats.totalSongs - state.stats.songsWithAudio,
                          ),
                          const SizedBox(height: 8),
                          _buildProgressBar(
                            state.stats.totalSongs > 0
                                ? state.stats.songsWithAudio /
                                      state.stats.totalSongs
                                : 0,
                            Colors.purple,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Financial Health
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Financial Health',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildFinancialItem(
                            'Collection Rate',
                            '${state.stats.monthlyCollectionRate.toStringAsFixed(1)}%',
                          ),
                          _buildFinancialItem(
                            'Expected Revenue',
                            '${(state.stats.totalMembers * AppConstants.monthlyPaymentAmount).toStringAsFixed(0)} ETB',
                          ),
                          _buildFinancialItem(
                            'Actual Revenue',
                            '${((state.stats.monthlyCollectionRate / 100) * state.stats.totalMembers * AppConstants.monthlyPaymentAmount).toStringAsFixed(0)} ETB',
                          ),
                          const SizedBox(height: 8),
                          _buildProgressBar(
                            state.stats.monthlyCollectionRate / 100,
                            state.stats.monthlyCollectionRate >= 80
                                ? Colors.green
                                : state.stats.monthlyCollectionRate >= 50
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Last updated: ${_formatDateTime(state.stats.lastUpdated)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else if (state is AdminError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No analytics data available'));
        },
      ),
    );
  }

  Widget _buildActivityItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSongHealthItem(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
