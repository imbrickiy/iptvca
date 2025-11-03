import 'package:dartz/dartz.dart';
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:iptvca/domain/repositories/playlist_repository.dart';

class GetAllChannels {
  GetAllChannels(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, List<Channel>>> call() async {
    final playlistsResult = await _repository.getPlaylists();
    return playlistsResult.fold(
      (failure) => Left(failure),
      (playlists) {
        final allChannels = <Channel>[];
        for (final playlist in playlists) {
          if (playlist.isActive) {
            allChannels.addAll(playlist.channels);
          }
        }
        return Right(allChannels);
      },
    );
  }
}

