import 'dart:developer' as developer;
import 'package:iptvca/core/storage/storage_interface.dart';

/// Универсальный сервис для кэширования сетевых запросов.
class NetworkCacheService {
  NetworkCacheService(this._storage);
  final StorageInterface? _storage;
  static const String _cachePrefix = 'network_cache_';
  static const String _timestampPrefix = 'network_cache_timestamp_';
  static const Duration _defaultCacheValidity = Duration(hours: 24);

  /// Получает данные из кэша по ключу.
  ///
  /// [key] - уникальный ключ для кэшируемых данных
  /// [cacheValidity] - время жизни кэша (по умолчанию 24 часа)
  ///
  /// Возвращает null, если кэш отсутствует или устарел.
  Future<String?> getCachedData(String key, {Duration? cacheValidity}) async {
    final storage = _storage;
    if (storage == null) return null;
    try {
      final timestampKey = _timestampPrefix + key;
      final timestampStr = await storage.getString(timestampKey);
      if (timestampStr == null) return null;
      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final validity = cacheValidity ?? _defaultCacheValidity;
      if (now.difference(timestamp) > validity) {
        developer.log(
          'Кэш устарел для ключа: $key',
          name: 'NetworkCacheService',
        );
        return null;
      }
      final cacheKey = _cachePrefix + key;
      final cachedData = await storage.getString(cacheKey);
      if (cachedData != null) {
        developer.log(
          'Данные загружены из кэша для ключа: $key',
          name: 'NetworkCacheService',
        );
      }
      return cachedData;
    } catch (e) {
      developer.log(
        'Ошибка чтения кэша для ключа $key: $e',
        name: 'NetworkCacheService',
      );
      return null;
    }
  }

  /// Сохраняет данные в кэш.
  ///
  /// [key] - уникальный ключ для кэшируемых данных
  /// [data] - данные для кэширования
  Future<void> saveCachedData(String key, String data) async {
    final storage = _storage;
    if (storage == null) return;
    try {
      final cacheKey = _cachePrefix + key;
      final timestampKey = _timestampPrefix + key;
      await storage.setString(cacheKey, data);
      await storage.setString(
        timestampKey,
        DateTime.now().toIso8601String(),
      );
      developer.log(
        'Данные сохранены в кэш для ключа: $key',
        name: 'NetworkCacheService',
      );
    } catch (e) {
      developer.log(
        'Ошибка сохранения кэша для ключа $key: $e',
        name: 'NetworkCacheService',
      );
    }
  }

  /// Удаляет кэш по ключу.
  Future<void> clearCache(String key) async {
    final storage = _storage;
    if (storage == null) return;
    try {
      final cacheKey = _cachePrefix + key;
      final timestampKey = _timestampPrefix + key;
      await storage.remove(cacheKey);
      await storage.remove(timestampKey);
      developer.log(
        'Кэш удален для ключа: $key',
        name: 'NetworkCacheService',
      );
    } catch (e) {
      developer.log(
        'Ошибка удаления кэша для ключа $key: $e',
        name: 'NetworkCacheService',
      );
    }
  }

  /// Генерирует ключ кэша на основе URL.
  static String generateCacheKey(String url) {
    return url.hashCode.toString();
  }
}

