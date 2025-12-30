import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/services/audio_service.dart';
import '../cubit/chat_cubit.dart';

class VoiceRecorder extends StatefulWidget {
  final String chatId;
  final String senderId;

  const VoiceRecorder({
    super.key,
    required this.chatId,
    required this.senderId,
  });

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  final AudioService _audioService = AudioService();
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    // Timer would be implemented to update recording duration
  }

  void _startRecording() async {
    final filePath =
        '/path/to/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final success = await _audioService.startRecording(filePath);

    if (success) {
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _stopRecording() async {
    final filePath = await _audioService.stopRecording();

    if (filePath != null) {
      if (!mounted) return;
      context.read<ChatCubit>().sendVoiceMessage(
        widget.chatId,
        widget.senderId,
        filePath,
      );
    }

    setState(() {
      _isRecording = false;
      _recordingDuration = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isRecording
              ? Colors.red.withValues()
              : Colors.grey.withValues(),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic, color: _isRecording ? Colors.red : Colors.grey),
            const SizedBox(width: 8),
            Text(
              _isRecording
                  ? 'Recording... ${_formatDuration(_recordingDuration)}'
                  : 'Hold to record',
              style: TextStyle(color: _isRecording ? Colors.red : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
