
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iptvca/domain/usecases/delete_playlist.dart';
import 'package:iptvca/domain/usecases/get_playlists.dart';
import 'package:iptvca/domain/usecases/load_playlist_from_file.dart';
import 'package:iptvca/domain/usecases/load_playlist_from_url.dart';
import 'package:iptvca/domain/usecases/save_playlist.dart';
import 'package:iptvca/presentation/bloc/playlist/playlist_event.dart';
import 'package:iptvca/presentation/bloc/playlist/playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  PlaylistBloc(
    this._getPlaylists,
    this._loadPlaylistFromUrl,
    this._loadPlaylistFromFile,
    this._savePlaylist,
    this._deletePlaylist,
  ) : super(const PlaylistInitial()) {
    on<LoadPlaylistsEvent>(_onLoadPlaylists);
    on<LoadPlaylistFromUrlEvent>(_onLoadPlaylistFromUrl);
    on<LoadPlaylistFromFileEvent>(_onLoadPlaylistFromFile);
    on<SavePlaylistEvent>(_onSavePlaylist);
    on<DeletePlaylistEvent>(_onDeletePlaylist);
  }

  final GetPlaylists _getPlaylists;
  final LoadPlaylistFromUrl _loadPlaylistFromUrl;
  final LoadPlaylistFromFile _loadPlaylistFromFile;
  final SavePlaylist _savePlaylist;
  final DeletePlaylist _deletePlaylist;

  Future<void> _onLoadPlaylists(
    LoadPlaylistsEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(const PlaylistLoading());
    final result = await _getPlaylists();
    result.fold(
      (failure) => emit(PlaylistError(failure.message ?? 'Ошибка загрузки')),
      (playlists) => emit(PlaylistLoaded(playlists)),
    );
  }

  Future<void> _onLoadPlaylistFromUrl(
    LoadPlaylistFromUrlEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(const PlaylistLoading());
    final result = await _loadPlaylistFromUrl(event.url);
    result.fold(
      (failure) => emit(PlaylistError(failure.message ?? 'Ошибка загрузки')),
      (channels) => emit(ChannelsLoaded(channels)),
    );
  }

  Future<void> _onLoadPlaylistFromFile(
    LoadPlaylistFromFileEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(const PlaylistLoading());
    final result = await _loadPlaylistFromFile(event.filePath);
    result.fold(
      (failure) => emit(PlaylistError(failure.message ?? 'Ошибка загрузки')),
      (channels) => emit(ChannelsLoaded(channels)),
    );
  }

  Future<void> _onSavePlaylist(
    SavePlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(const PlaylistLoading());
    final result = await _savePlaylist(event.playlist);
    result.fold(
      (failure) => emit(PlaylistError(failure.message ?? 'Ошибка сохранения')),
      (_) {
        emit(const PlaylistSaved());
        add(const LoadPlaylistsEvent());
      },
    );
  }

  Future<void> _onDeletePlaylist(
    DeletePlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(const PlaylistLoading());
    final result = await _deletePlaylist(event.playlistId);
    result.fold(
      (failure) => emit(PlaylistError(failure.message ?? 'Ошибка удаления')),
      (_) {
        emit(const PlaylistDeleted());
        add(const LoadPlaylistsEvent());
      },
    );
  }
}

