
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:iptvca/domain/entities/playlist.dart';
import 'package:dartz/dartz.dart';

abstract class PlaylistRepository {
  Future<Either<Failure, List<Channel>>> loadPlaylistFromUrl(String url);
  Future<Either<Failure, List<Channel>>> loadPlaylistFromFile(String filePath);
  Future<Either<Failure, List<Playlist>>> getPlaylists();
  Future<Either<Failure, void>> savePlaylist(Playlist playlist);
  Future<Either<Failure, void>> deletePlaylist(String playlistId);
  Future<Either<Failure, Playlist?>> getPlaylistById(String playlistId);
}

