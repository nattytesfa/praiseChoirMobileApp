import 'package:easy_localization/easy_localization.dart';
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
        title: Text('usageAnalytics'.tr()),
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
                    'activeMembers'.tr(),
                    '${state.stats.activeMembers}/${state.stats.totalMembers}',
                    '${((state.stats.activeMembers / state.stats.totalMembers) * 100).toStringAsFixed(1)}% active',
                    Icons.people,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildAnalyticsCard(
                    'songCompletion'.tr(),
                    '${state.stats.songsWithAudio}/${state.stats.totalSongs}',
                    '${((state.stats.songsWithAudio / state.stats.totalSongs) * 100).toStringAsFixed(1)}% with audio',
                    Icons.music_note,
                    Colors.purple,
                  ),
                  const SizedBox(height: 12),
                  _buildAnalyticsCard(
                    'paymentCollection'.tr(),
                    '${state.stats.monthlyCollectionRate.toStringAsFixed(1)}%',
                    'monthlyCollectionRate'.tr(),
                    Icons.payment,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildAnalyticsCard(
                    'systemUsage'.tr(),
                    '${state.stats.unreadMessages}',
                    'unreadMessages'.tr(),
                    Icons.chat,
                    Colors.orange,
                  ),

                  const SizedBox(height: 24),

                  // Detailed Analytics
                  Text(
                    'detailedAnalytics'.tr(),
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
                          Text(
                            'memberActivity'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildActivityItem(
                            'TotalMembers'.tr(),
                            state.stats.totalMembers.toString(),
                            Icons.people,
                          ),
                          _buildActivityItem(
                            'activeMembers'.tr(),
                            state.stats.activeMembers.toString(),
                            Icons.person,
                          ),
                          _buildActivityItem(
                            'inactiveMembers'.tr(),
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
                          Text(
                            'songLibraryHealth'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSongHealthItem(
                            'totalSongs'.tr(),
                            state.stats.totalSongs,
                          ),
                          _buildSongHealthItem(
                            'songsWithAudio'.tr(),
                            state.stats.songsWithAudio,
                          ),
                          _buildSongHealthItem(
                            'songsWithoutAudio'.tr(),
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
                          Text(
                            'financialHealth'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildFinancialItem(
                            'collectionRate'.tr(),
                            '${state.stats.monthlyCollectionRate.toStringAsFixed(1)}%',
                          ),
                          _buildFinancialItem(
                            'expectedRevenue'.tr(),
                            '${(state.stats.totalMembers * AppConstants.monthlyPaymentAmount).toStringAsFixed(0)} ETB',
                          ),
                          _buildFinancialItem(
                            'actualRevenue'.tr(),
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
                    'lastUpdated: ${_formatDateTime(state.stats.lastUpdated)}'
                        .tr(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else if (state is AdminError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text('NoAnalyticsDataAvailable'.tr()));
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
