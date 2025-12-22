import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;
  final Widget? actionButton;

  const EmptyState({
    super.key,
    required this.message,
    this.subtitle,
    this.icon = Icons.inbox,
    this.actionButton,
    required String title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: 20),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}

class EmptySongsState extends StatelessWidget {
  final VoidCallback onAddSong;

  const EmptySongsState({super.key, required this.onAddSong});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      message: 'No Songs Yet',
      subtitle: 'Start by adding your first song to the library',
      icon: Icons.music_note,
      actionButton: ElevatedButton.icon(
        onPressed: onAddSong,
        icon: const Icon(Icons.add),
        label: const Text('Add First Song'),
      ),
      title: '',
    );
  }
}

class EmptyPaymentsState extends StatelessWidget {
  const EmptyPaymentsState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      message: 'No Payment Records',
      subtitle: 'Payment records will appear here',
      icon: Icons.payment,
      title: '',
    );
  }
}
