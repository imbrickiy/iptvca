
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/core/storage/storage_interface.dart';
import 'package:iptvca/data/models/playlist_model.dart';
import 'dart:convert';

abstract class PlaylistLocalDataSource {
  Future<List<PlaylistModel>> getPlaylists();
  Future<void> savePlaylist(PlaylistModel playlist);
  Future<void> deletePlaylist(String playlistId);
  Future<PlaylistModel?> getPlaylistById(String playlistId);
}

class PlaylistLocalDataSourceImpl implements PlaylistLocalDataSource {
  PlaylistLocalDataSourceImpl(this._storage);

  final StorageInterface _storage;
  static const String _playlistsKey = 'playlists';

  @override
  Future<List<PlaylistModel>> getPlaylists() async {
    try {
      final jsonString = await _storage.getString(_playlistsKey);
      if (jsonString == null) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => PlaylistModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure(message: 'Ошибка чтения плейлистов: $e');
    }
  }

  @override
  Future<void> savePlaylist(PlaylistModel playlist) async {
    try {
      final playlists = await getPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlist.id);

      if (index >= 0) {
        playlists[index] = playlist;
      } else {
        playlists.add(playlist);
      }

      final jsonList = playlists.map((p) => p.toJson()).toList();
      await _storage.setString(_playlistsKey, json.encode(jsonList));
    } catch (e) {
      throw CacheFailure(message: 'Ошибка сохранения плейлиста: $e');
    }
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    try {
      final playlists = await getPlaylists();
      playlists.removeWhere((p) => p.id == playlistId);

      final jsonList = playlists.map((p) => p.toJson()).toList();
      await _storage.setString(_playlistsKey, json.encode(jsonList));
    } catch (e) {
      throw CacheFailure(message: 'Ошибка удаления плейлиста: $e');
    }
  }

  @override
  Future<PlaylistModel?> getPlaylistById(String playlistId) async {
    try {
      final playlists = await getPlaylists();
      return playlists.firstWhere(
        (p) => p.id == playlistId,
        orElse: () => throw CacheFailure(message: 'Плейлист не найден'),
      );
    } catch (e) {
      if (e is CacheFailure) {
        return null;
      }
      throw CacheFailure(message: 'Ошибка получения плейлиста: $e');
    }
  }
}

