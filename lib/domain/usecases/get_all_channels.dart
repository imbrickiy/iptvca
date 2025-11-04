import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/core/services/channels_cache_service.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:iptvca/domain/repositories/playlist_repository.dart';

class GetAllChannels {
  GetAllChannels(this._repository, this._cacheService);
  final PlaylistRepository _repository;
  final ChannelsCacheService _cacheService;

  Future<Either<Failure, List<Channel>>> call({bool useCache = true}) async {
    if (useCache) {
      final cachedChannels = await _cacheService.loadChannels();
      if (cachedChannels != null && cachedChannels.isNotEmpty) {
        developer.log(
          'Загружено ${cachedChannels.length} каналов из кэша',
          name: 'GetAllChannels',
        );
        return Right(cachedChannels);
      }
    }
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
        if (allChannels.isNotEmpty) {
          _cacheService.saveChannels(allChannels).then((_) {
            developer.log(
              'Сохранено ${allChannels.length} каналов в кэш',
              name: 'GetAllChannels',
            );
          }).catchError((e) {
            developer.log(
              'Ошибка сохранения каналов в кэш: $e',
              name: 'GetAllChannels',
            );
          });
        }
        return Right(allChannels);
      },
    );
  }
}

