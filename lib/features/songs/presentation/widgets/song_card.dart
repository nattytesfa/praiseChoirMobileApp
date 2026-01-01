import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';

class SongCard extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback onPerformed;
  final VoidCallback onPracticed;

  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
    required this.onPerformed,
    required this.onPracticed,
  });

  String _getTimeAgo(DateTime? date) {
    if (date == null) return 'never'.tr();

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} daysAgo'.tr();
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hoursAgo'.tr();
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutesAgo'.tr();
    } else {
      return 'Just now';
    }
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'old':
        return Colors.orange;
      case 'new':
        return Colors.green;
      case 'favorite':
        return Colors.red;
      case 'this_round':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.music_note, color: Colors.blue),
        title: Text(
          song.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'language: ${song.language}'.tr(),
              style: const TextStyle(fontSize: 12),
            ),
            if (song.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: song.tags.map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: _getTagColor(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'lastPerformed: ${_getTimeAgo(song.lastPerformed)}'.tr(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'performed') {
              onPerformed();
            } else if (value == 'practiced') {
              onPracticed();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'performed',
              child: Text('markAsPerformed'.tr()),
            ),
            PopupMenuItem(
              value: 'practiced',
              child: Text('markAspracticed'.tr()),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
