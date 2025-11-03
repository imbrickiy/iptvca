
import 'package:equatable/equatable.dart';
import 'package:iptvca/domain/entities/playlist.dart';

abstract class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlaylistsEvent extends PlaylistEvent {
  const LoadPlaylistsEvent();
}

class LoadPlaylistFromUrlEvent extends PlaylistEvent {
  const LoadPlaylistFromUrlEvent(this.url);
  final String url;

  @override
  List<Object?> get props => [url];
}

class LoadPlaylistFromFileEvent extends PlaylistEvent {
  const LoadPlaylistFromFileEvent(this.filePath);
  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

class SavePlaylistEvent extends PlaylistEvent {
  const SavePlaylistEvent(this.playlist);
  final Playlist playlist;

  @override
  List<Object?> get props => [playlist];
}

class DeletePlaylistEvent extends PlaylistEvent {
  const DeletePlaylistEvent(this.playlistId);
  final String playlistId;

  @override
  List<Object?> get props => [playlistId];
}

