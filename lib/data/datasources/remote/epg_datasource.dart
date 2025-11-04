import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:iptvca/core/storage/storage_interface.dart';
import 'package:iptvca/core/services/network_cache_service.dart';

/// Источник данных для получения EPG (Electronic Program Guide).
class EpgDataSource {
  EpgDataSource(this._storage, this._cacheService);
  final StorageInterface? _storage;
  final NetworkCacheService? _cacheService;
  static const String _defaultEpgUrl = 'http://epg.one/epg.xml.gz';
  static const String _cacheKey = 'epg_cache';
  static const String _cacheTimestampKey = 'epg_cache_timestamp';
  static const Duration _cacheValidityDuration = Duration(hours: 24);

  /// Получает EPG данные по указанному URL.
  ///
  /// Загружает gzip-сжатый XML файл, распаковывает его и парсит.
  /// Использует кэш, если данные актуальны.
  ///
  /// [url] - URL для загрузки EPG. Если не указан, используется
  /// значение по умолчанию: http://epg.one/epg.xml.gz
  /// [forceRefresh] - принудительно обновить данные, игнорируя кэш
  /// [onProgress] - callback для отслеживания прогресса загрузки
  ///
  /// Возвращает Map с ключами:
  /// - 'channels': Map<String, List<Map<String, dynamic>>> - программы,
  ///   сгруппированные по channelId
  /// - 'totalPrograms': int - общее количество программ
  ///
  /// Выбрасывает Exception при ошибках загрузки или парсинга.
  Future<Map<String, dynamic>> fetchEpg({
    String? url,
    bool forceRefresh = false,
    void Function(double progress)? onProgress,
  }) async {
    final epgUrl = url ?? _defaultEpgUrl;
    try {
      if (!forceRefresh && _storage != null) {
        final cachedData = await _getCachedEpg();
        if (cachedData != null) {
          developer.log('EPG загружен из кэша', name: 'EpgDataSource');
          onProgress?.call(1.0);
          return cachedData;
        }
      }
      developer.log('Начало загрузки EPG из: $epgUrl', name: 'EpgDataSource');
      onProgress?.call(0.1);
      final gzipBytes = await _fetchEpgInChunks(epgUrl, onProgress);
      developer.log(
        'EPG загружен: ${gzipBytes.length} байт',
        name: 'EpgDataSource',
      );
      onProgress?.call(0.4);
      final decompressedBytes = await compute(_decompressGzipCompute, gzipBytes);
      developer.log(
        'EPG распакован: ${decompressedBytes.length} байт',
        name: 'EpgDataSource',
      );
      onProgress?.call(0.6);
      final xmlString = await compute(_decodeUtf8Compute, decompressedBytes);
      onProgress?.call(0.7);
      final epgData = await compute(_parseXmlCompute, xmlString);
      developer.log(
        'EPG распарсен: ${epgData['totalPrograms']} программ для ${(epgData['channels'] as Map).length} каналов',
        name: 'EpgDataSource',
      );
      onProgress?.call(0.9);
      if (_storage != null) {
        await _saveCachedEpg(epgData);
      }
      onProgress?.call(1.0);
      return epgData;
    } catch (e, stackTrace) {
      developer.log(
        'Ошибка при получении EPG: $e',
        name: 'EpgDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      if (_storage != null && !forceRefresh) {
        final cachedData = await _getCachedEpg();
        if (cachedData != null) {
          developer.log('Используются кэшированные данные EPG', name: 'EpgDataSource');
          return cachedData;
        }
      }
      throw Exception('Ошибка при получении EPG: $e');
    }
  }

  Future<Map<String, dynamic>?> _getCachedEpg() async {
    final cacheService = _cacheService;
    if (cacheService != null) {
      final cachedJson = await cacheService.getCachedData(
        _cacheKey,
        cacheValidity: _cacheValidityDuration,
      );
      if (cachedJson != null) {
        try {
          final cachedData = await compute(_decodeJsonEpgCacheCompute, cachedJson);
          return cachedData;
        } catch (e) {
          developer.log('Ошибка декодирования кэша EPG: $e', name: 'EpgDataSource');
        }
      }
    }
    final storage = _storage;
    if (storage == null) return null;
    try {
      final timestampStr = await storage.getString(_cacheTimestampKey);
      if (timestampStr == null) return null;
      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      if (now.difference(timestamp) > _cacheValidityDuration) {
        return null;
      }
      final cachedJson = await storage.getString(_cacheKey);
      if (cachedJson == null) return null;
      final cachedData = await compute(_decodeJsonEpgCacheCompute, cachedJson);
      return cachedData;
    } catch (e) {
      developer.log('Ошибка чтения кэша EPG: $e', name: 'EpgDataSource');
      return null;
    }
  }

