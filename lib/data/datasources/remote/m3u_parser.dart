
import 'dart:developer' as developer;
import 'package:iptvca/data/models/channel_model.dart';
import 'package:iptvca/core/errors/failures.dart';
import 'package:uuid/uuid.dart';

class M3uParser {
  M3uParser(this._uuid);
  final Uuid _uuid;
  Uuid get uuid => _uuid;

  List<ChannelModel> parsePlaylist(String content) {
    return parsePlaylistStatic(content, _uuid);
  }

  static List<ChannelModel> parsePlaylistStatic(String content, Uuid uuid) {
    try {
      final lines = content.split('\n');
      developer.log('Парсинг плейлиста: ${lines.length} строк', name: 'M3uParser');
      final channels = <ChannelModel>[];
      String? currentExtinf;
      Map<String, String>? currentAttributes;

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();

        if (line.isEmpty) {
          continue;
        }

        if (line.startsWith('#EXTM3U')) {
          continue;
        }

        if (line.startsWith('#EXTINF:')) {
          currentExtinf = line;
          currentAttributes = _parseExtinfLineStatic(line);
        } else if (line.startsWith('#EXTGRP:')) {
          final groupMatch = RegExp(r'#EXTGRP:(.+)').firstMatch(line);
          if (groupMatch != null && currentAttributes != null) {
            currentAttributes['group-title'] = groupMatch.group(1)?.trim() ?? '';
          }
        } else if (line.startsWith('#')) {
          continue;
        } else if (currentExtinf != null && line.isNotEmpty && !line.startsWith('#')) {
          final channel = _createChannelFromExtinfStatic(
            currentExtinf,
            line,
            currentAttributes,
            uuid,
          );
          if (channel != null) {
            channels.add(channel);
            developer.log('Добавлен канал: ${channel.name} (${channel.url})', name: 'M3uParser');
          } else {
            developer.log('Канал не добавлен (неверный URL): $line', name: 'M3uParser');
          }
          currentExtinf = null;
          currentAttributes = null;
        }
      }

      developer.log('Парсинг завершен: найдено ${channels.length} каналов', name: 'M3uParser');
      return channels;
    } catch (e) {
      throw ParseFailure(message: 'Ошибка парсинга M3U: $e');
    }
  }

  static Map<String, String> _parseExtinfLineStatic(String extinfLine) {
    final attributes = <String, String>{};
    final match = RegExp(
      r'#EXTINF:(-?\d+)\s*(.*)',
    ).firstMatch(extinfLine);

    if (match != null) {
      final duration = match.group(1);
      final rest = match.group(2) ?? '';

      if (duration != null) {
        attributes['duration'] = duration;
      }

      final attributePattern = RegExp(r'(\w+(?:-\w+)*)="([^"]*)"');
      final attributeMatches = attributePattern.allMatches(rest);

      for (final match in attributeMatches) {
        final key = match.group(1);
        final value = match.group(2);
        if (key != null && value != null) {
          attributes[key] = value;
        }
      }

      final nameMatch = RegExp(r',\s*(.+)$').firstMatch(rest);
      if (nameMatch != null) {
        attributes['name'] = nameMatch.group(1) ?? '';
      }
    }

    return attributes;
  }

  static ChannelModel? _createChannelFromExtinfStatic(
    String extinfLine,
    String url,
    Map<String, String>? attributes,
    Uuid uuid,
  ) {
    try {
      final trimmedUrl = url.trim();
      if (trimmedUrl.isEmpty) {
        return null;
      }
      final urlPattern = RegExp(r'^https?://');
      if (!urlPattern.hasMatch(trimmedUrl)) {
        return null;
      }

      final attrs = attributes ?? <String, String>{};
      final channelName = attrs['name'] ?? attrs['tvg-name'] ?? 'Неизвестный канал';
      final logoUrl = attrs['tvg-logo'];
      final groupTitle = attrs['group-title'];
      final tvgId = attrs['tvg-id'];

      final channelAttributes = <String, String>{};
      for (final entry in attrs.entries) {
        if (!['name', 'duration'].contains(entry.key)) {
          channelAttributes[entry.key] = entry.value;
        }
      }

      return ChannelModel(
        id: uuid.v4(),
        name: channelName,
        url: url.trim(),
        logoUrl: logoUrl,
        groupTitle: groupTitle,
        tvgId: tvgId,
        attributes: channelAttributes.isEmpty ? null : channelAttributes,
      );
    } catch (e) {
      return null;
    }
  }
}

