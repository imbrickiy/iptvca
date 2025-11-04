import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:iptvca/core/constants/app_constants.dart';
import 'package:iptvca/data/models/channel_model.dart';
import 'package:iptvca/domain/entities/channel.dart';

class ChannelsCacheService {

  Future<File> _getCacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/${AppConstants.channelsCacheFileName}');
  }

  Future<File> _getMetadataFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/${AppConstants.channelsCacheMetadataFileName}');
  }

  Future<void> saveChannels(List<Channel> channels) async {
    try {
      final cacheFile = await _getCacheFile();
      final metadataFile = await _getMetadataFile();
      final jsonList = channels.map((channel) {
        final model = ChannelModel.fromEntity(channel);
        return model.toJson();
      }).toList();
      final jsonString = await compute(_encodeChannelsJsonCompute, jsonList);
      await cacheFile.writeAsString(jsonString);
      final metadata = {
        'saved_at': DateTime.now().toIso8601String(),
        'channels_count': channels.length,
      };
      await metadataFile.writeAsString(json.encode(metadata));
      developer.log(
        'Сохранено ${channels.length} каналов в кэш',
        name: 'ChannelsCacheService',
      );
    } catch (e) {
      developer.log(
        'Ошибка сохранения каналов в кэш: $e',
        name: 'ChannelsCacheService',
      );
    }
  }

  Future<List<Channel>?> loadChannels() async {
    try {
      final cacheFile = await _getCacheFile();
      if (!await cacheFile.exists()) {
        developer.log(
          'Файл кэша каналов не найден',
          name: 'ChannelsCacheService',
        );
        return null;
      }
      final jsonString = await cacheFile.readAsString();
      if (jsonString.isEmpty) {
        developer.log(
          'Файл кэша каналов пуст',
          name: 'ChannelsCacheService',
        );
        return null;
      }
      final List<dynamic> jsonList = await compute(_decodeChannelsJsonCompute, jsonString);
      final channels = jsonList
          .map((json) => ChannelModel.fromJson(json as Map<String, dynamic>))
          .toList();
      developer.log(
        'Загружено ${channels.length} каналов из кэша',
        name: 'ChannelsCacheService',
      );
      return channels;
    } catch (e) {
      developer.log(
        'Ошибка загрузки каналов из кэша: $e',
        name: 'ChannelsCacheService',
      );
      return null;
    }
  }

  Future<DateTime?> getCacheDate() async {
    try {
      final metadataFile = await _getMetadataFile();
      if (!await metadataFile.exists()) {
        return null;
      }
      final jsonString = await metadataFile.readAsString();
      final metadata = json.decode(jsonString) as Map<String, dynamic>;
      final savedAt = metadata['saved_at'] as String?;
      if (savedAt != null) {
        return DateTime.parse(savedAt);
      }
      return null;
    } catch (e) {
      developer.log(
        'Ошибка получения даты кэша: $e',
        name: 'ChannelsCacheService',
      );
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      final cacheFile = await _getCacheFile();
      final metadataFile = await _getMetadataFile();
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }
      developer.log(
        'Кэш каналов очищен',
        name: 'ChannelsCacheService',
      );
    } catch (e) {
      developer.log(
        'Ошибка очистки кэша каналов: $e',
        name: 'ChannelsCacheService',
      );
    }
  }

  static String _encodeChannelsJsonCompute(List<Map<String, dynamic>> jsonList) {
    try {
      return json.encode(jsonList);
    } catch (e) {
      throw Exception('Ошибка кодирования JSON каналов: $e');
    }
  }

  static List<dynamic> _decodeChannelsJsonCompute(String jsonString) {
    try {
      return json.decode(jsonString) as List<dynamic>;
    } catch (e) {
      throw Exception('Ошибка декодирования JSON каналов: $e');
    }
  }
}

