import 'package:equatable/equatable.dart';

abstract class AudioPlayerState extends Equatable {
  const AudioPlayerState();

  @override
  List<Object> get props => [];
}

class AudioPlayerInitial extends AudioPlayerState {}

class AudioPlayerLoading extends AudioPlayerState {}

class AudioPlayerLoaded extends AudioPlayerState {
  final String filePath;
  final String songTitle;
  final Duration duration;
  final Duration position;
  final bool isPlaying;
  final double playbackSpeed;
  final double volume;
  final bool isLooping;

  const AudioPlayerLoaded({
    required this.filePath,
    required this.songTitle,
    required this.duration,
    this.position = Duration.zero,
    this.isPlaying = false,
    this.playbackSpeed = 1.0,
    this.volume = 1.0,
    this.isLooping = false,
  });

  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  String get positionText {
    final minutes = position.inMinutes;
    final seconds = position.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get durationText {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get remainingText {
    final remaining = duration - position;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60);
    return '-${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  AudioPlayerLoaded copyWith({
    String? filePath,
    String? songTitle,
    Duration? duration,
    Duration? position,
    bool? isPlaying,
    double? playbackSpeed,
    double? volume,
    bool? isLooping,
  }) {
    return AudioPlayerLoaded(
      filePath: filePath ?? this.filePath,
      songTitle: songTitle ?? this.songTitle,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      volume: volume ?? this.volume,
      isLooping: isLooping ?? this.isLooping,
    );
  }

  @override
  List<Object> get props => [
    filePath,
    songTitle,
    duration,
    position,
    isPlaying,
    playbackSpeed,
    volume,
    isLooping,
  ];
}

class AudioPlayerError extends AudioPlayerState {
  final String message;

  const AudioPlayerError(this.message);

  @override
  List<Object> get props => [message];
}
