import 'package:dartz/dartz.dart';
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/domain/repositories/playlist_repository.dart';

class DeletePlaylist {
  DeletePlaylist(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, void>> call(String playlistId) {
    return _repository.deletePlaylist(playlistId);
  }
}

