import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/voice_player.dart';

class VoiceMessageScreen extends StatefulWidget {
  final String filePath;
  final Duration duration;

  const VoiceMessageScreen({
    super.key,
    required this.filePath,
    required this.duration,
  });

  @override
  State<VoiceMessageScreen> createState() => _VoiceMessageScreenState();
}

class _VoiceMessageScreenState extends State<VoiceMessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Message'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text('Voice Message', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Duration: ${_formatDuration(widget.duration)}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),
            VoicePlayer(
              filePath: widget.filePath,
              duration: widget.duration,
              showWaveform: true,
            ),
            const SizedBox(height: 24),

          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
