import 'package:audio_service/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:praise_choir_app/features/songs/presentation/cubit/audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayerCubit({required AudioService audioService})
    : super(AudioPlayerInitial());

  // Load and play audio file
  Future<void> loadAudio(String filePath, String songTitle) async {
    emit(AudioPlayerLoading());

    try {
      await _audioPlayer.setFilePath(filePath);
      emit(
        AudioPlayerLoaded(
          filePath: filePath,
          songTitle: songTitle,
          duration: _audioPlayer.duration ?? Duration.zero,
          isPlaying: false,
        ),
      );
    } catch (e) {
      emit(AudioPlayerError('Failed to load audio: ${e.toString()}'));
    }
  }

  // Play audio
  Future<void> play() async {
    final currentState = state;
    if (currentState is AudioPlayerLoaded) {
      try {
        await _audioPlayer.play();
        emit(currentState.copyWith(isPlaying: true));

        // Listen for position updates
        _audioPlayer.positionStream.listen((position) {
          if (state is AudioPlayerLoaded) {
            final loadedState = state as AudioPlayerLoaded;
            emit(loadedState.copyWith(position: position));
          }
        });

        // Listen for completion
        _audioPlayer.playerStateStream.listen((playerState) {
          if (playerState.processingState == ProcessingState.completed) {
            pause();
            seekTo(Duration.zero);
          }
        });
      } catch (e) {
        emit(AudioPlayerError('Failed to play audio: ${e.toString()}'));
      }
    }
  }

  // Pause audio
  Future<void> pause() async {
    final currentState = state;
    if (currentState is AudioPlayerLoaded) {
      try {
        await _audioPlayer.pause();
        emit(currentState.copyWith(isPlaying: false));
      } catch (e) {
        emit(AudioPlayerError('Failed to pause audio: ${e.toString()}'));
      }
    }
  }

  // Stop audio
  Future<void> stop() async {
    final currentState = state;
    if (currentState is AudioPlayerLoaded) {
      try {
        await _audioPlayer.stop();
        emit(currentState.copyWith(isPlaying: false, position: Duration.zero));
      } catch (e) {
        emit(AudioPlayerError('Failed to stop audio: ${e.toString()}'));
      }
    }
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    final currentState = state;
    if (currentState is AudioPlayerLoaded) {
      try {
        await _audioPlayer.seek(position);
        emit(currentState.copyWith(position: position));
      } catch (e) {
        emit(AudioPlayerError('Failed to seek: ${e.toString()}'));
      }
    }
  }

  // Set playback speed
  Future<void> setSpeed(double speed) async {
    final currentState = state;
    if (currentState is AudioPlayerLoaded) {
      try {
        await _audioPlayer.setSpeed(speed);
        emit(currentState.copyWith(playbackSpeed: speed));
      } catch (e) {
        emit(AudioPlayerError('Failed to set speed: ${e.toString()}'));
      }
    }
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    final currentState = state;
    if (currentState is AudioPlayerLoaded) {
      try {
        await _audioPlayer.setVolume(volume);
        emit(currentState.copyWith(volume: volume));
      } catch (e) {
        emit(AudioPlayerError('Failed to set volume: ${e.toString()}'));
      }
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    final currentState = state;
    if (currentState is AudioPlayerLoaded) {
      if (currentState.isPlaying) {
        await pause();
      } else {
        await play();
      }
    }
  }

  // Skip forward
  Future<void> skipForward(Duration duration) async {
    final currentState = state;
    if (currentState is AudioPlayerLoaded) {
      final newPosition = currentState.position + duration;
      final maxPosition = currentState.duration;

      if (newPosition < maxPosition) {
        await seekTo(newPosition);
      } else {
        await seekTo(maxPosition);
      }
    }
  }

  // Skip backward
  Future<void> skipBackward(Duration duration) async {
    final currentState = state;
    if (currentState is AudioPlayerLoaded) {
      final newPosition = currentState.position - duration;

      if (newPosition > Duration.zero) {
        await seekTo(newPosition);
      } else {
        await seekTo(Duration.zero);
      }
    }
  }

  // Dispose resources
  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
