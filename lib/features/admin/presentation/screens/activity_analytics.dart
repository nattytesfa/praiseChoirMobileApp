import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:praise_choir_app/features/auth/data/models/user_model.dart';

class ActivityAnalytics extends StatelessWidget {
  final List<UserModel> members;

  const ActivityAnalytics({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final activeCount = members
        .where((u) => u.lastLogin != null && u.lastLogin!.isAfter(sevenDaysAgo))
        .length;

    final inactiveCount = members.length - activeCount;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choir Engagement (Last 7 Days)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Active", activeCount, Colors.green),
                _buildStatItem("Inactive", inactiveCount, Colors.orange),
              ],
            ),
            const Divider(height: 30),
            const Text(
              "Recent Logins",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.take(5).length, // Show top 5
              itemBuilder: (context, index) {
                final user = members[index];
                final lastSeen = user.lastLogin != null
                    ? DateFormat('MMM d, HH:mm').format(user.lastLogin!)
                    : 'Never';

                return ListTile(
                  leading: CircleAvatar(child: Text(user.name[0])),
                  title: Text(user.name),
                  subtitle: Text('Last seen: $lastSeen'),
                  trailing: Icon(
                    Icons.circle,
                    size: 12,
                    color:
                        user.lastLogin != null &&
                            user.lastLogin!.isAfter(sevenDaysAgo)
                        ? Colors.green
                        : Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
