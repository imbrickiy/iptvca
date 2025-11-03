
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:iptvca/core/errors/failures.dart';
import 'package:iptvca/core/constants/app_constants.dart';
import 'package:iptvca/data/datasources/remote/m3u_parser.dart';
import 'package:iptvca/data/models/channel_model.dart';

abstract class PlaylistRemoteDataSource {
  Future<String> fetchPlaylistFromUrl(String url);
  Future<List<ChannelModel>> parsePlaylistFromUrl(String url);
  Future<List<ChannelModel>> parsePlaylistFromFile(String filePath);
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  PlaylistRemoteDataSourceImpl(
    this._client,
    this._parser,
  );

  final http.Client _client;
  final M3uParser _parser;

  @override
  Future<String> fetchPlaylistFromUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await _client
          .get(uri)
          .timeout(AppConstants.connectionTimeout);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw NetworkFailure(
          message: 'Ошибка загрузки плейлиста: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is NetworkFailure) {
        rethrow;
      }
      throw NetworkFailure(message: 'Ошибка сети: $e');
    }
  }

  @override
  Future<List<ChannelModel>> parsePlaylistFromUrl(String url) async {
    try {
      final content = await fetchPlaylistFromUrl(url);
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
      String content;
      if (filePath.startsWith('assets/')) {
        try {
          developer.log('Попытка загрузить из assets: $filePath', name: 'PlaylistRemoteDataSource');
          content = await rootBundle.loadString(filePath);
          developer.log('Файл загружен из assets как UTF-8', name: 'PlaylistRemoteDataSource');
        } catch (e) {
          developer.log('Ошибка загрузки из assets: $e', name: 'PlaylistRemoteDataSource');
          throw ValidationFailure(message: 'Ошибка загрузки из assets: $e');
        }
      } else {
        final file = File(filePath);
        if (!await file.exists()) {
          throw ValidationFailure(message: 'Файл не найден: $filePath');
        }
        final fileSize = await file.length();
        developer.log('Размер файла: $fileSize байт', name: 'PlaylistRemoteDataSource');
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

