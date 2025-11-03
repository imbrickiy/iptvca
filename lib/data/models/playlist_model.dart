
import 'package:iptvca/domain/entities/playlist.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:iptvca/data/models/channel_model.dart';

class PlaylistModel extends Playlist {
  const PlaylistModel({
    required super.id,
    required super.name,
    required super.source,
    required super.lastUpdated,
    required super.channels,
    super.isActive,
  });

  factory PlaylistModel.fromEntity(Playlist playlist) {
    return PlaylistModel(
      id: playlist.id,
      name: playlist.name,
      source: playlist.source,
      lastUpdated: playlist.lastUpdated,
      channels: playlist.channels
          .map((channel) => ChannelModel.fromEntity(channel))
          .toList(),
      isActive: playlist.isActive,
    );
  }

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      source: json['source'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      channels: (json['channels'] as List<dynamic>)
          .map((channelJson) => ChannelModel.fromJson(
                channelJson as Map<String, dynamic>,
              ))
          .toList(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'source': source,
      'last_updated': lastUpdated.toIso8601String(),
      'channels': channels
          .map((channel) => (channel as ChannelModel).toJson())
          .toList(),
      'is_active': isActive,
    };
  }

  PlaylistModel copyWithModel({
    String? id,
    String? name,
    String? source,
    DateTime? lastUpdated,
    List<Channel>? channels,
    bool? isActive,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      channels: channels ?? this.channels,
      isActive: isActive ?? this.isActive,
    );
  }
}

