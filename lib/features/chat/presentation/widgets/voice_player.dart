import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class VoicePlayer extends StatefulWidget {
  final String filePath;
  final Duration duration;
  final bool showWaveform;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;

  const VoicePlayer({
    super.key,
    required this.filePath,
    required this.duration,
    this.showWaveform = false,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<VoicePlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            if (state.processingState == ProcessingState.completed) {
              _isPlaying = false;
              _currentPosition = Duration.zero;
              _audioPlayer.seek(Duration.zero);
              _audioPlayer.pause();
            }
          });
        }
      });

      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      });

      if (widget.filePath.startsWith('http')) {
        await _audioPlayer.setUrl(widget.filePath);
      } else {
        await _audioPlayer.setFilePath(widget.filePath);
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (!_isInitialized) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.backgroundColor ?? AppColors.primary.withValues(alpha: 0.1);
    final activeColor = widget.activeColor ?? AppColors.primary;
    final inactiveColor = widget.inactiveColor ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Play/Pause Button
          IconButton(
            onPressed: _togglePlay,
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: activeColor,
            ),
          ),
          // Progress and Waveform
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showWaveform)
                  Container(
                    height: 20,
                    margin: const EdgeInsets.only(bottom: 4),
                    child: _buildWaveform(activeColor),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_currentPosition),
                      style: AppTextStyles.caption.copyWith(
                        color: inactiveColor,
                      ),
                    ),
                    Text(
                      _formatDuration(widget.duration),
                      style: AppTextStyles.caption.copyWith(
                        color: inactiveColor,
                      ),
                    ),
                  ],
                ),
                LinearProgressIndicator(
                  value: widget.duration.inMilliseconds > 0
                      ? (_currentPosition.inMilliseconds /
                                widget.duration.inMilliseconds)
                            .clamp(0.0, 1.0)
                      : 0,
                  backgroundColor: inactiveColor.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform(Color color) {
    // Simplified waveform visualization
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(20, (index) {
        final height = (index % 5 + 1) * 3.0;
        return Container(width: 2, height: height, color: color);
      }),
    );
  }
}
