
import 'package:dartz/dartz.dart';
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/domain/entities/playlist.dart';
import 'package:iptvca/domain/repositories/playlist_repository.dart';

class GetPlaylists {
  GetPlaylists(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, List<Playlist>>> call() {
    return _repository.getPlaylists();
  }
}

