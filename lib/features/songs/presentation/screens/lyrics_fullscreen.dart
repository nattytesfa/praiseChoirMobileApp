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
      actions: [_textSizeController()],
    );
  }

  Widget _textSizeController() {
    return Row(
      children: [
        IconButton(
          onPressed: _increaseTextSize,
          icon: Icon(Icons.zoom_in, color: Colors.white),
        ),
        IconButton(
          onPressed: _decreaseTextSize,
          icon: Icon(Icons.zoom_out, color: Colors.white),
        ),
        IconButton(
          onPressed: _resetTextSize,
          icon: Icon(Icons.refresh, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildLyricsContent() {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(24),
        child: Center(
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
    const primaryDark = Color(0xFF0F172A);

    return Scaffold(
      extendBodyBehindAppBar: false,
      extendBody: true,
      backgroundColor: primaryDark,
      appBar: _buildAppBar(),
      body: _buildLyricsContent(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
