
import 'package:dartz/dartz.dart';
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:iptvca/domain/repositories/playlist_repository.dart';

class LoadPlaylistFromFile {
  LoadPlaylistFromFile(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, List<Channel>>> call(String filePath) {
    return _repository.loadPlaylistFromFile(filePath);
  }
}

