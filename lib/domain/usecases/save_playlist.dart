
import 'package:dartz/dartz.dart';
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/domain/entities/playlist.dart';
import 'package:iptvca/domain/repositories/playlist_repository.dart';

class SavePlaylist {
  SavePlaylist(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, void>> call(Playlist playlist) {
    return _repository.savePlaylist(playlist);
  }
}

