
import 'package:equatable/equatable.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:iptvca/domain/entities/playlist.dart';

abstract class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object?> get props => [];
}

class PlaylistInitial extends PlaylistState {
  const PlaylistInitial();
}

class PlaylistLoading extends PlaylistState {
  const PlaylistLoading();
}

class PlaylistLoaded extends PlaylistState {
  const PlaylistLoaded(this.playlists);
  final List<Playlist> playlists;

  @override
  List<Object?> get props => [playlists];
}

class ChannelsLoaded extends PlaylistState {
  const ChannelsLoaded(this.channels);
  final List<Channel> channels;

  @override
  List<Object?> get props => [channels];
}

class PlaylistError extends PlaylistState {
  const PlaylistError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class PlaylistSaved extends PlaylistState {
  const PlaylistSaved();
}

class PlaylistDeleted extends PlaylistState {
  const PlaylistDeleted();
}

