import 'package:easy_localization/easy_localization.dart';
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

  Widget _buildActions() {
    if (!widget.showActions) return const SizedBox.shrink();

    return FloatingActionButton(
      mini: true,
      elevation: 0,

      onPressed: () {
        Clipboard.setData(ClipboardData(text: widget.lyrics));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('lyricsCopiedToClipboard'.tr())));
      },
      child: const Icon(Icons.copy, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for KeepAlive

    return Scaffold(
      floatingActionButton: widget.showActions ? _buildActions() : null,
      body: Column(
        children: [
          if (widget.showActions) _buildFontSizeControls(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.topLeft,
                child: SelectableText(
                  widget.lyrics,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontSize: _fontSize,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