  Future<void> _saveCachedEpg(Map<String, dynamic> epgData) async {
    try {
      final jsonString = json.encode(epgData);
      final cacheService = _cacheService;
      if (cacheService != null) {
        await cacheService.saveCachedData(_cacheKey, jsonString);
        developer.log('EPG сохранен в кэш через NetworkCacheService', name: 'EpgDataSource');
      } else {
        final storage = _storage;
        if (storage == null) return;
        await storage.setString(_cacheKey, jsonString);
        await storage.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
        developer.log('EPG сохранен в кэш', name: 'EpgDataSource');
      }
    } catch (e) {
      developer.log('Ошибка сохранения кэша EPG: $e', name: 'EpgDataSource');
    }
  }

  static List<int> _decompressGzipCompute(List<int> gzipBytes) {
    try {
      final gzipDecoder = GZipCodec();
      return gzipDecoder.decode(gzipBytes);
    } catch (e) {
      throw Exception('Ошибка распаковки gzip: $e');
    }
  }

  static String _decodeUtf8Compute(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } catch (e) {
      throw Exception('Ошибка декодирования UTF-8: $e');
    }
  }

  static Map<String, dynamic> _decodeJsonEpgCacheCompute(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Ошибка декодирования JSON кэша EPG: $e');
    }
  }

  static Map<String, dynamic> _parseXmlCompute(String xmlString) {
    try {
      final document = xml.XmlDocument.parse(xmlString);
      final tvElement = document.rootElement;
      final Map<String, List<Map<String, dynamic>>> programsByChannel = {};
      final programmes = tvElement.findAllElements('programme');
      final totalProgrammes = programmes.length;
      var processed = 0;
      for (final programme in programmes) {
        final channelId = programme.getAttribute('channel');
        if (channelId == null) {
          processed++;
          continue;
        }
        final startStr = programme.getAttribute('start');
        final stopStr = programme.getAttribute('stop');
        final titleElement = programme.findElements('title').firstOrNull;
        final descElement = programme.findElements('desc').firstOrNull;
        final categoryElement = programme.findElements('category').firstOrNull;
        final iconElement = programme.findElements('icon').firstOrNull;
        if (startStr == null) {
          processed++;
          continue;
        }
        final startTime = _parseXmltvDate(startStr);
        final stopTime = stopStr != null ? _parseXmltvDate(stopStr) : null;
        final program = {
          'channelId': channelId,
          'title': titleElement?.innerText ?? '',
          'description': descElement?.innerText,
          'startTime': startTime.toIso8601String(),
          'endTime': stopTime?.toIso8601String(),
          'category': categoryElement?.innerText,
          'iconUrl': iconElement?.getAttribute('src'),
        };
        programsByChannel.putIfAbsent(channelId, () => []).add(program);
        processed++;
        if (processed % 1000 == 0) {
          developer.log(
            'Обработано программ: $processed из $totalProgrammes',
            name: 'EpgDataSource',
          );
        }
      }
      return {
        'channels': programsByChannel,
        'totalPrograms': programsByChannel.values
            .fold(0, (sum, programs) => sum + programs.length),
      };
    } catch (e) {
      throw Exception('Ошибка парсинга XML: $e');
    }
  }

  Future<List<int>> _fetchEpgInChunks(
    String url,
    void Function(double)? onProgress,
  ) async {
    try {
      final uri = Uri.parse(url);
      final request = http.Request('GET', uri);
      final streamedResponse = await http.Client().send(request).timeout(
        const Duration(seconds: 60),
      );
      if (streamedResponse.statusCode != 200) {
        throw Exception(
          'Ошибка загрузки EPG: статус ${streamedResponse.statusCode}',
        );
      }
      final contentLength = streamedResponse.contentLength ?? 0;
      final chunks = <List<int>>[];
      var totalBytesReceived = 0;
      await for (final chunk in streamedResponse.stream) {
        chunks.add(chunk);
        totalBytesReceived += chunk.length;
        if (onProgress != null && contentLength > 0) {
          final progress = 0.1 + (totalBytesReceived / contentLength) * 0.2;
          onProgress(progress);
        }
      }
      final bytes = chunks.expand((chunk) => chunk).toList();
      return bytes;
    } catch (e) {
      throw Exception('Ошибка загрузки EPG чанками: $e');
    }
  }

  static DateTime _parseXmltvDate(String dateStr) {
    if (dateStr.length < 14) {
      throw FormatException('Неверный формат даты XMLTV: $dateStr');
    }
    final year = int.parse(dateStr.substring(0, 4));
    final month = int.parse(dateStr.substring(4, 6));
    final day = int.parse(dateStr.substring(6, 8));
    final hour = int.parse(dateStr.substring(8, 10));
    final minute = int.parse(dateStr.substring(10, 12));
    final second = int.parse(dateStr.substring(12, 14));
    final timezoneOffset = dateStr.length > 14 ? dateStr.substring(14) : '+0000';
    final offsetHours = int.parse(timezoneOffset.substring(1, 3));
    final offsetMinutes = int.parse(timezoneOffset.substring(3, 5));
    final offset = Duration(
      hours: timezoneOffset[0] == '+' ? offsetHours : -offsetHours,
      minutes: offsetMinutes,
    );
    final dateTime = DateTime(
      year,
      month,
      day,
      hour,
      minute,
      second,
    );
    return dateTime.subtract(offset);
  }
}
