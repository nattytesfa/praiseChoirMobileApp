import 'package:flutter/material.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';

class LyricsFullscreen extends StatefulWidget {
  final String title;
  final String lyrics;
  final String language;

  const LyricsFullscreen({
    super.key,
    required this.title,
    required this.lyrics,
    required this.language,
    required String songTitle,
  });

  @override
  State<LyricsFullscreen> createState() => _LyricsFullscreenState();
}

class _LyricsFullscreenState extends State<LyricsFullscreen> {
  double _textScale = 1.0;

  final List<double> _textScales = [0.8, 1.0, 1.2, 1.5, 2.0];
  final ScrollController _scrollController = ScrollController();

  void _increaseTextSize() {
    final currentIndex = _textScales.indexOf(_textScale);
    if (currentIndex < _textScales.length - 1) {
      setState(() {
        _textScale = _textScales[currentIndex + 1];
      });
    }
  }

  void _decreaseTextSize() {
    final currentIndex = _textScales.indexOf(_textScale);
    if (currentIndex > 0) {
      setState(() {
        _textScale = _textScales[currentIndex - 1];
      });
    }
  }

  void _resetTextSize() {
    setState(() {
      _textScale = 1.0;
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.withValues(Colors.black, 0.8),
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            widget.language == 'amharic' ? 'Amharic' : 'Kembatigna',
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
        ],
      ),
      actions: [
        // Text Size Controls
        PopupMenuButton<double>(
          icon: const Icon(Icons.text_fields, color: Colors.white),
          onSelected: (scale) => setState(() => _textScale = scale),
          itemBuilder: (context) => _textScales.map((scale) {
            return PopupMenuItem<double>(
              value: scale,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(scale * 100).toInt()}%'),
                  if (scale == _textScale) const Icon(Icons.check, size: 16),
                ],
              ),
            );
          }).toList(),
        ),

        // Scroll Controls
        PopupMenuButton<void>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: _scrollToTop,
              child: const Text('Scroll to Top'),
            ),
            PopupMenuItem(
              onTap: _scrollToBottom,
              child: const Text('Scroll to Bottom'),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              onTap: _resetTextSize,
              child: const Text('Reset Text Size'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingControls() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        children: [
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            onPressed: _increaseTextSize,
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            onPressed: _decreaseTextSize,
            child: const Icon(Icons.zoom_out),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'reset',
            onPressed: _resetTextSize,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsContent() {
    return Container(
      color: Colors.black,
      child: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: SelectableText(
            widget.lyrics,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontSize: AppTextStyles.bodyLarge.fontSize! * _textScale,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Stack(children: [_buildLyricsContent(), _buildFloatingControls()]),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
