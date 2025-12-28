import 'package:flutter/material.dart';

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
          const Text(
            'Filter Songs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('By Tag:'),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('All', onTap: () => onTagSelected('')),
              _buildFilterChip('New', onTap: () => onTagSelected('new')),
              _buildFilterChip(
                'This Round',
                onTap: () => onTagSelected('this_round'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Special Filters:'),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.orange),
            title: const Text('Neglected Songs'),
            subtitle: const Text('Songs not used in 3+ months'),
            onTap: onNeglectedSongs,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
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
