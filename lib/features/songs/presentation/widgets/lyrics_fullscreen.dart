import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';

class LyricsFullscreen extends StatefulWidget {
  final String lyrics;
  final VoidCallback onFullscreen;
  final bool showActions;

  const LyricsFullscreen({
    super.key,
    required this.lyrics,
    required this.onFullscreen,
    this.showActions = true,
  });

  @override
  State<LyricsFullscreen> createState() => _LyricsFullscreenState();
}

class _LyricsFullscreenState extends State<LyricsFullscreen>
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
        stanza,
        style: TextStyle(
          fontSize: _fontSize,
          height: 1.7, // Slightly increased for Amharic legibility
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  List<String> _splitLyricsIntoStanzas(String lyrics) {
    // Split by double newlines (stanzas)
    return lyrics.split('\n\n');
  }

  Widget _buildActions() {
    if (!widget.showActions) return const SizedBox.shrink();

    return FloatingActionButton(
      mini: true,
      elevation: 0,

      onPressed: () {
        Clipboard.setData(ClipboardData(text: widget.lyrics));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lyrics copied to clipboard')),
        );
      },
      child: const Icon(Icons.copy, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for KeepAlive
    final stanzas = _splitLyricsIntoStanzas(widget.lyrics);

    return Scaffold(
      floatingActionButton: widget.showActions ? _buildActions() : null,
      body: Column(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
