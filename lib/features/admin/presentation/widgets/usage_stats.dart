import 'package:flutter/material.dart';
import 'package:praise_choir_app/features/admin/data/models/admin_stats_model.dart';

class UsageStats extends StatelessWidget {
  final AdminStatsModel stats;

  const UsageStats({super.key, required this.stats});

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Usage Statistics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          children: [
            _buildStatCard(
              'Total Members',
              stats.totalMembers.toString(),
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              'Active Members',
              stats.activeMembers.toString(),
              Icons.person,
              Colors.green,
            ),
            _buildStatCard(
              'Total Songs',
              stats.totalSongs.toString(),
              Icons.music_note,
              Colors.purple,
            ),
            _buildStatCard(
              'Songs with Audio',
              '${stats.songsWithAudio}/${stats.totalSongs}',
              Icons.audio_file,
              Colors.orange,
            ),
            _buildStatCard(
              'Collection Rate',
              '${stats.monthlyCollectionRate.toStringAsFixed(1)}%',
              Icons.payment,
              Colors.teal,
            ),
            _buildStatCard(
              'Unread Messages',
              stats.unreadMessages.toString(),
              Icons.chat,
              Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Last updated: ${_formatDate(stats.lastUpdated)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
