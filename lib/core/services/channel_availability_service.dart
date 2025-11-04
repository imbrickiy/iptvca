import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:iptvca/core/constants/app_constants.dart';
import 'package:iptvca/domain/entities/channel.dart';

enum ChannelAvailabilityStatus {
  available,
  unavailable,
  unknown,
}

class ChannelAvailabilityResult {
  ChannelAvailabilityResult({
    required this.channel,
    required this.status,
    this.errorMessage,
    this.checkedAt,
  });

  final Channel channel;
  final ChannelAvailabilityStatus status;
  final String? errorMessage;
  final DateTime? checkedAt;

  bool get isAvailable => status == ChannelAvailabilityStatus.available;
}

class ChannelAvailabilityService {
  ChannelAvailabilityService(this._httpClient);

  final http.Client _httpClient;
  final Map<String, ChannelAvailabilityResult> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  Future<ChannelAvailabilityResult> checkChannel(Channel channel) async {
    try {
      final cacheKey = channel.id;
      final cachedResult = _getCachedResult(cacheKey);
      if (cachedResult != null) {
        developer.log(
          'Результат проверки канала ${channel.name} загружен из кэша',
          name: 'ChannelAvailabilityService',
        );
        return cachedResult;
      }
      developer.log(
        'Проверка доступности канала: ${channel.name} (${channel.url})',
        name: 'ChannelAvailabilityService',
      );
      final uri = Uri.parse(channel.url);
      final isAvailable = await _checkUrlAvailability(uri);
      final result = ChannelAvailabilityResult(
        channel: channel,
        status: isAvailable
            ? ChannelAvailabilityStatus.available
            : ChannelAvailabilityStatus.unavailable,
        checkedAt: DateTime.now(),
      );
      _cacheResult(cacheKey, result);
      developer.log(
        'Канал ${channel.name} ${isAvailable ? "доступен" : "недоступен"}',
        name: 'ChannelAvailabilityService',
      );
      return result;
    } catch (e) {
      developer.log(
        'Ошибка проверки канала ${channel.name}: $e',
        name: 'ChannelAvailabilityService',
      );
      final result = ChannelAvailabilityResult(
        channel: channel,
        status: ChannelAvailabilityStatus.unknown,
        errorMessage: e.toString(),
        checkedAt: DateTime.now(),
      );
      _cacheResult(channel.id, result);
      return result;
    }
  }

  Future<List<ChannelAvailabilityResult>> checkChannels(
    List<Channel> channels, {
    int maxConcurrent = AppConstants.maxConcurrentChannelChecks,
  }) async {
    final results = <ChannelAvailabilityResult>[];
    for (var i = 0; i < channels.length; i += maxConcurrent) {
      final batch = channels.skip(i).take(maxConcurrent).toList();
      final batchResults = await Future.wait(
        batch.map((channel) => checkChannel(channel)),
      );
      results.addAll(batchResults);
    }
    return results;
  }

  Future<bool> _checkUrlAvailability(Uri uri) async {
    try {
      final request = http.Request('HEAD', uri);
      request.headers['User-Agent'] = AppConstants.userAgent;
      request.headers['Accept'] = '*/*';
      final streamedResponse = await _httpClient
          .send(request)
          .timeout(AppConstants.channelCheckTimeout);
      final statusCode = streamedResponse.statusCode;
      await streamedResponse.stream.drain();
      if (statusCode >= 200 && statusCode < 400) {
        return true;
      }
      if (statusCode == 405) {
        return await _checkUrlAvailabilityWithGet(uri);
      }
      return false;
    } catch (e) {
      if (e.toString().contains('405') || e.toString().contains('Method Not Allowed')) {
        return await _checkUrlAvailabilityWithGet(uri);
      }
      return false;
    }
  }

  Future<bool> _checkUrlAvailabilityWithGet(Uri uri) async {
    try {
      final request = http.Request('GET', uri);
      request.headers['User-Agent'] = AppConstants.userAgent;
      request.headers['Accept'] = '*/*';
      request.headers['Range'] = 'bytes=0-${AppConstants.channelCheckRangeBytes}';
      final streamedResponse = await _httpClient
          .send(request)
          .timeout(AppConstants.channelCheckTimeout);
      final statusCode = streamedResponse.statusCode;
      await streamedResponse.stream.drain();
      return statusCode >= 200 && statusCode < 400;
    } catch (e) {
      return false;
    }
  }

  ChannelAvailabilityResult? _getCachedResult(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) {
      return null;
    }
    final age = DateTime.now().difference(timestamp);
    if (age > AppConstants.channelCacheDuration) {
      _cache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
      return null;
    }
    return _cache[cacheKey];
  }

  void _cacheResult(String cacheKey, ChannelAvailabilityResult result) {
    _cache[cacheKey] = result;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    developer.log(
      'Кэш проверки доступности каналов очищен',
      name: 'ChannelAvailabilityService',
    );
  }

  void clearChannelCache(String channelId) {
    _cache.remove(channelId);
    _cacheTimestamps.remove(channelId);
    developer.log(
      'Кэш проверки канала $channelId очищен',
      name: 'ChannelAvailabilityService',
    );
  }

  ChannelAvailabilityResult? getCachedResult(String channelId) {
    return _getCachedResult(channelId);
  }
}

