import 'package:flutter/material.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';

import '../../../../core/theme/app_colors.dart';

class LyricsDisplay extends StatefulWidget {
  final String title;
  final String lyrics;

  const LyricsDisplay({super.key, required this.title, required this.lyrics});

  @override
  State<LyricsDisplay> createState() => _LyricsDisplayState();
}

class _LyricsDisplayState extends State<LyricsDisplay> {
  double _textScale = 1.0;
  double _baseTextScale = 1.0;

  final ScrollController _scrollController = ScrollController();


  Widget _buildLyricsContent() {
    return GestureDetector(
      onScaleStart: (details) {
        _baseTextScale = _textScale;
      },
      onScaleUpdate: (details) {
        setState(() {
          _textScale = (_baseTextScale * details.scale).clamp(0.5, 3.0);
        });
      },
      child: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(24),
            alignment: Alignment.topLeft,
            child: SelectableText(
              widget.lyrics,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontSize: AppTextStyles.bodyLarge.fontSize! * _textScale,
                height: 1.8,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF0F172A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.withValues(Colors.black, 0.8),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: false,
      extendBody: true,
      backgroundColor: primaryDark,
      body: _buildLyricsContent(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
