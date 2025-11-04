
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/core/constants/app_constants.dart';
import 'package:iptvca/core/services/network_cache_service.dart';
import 'package:iptvca/data/datasources/remote/m3u_parser.dart';
import 'package:iptvca/data/models/channel_model.dart';

abstract class PlaylistRemoteDataSource {
  Future<String> fetchPlaylistFromUrl(String url, {bool forceRefresh = false});
  Future<List<ChannelModel>> parsePlaylistFromUrl(String url, {bool forceRefresh = false});
  Future<List<ChannelModel>> parsePlaylistFromFile(String filePath);
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  PlaylistRemoteDataSourceImpl(
    this._client,
    this._parser,
    this._cacheService,
  );

  final http.Client _client;
  final M3uParser _parser;
  final NetworkCacheService? _cacheService;

  @override
  Future<String> fetchPlaylistFromUrl(String url, {bool forceRefresh = false}) async {
    try {
      final cacheService = _cacheService;
      if (!forceRefresh && cacheService != null) {
        final cacheKey = NetworkCacheService.generateCacheKey(url);
        final cachedData = await cacheService.getCachedData(cacheKey);
        if (cachedData != null) {
          developer.log(
            'Плейлист загружен из кэша: $url',
            name: 'PlaylistRemoteDataSource',
          );
          return cachedData;
        }
      }
      developer.log(
        'Начало загрузки плейлиста из: $url',
        name: 'PlaylistRemoteDataSource',
      );
      final uri = Uri.parse(url);
      final response = await _client
          .get(uri)
          .timeout(AppConstants.connectionTimeout);
      if (response.statusCode == 200) {
        final content = response.body;
        final cacheService = _cacheService;
        if (cacheService != null) {
          final cacheKey = NetworkCacheService.generateCacheKey(url);
          await cacheService.saveCachedData(cacheKey, content);
        }
        developer.log(
          'Плейлист загружен: ${content.length} символов',
          name: 'PlaylistRemoteDataSource',
        );
        return content;
      } else {
        throw NetworkFailure(
          message: 'Ошибка загрузки плейлиста: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is NetworkFailure) {
        final cacheService = _cacheService;
        if (cacheService != null) {
          final cacheKey = NetworkCacheService.generateCacheKey(url);
          final cachedData = await cacheService.getCachedData(cacheKey);
          if (cachedData != null) {
            developer.log(
              'Используются кэшированные данные плейлиста',
              name: 'PlaylistRemoteDataSource',
            );
            return cachedData;
          }
        }
        rethrow;
      }
      throw NetworkFailure(message: 'Ошибка сети: $e');
    }
  }

  @override
  Future<List<ChannelModel>> parsePlaylistFromUrl(String url, {bool forceRefresh = false}) async {
    try {
      final content = await fetchPlaylistFromUrl(url, forceRefresh: forceRefresh);
      return _parser.parsePlaylist(content);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ParseFailure(message: 'Ошибка парсинга плейлиста: $e');
    }
  }

  @override
  Future<List<ChannelModel>> parsePlaylistFromFile(String filePath) async {
    try {
      developer.log('Чтение файла плейлиста: $filePath', name: 'PlaylistRemoteDataSource');
      final file = File(filePath);
      if (!await file.exists()) {
        throw ValidationFailure(message: 'Файл не найден: $filePath');
      }
      final fileSize = await file.length();
      developer.log('Размер файла: $fileSize байт', name: 'PlaylistRemoteDataSource');
      String content;
      try {
        content = await file.readAsString(encoding: utf8);
        developer.log('Файл прочитан как UTF-8', name: 'PlaylistRemoteDataSource');
      } catch (e) {
        developer.log('Ошибка чтения UTF-8: $e, пробую Latin1', name: 'PlaylistRemoteDataSource');
        try {
          content = await file.readAsString(encoding: latin1);
          developer.log('Файл прочитан как Latin1', name: 'PlaylistRemoteDataSource');
        } catch (e2) {
          developer.log('Ошибка чтения Latin1: $e2, пробую дефолтную кодировку', name: 'PlaylistRemoteDataSource');
          content = await file.readAsString();
        }
      }
      developer.log('Длина содержимого: ${content.length} символов', name: 'PlaylistRemoteDataSource');
      final channels = await _parser.parsePlaylist(content);
      developer.log('Из файла извлечено ${channels.length} каналов', name: 'PlaylistRemoteDataSource');
      return channels;
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ParseFailure(message: 'Ошибка чтения файла: $e');
    }
  }
}

