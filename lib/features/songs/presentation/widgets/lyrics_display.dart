import 'package:flutter/material.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';

class LyricsDisplay extends StatelessWidget {
  final String lyrics;
  final VoidCallback onFullscreen;
  final bool showActions;

  const LyricsDisplay({
    super.key,
    required this.lyrics,
    required this.onFullscreen,
    this.showActions = true,
  });

  Widget _buildStanza(String stanza, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        stanza,
        style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<String> _splitLyricsIntoStanzas(String lyrics) {
    // Split by double newlines (stanzas) or single newlines (lines within stanzas)
    final stanzas = lyrics.split('\n\n');

    // If no double newlines found, split by single newlines
    if (stanzas.length == 1 && stanzas.first.contains('\n')) {
      return lyrics.split('\n');
    }

    return stanzas;
  }

  Widget _buildActions() {
    if (!showActions) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: onFullscreen,
            icon: const Icon(Icons.fullscreen),
            label: const Text('Fullscreen'),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.withValues(AppColors.primary, 0.1),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              // Copy lyrics to clipboard
            },
            tooltip: 'Copy Lyrics',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stanzas = _splitLyricsIntoStanzas(lyrics);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Lyrics Content
          Column(
            children: stanzas.asMap().entries.map((entry) {
              final index = entry.key;
              final stanza = entry.value;
              return _buildStanza(stanza, index);
            }).toList(),
          ),

          // Actions
          _buildActions(),
        ],
      ),
    );
  }
}
