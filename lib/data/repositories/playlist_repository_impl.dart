
import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/core/services/channels_cache_service.dart';
import 'package:iptvca/data/datasources/local/playlist_local_datasource.dart';
import 'package:iptvca/data/datasources/remote/playlist_remote_datasource.dart';
import 'package:iptvca/data/models/playlist_model.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:iptvca/domain/entities/playlist.dart';
import 'package:iptvca/domain/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  PlaylistRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._channelsCacheService,
  );

  final PlaylistRemoteDataSource _remoteDataSource;
  final PlaylistLocalDataSource _localDataSource;
  final ChannelsCacheService? _channelsCacheService;

  @override
  Future<Either<Failure, List<Channel>>> loadPlaylistFromUrl(String url) async {
    try {
      final channels = await _remoteDataSource.parsePlaylistFromUrl(url);
      if (channels.isNotEmpty && _channelsCacheService != null) {
        _updateChannelsCacheAfterLoad(channels);
      }
      return Right(channels);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ParseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: 'Неизвестная ошибка: $e'));
    }
  }

  void _updateChannelsCacheAfterLoad(List<Channel> newChannels) {
    Future.microtask(() async {
      try {
        final allPlaylists = await _localDataSource.getPlaylists();
        final allChannels = <Channel>[];
        for (final playlist in allPlaylists) {
          if (playlist.isActive) {
            allChannels.addAll(playlist.channels);
          }
        }
        allChannels.addAll(newChannels);
        await _channelsCacheService!.saveChannels(allChannels);
        developer.log(
          'Кэш каналов обновлен после загрузки: ${newChannels.length} новых каналов, всего: ${allChannels.length}',
          name: 'PlaylistRepository',
        );
      } catch (e) {
        developer.log(
          'Ошибка обновления кэша каналов после загрузки: $e',
          name: 'PlaylistRepository',
        );
      }
    });
  }

  @override
  Future<Either<Failure, List<Channel>>> loadPlaylistFromFile(
    String filePath,
  ) async {
    try {
      final channels = await _remoteDataSource.parsePlaylistFromFile(filePath);
      if (channels.isNotEmpty && _channelsCacheService != null) {
        _updateChannelsCacheAfterLoad(channels);
      }
      return Right(channels);
    } on ValidationFailure catch (e) {
      return Left(e);
    } on ParseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: 'Неизвестная ошибка: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Playlist>>> getPlaylists() async {
    try {
      final playlists = await _localDataSource.getPlaylists();
      return Right(playlists);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка получения плейлистов: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> savePlaylist(Playlist playlist) async {
    try {
      final playlistModel = PlaylistModel.fromEntity(playlist);
      await _localDataSource.savePlaylist(playlistModel);
      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка сохранения плейлиста: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlaylist(String playlistId) async {
    try {
      final playlists = await _localDataSource.getPlaylists();
      playlists.firstWhere(
        (p) => p.id == playlistId,
        orElse: () => throw CacheFailure(message: 'Плейлист не найден'),
      );
      await _localDataSource.deletePlaylist(playlistId, playlists: playlists);
      if (_channelsCacheService != null) {
        _updateChannelsCacheAfterDeletion();
      }
      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка удаления плейлиста: $e'));
    }
  }

  void _updateChannelsCacheAfterDeletion() {
    Future.microtask(() async {
      try {
        final allPlaylists = await _localDataSource.getPlaylists();
        final allChannels = <Channel>[];
        for (final playlist in allPlaylists) {
          if (playlist.isActive) {
            allChannels.addAll(playlist.channels);
          }
        }
        if (allChannels.isNotEmpty) {
          await _channelsCacheService!.saveChannels(allChannels);
          developer.log(
            'Кэш каналов обновлен после удаления плейлиста',
            name: 'PlaylistRepository',
          );
        } else {
          await _channelsCacheService!.clearCache();
          developer.log(
            'Кэш каналов очищен, так как активных плейлистов не осталось',
            name: 'PlaylistRepository',
          );
        }
      } catch (e) {
        developer.log(
          'Ошибка обновления кэша каналов после удаления плейлиста: $e',
          name: 'PlaylistRepository',
        );
      }
    });
  }

  @override
  Future<Either<Failure, Playlist?>> getPlaylistById(String playlistId) async {
    try {
      final playlist = await _localDataSource.getPlaylistById(playlistId);
      return Right(playlist);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка получения плейлиста: $e'));
    }
  }
}

