import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/lyrics_fullscreen.dart';

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

  void _openFullscreenLyrics() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    Navigator.of(context, rootNavigator: true)
        .push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              body: SafeArea(
                child: LyricsFullscreen(
                  lyrics: widget.lyrics,
                  onFullscreen: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        )
        .then((_) {
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          );
        });
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            color: Colors.white,
            onPressed: _openFullscreenLyrics,
            tooltip: 'fullscreenLyrics'.tr(),
          ),
        ],
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
