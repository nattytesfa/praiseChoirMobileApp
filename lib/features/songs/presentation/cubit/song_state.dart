import 'package:equatable/equatable.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';

abstract class SongState extends Equatable {
  const SongState();

  @override
  List<Object> get props => [];
}

class SongInitial extends SongState {}

class SongLoading extends SongState {}

class SongLoaded extends SongState {
  final List<SongModel> songs;
  final List<SongModel>? filteredSongs;

  const SongLoaded(this.songs, {this.filteredSongs});

  @override
  List<Object> get props => [songs, filteredSongs ?? []];
}

class SongError extends SongState {
  final String message;

  const SongError(this.message);

  @override
  List<Object> get props => [message];
}

class SongSearchResults extends SongState {
  final List<SongModel> results;

  const SongSearchResults(this.results);

  @override
  List<Object> get props => [results];
}

class SongDetailLoaded extends SongState {
  final SongModel song;

  const SongDetailLoaded(this.song);

  @override
  List<Object> get props => [song];
}
