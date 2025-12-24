import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';

class LyricsDisplay extends StatefulWidget {
  final String lyrics;
  final VoidCallback onFullscreen;
  final bool showActions;

  const LyricsDisplay({
    super.key,
    required this.lyrics,
    required this.onFullscreen,
    this.showActions = true,
  });

  @override
  State<LyricsDisplay> createState() => _LyricsDisplayState();
}

class _LyricsDisplayState extends State<LyricsDisplay>
    with AutomaticKeepAliveClientMixin {
  double _fontSize = 18.0;

  @override
  bool get wantKeepAlive => true;

  Widget _buildFontSizeControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(
            Icons.text_fields,
            size: 16,
            color: AppColors.textSecondary,
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: () => setState(() => _fontSize -= 2),
          ),
          Text(_fontSize.toInt().toString(), style: AppTextStyles.labelMedium),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => setState(() => _fontSize += 2),
          ),
        ],
      ),
    );
  }

  Widget _buildStanza(String stanza) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SelectableText(
        // Changed from Text to SelectableText
        stanza,
        style: TextStyle(
          fontSize: _fontSize,
          height: 1.7, // Slightly increased for Amharic legibility
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
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
    if (!widget.showActions) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: widget.onFullscreen,
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
              Clipboard.setData(ClipboardData(text: widget.lyrics));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lyrics copied to clipboard')),
              );
            },
            tooltip: 'Copy Lyrics',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for KeepAlive
    final stanzas = _splitLyricsIntoStanzas(widget.lyrics);

    return Column(
      children: [
        if (widget.showActions) _buildFontSizeControls(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Lyrics Content
                Column(
                  children: stanzas.asMap().entries.map((entry) {
                    return _buildStanza(entry.value);
                  }).toList(),
                ),

                // Actions
                _buildActions(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
