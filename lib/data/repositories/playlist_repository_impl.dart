
import 'package:dartz/dartz.dart';
import 'package:iptvca/core/errors/failures.dart';
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
  );

  final PlaylistRemoteDataSource _remoteDataSource;
  final PlaylistLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<Channel>>> loadPlaylistFromUrl(String url) async {
    try {
      final channels = await _remoteDataSource.parsePlaylistFromUrl(url);
      return Right(channels);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ParseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: 'Неизвестная ошибка: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Channel>>> loadPlaylistFromFile(
    String filePath,
  ) async {
    try {
      final channels = await _remoteDataSource.parsePlaylistFromFile(filePath);
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
      await _localDataSource.deletePlaylist(playlistId);
      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка удаления плейлиста: $e'));
    }
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

