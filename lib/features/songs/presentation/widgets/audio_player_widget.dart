import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/audio_player_cubit.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/audio_player_state.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final String songTitle;

  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
    required this.songTitle,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  @override
  void initState() {
    super.initState();
    // Load audio when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioPlayerCubit>().loadAudio(
        widget.audioPath,
        widget.songTitle,
      );
    });
  }

  void _togglePlayPause() {
    context.read<AudioPlayerCubit>().togglePlayPause();
  }

  void _seekToPosition(double value) {
    final state = context.read<AudioPlayerCubit>().state;
    if (state is AudioPlayerLoaded) {
      final newPosition = Duration(
        milliseconds: (value * state.duration.inMilliseconds).toInt(),
      );
      context.read<AudioPlayerCubit>().seekTo(newPosition);
    }
  }

  void _skipForward() {
    context.read<AudioPlayerCubit>().skipForward(const Duration(seconds: 10));
  }

  void _skipBackward() {
    context.read<AudioPlayerCubit>().skipBackward(const Duration(seconds: 10));
  }

  void _setPlaybackSpeed(double speed) {
    context.read<AudioPlayerCubit>().setSpeed(speed);
  }

  Widget _buildPlayerControls(AudioPlayerLoaded state) {
    return Column(
      children: [
        // Progress Bar
        Slider(
          value: state.progress,
          onChanged: _seekToPosition,
          onChangeStart: (_) {
            // Pause while seeking
            if (state.isPlaying) {
              context.read<AudioPlayerCubit>().pause();
            }
          },
          onChangeEnd: (_) {
            // Resume after seeking if it was playing
            if (state.isPlaying) {
              context.read<AudioPlayerCubit>().play();
            }
          },
        ),

        // Time Indicators
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(state.positionText, style: AppTextStyles.caption),
              Text(state.durationText, style: AppTextStyles.caption),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Control Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skip Backward
            IconButton(
              icon: const Icon(Icons.replay_10),
              onPressed: _skipBackward,
              iconSize: 32,
              color: AppColors.primary,
            ),

            const SizedBox(width: 16),

            // Play/Pause
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  state.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _togglePlayPause,
                iconSize: 32,
              ),
            ),

            const SizedBox(width: 16),

            // Skip Forward
            IconButton(
              icon: const Icon(Icons.forward_10),
              onPressed: _skipForward,
              iconSize: 32,
              color: AppColors.primary,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Additional Controls
        _buildAdditionalControls(state),
      ],
    );
  }

  Widget _buildAdditionalControls(AudioPlayerLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Playback Speed
        PopupMenuButton<double>(
          icon: Row(
            children: [
              const Icon(Icons.speed, size: 16),
              const SizedBox(width: 4),
              Text('${state.playbackSpeed}x', style: AppTextStyles.caption),
            ],
          ),
          onSelected: _setPlaybackSpeed,
          itemBuilder: (context) =>
              [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                return PopupMenuItem<double>(
                  value: speed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${speed}x Speed'),
                      if (speed == state.playbackSpeed)
                        const Icon(Icons.check, size: 16),
                    ],
                  ),
                );
              }).toList(),
        ),

        // Volume (simplified)
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            // Show volume dialog
            _showVolumeDialog(state.volume);
          },
        ),

        // Loop
        IconButton(
          icon: Icon(
            state.isLooping ? Icons.loop : Icons.loop,
            color: state.isLooping ? AppColors.primary : AppColors.textDisabled,
          ),
          onPressed: () {
            // Toggle looping
          },
        ),
      ],
    );
  }

  void _showVolumeDialog(double currentVolume) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Volume'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: currentVolume,
              onChanged: (value) {
                context.read<AudioPlayerCubit>().setVolume(value);
              },
            ),
            Text('${(currentVolume * 100).toInt()}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: AppColors.error),
        const SizedBox(height: 16),
        Text('Audio Error', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        Text(
          message,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            context.read<AudioPlayerCubit>().loadAudio(
              widget.audioPath,
              widget.songTitle,
            );
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text('Loading Audio...', style: AppTextStyles.bodyMedium),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.audio_file, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.songTitle,
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('Audio Player', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Player Content
                if (state is AudioPlayerLoading) _buildLoadingState(),
                if (state is AudioPlayerError) _buildErrorState(state.message),
                if (state is AudioPlayerLoaded) _buildPlayerControls(state),
                if (state is AudioPlayerInitial) _buildLoadingState(),
              ],
            );
          },
        ),
      ),
    );
  }
}
