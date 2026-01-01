import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SongFilterSheet extends StatelessWidget {
  final Function(String) onTagSelected;
  final VoidCallback onNeglectedSongs;

  const SongFilterSheet({
    super.key,
    required this.onTagSelected,
    required this.onNeglectedSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'filterSongs'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('byTag'.tr()),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('all'.tr(), onTap: () => onTagSelected('')),
              _buildFilterChip('new'.tr(), onTap: () => onTagSelected('new')),
              _buildFilterChip(
                'thisRound'.tr(),
                onTap: () => onTagSelected('this_round'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('specialFilters'.tr()),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.orange),
            title: Text('neglectedSongs'.tr()),
            subtitle: Text('neglectedSongsSubtitle'.tr()),
            onTap: onNeglectedSongs,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {required VoidCallback onTap}) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}
