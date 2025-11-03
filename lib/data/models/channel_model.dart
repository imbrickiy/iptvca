
import 'package:iptvca/domain/entities/channel.dart';

class ChannelModel extends Channel {
  const ChannelModel({
    required super.id,
    required super.name,
    required super.url,
    super.logoUrl,
    super.groupTitle,
    super.tvgId,
    super.attributes,
    super.isFavorite,
    super.lastWatched,
  });

  factory ChannelModel.fromEntity(Channel channel) {
    return ChannelModel(
      id: channel.id,
      name: channel.name,
      url: channel.url,
      logoUrl: channel.logoUrl,
      groupTitle: channel.groupTitle,
      tvgId: channel.tvgId,
      attributes: channel.attributes,
      isFavorite: channel.isFavorite,
      lastWatched: channel.lastWatched,
    );
  }

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      logoUrl: json['logo_url'] as String?,
      groupTitle: json['group_title'] as String?,
      tvgId: json['tvg_id'] as String?,
      attributes: json['attributes'] != null
          ? Map<String, String>.from(json['attributes'] as Map)
          : null,
      isFavorite: json['is_favorite'] as bool? ?? false,
      lastWatched: json['last_watched'] != null
          ? DateTime.parse(json['last_watched'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'logo_url': logoUrl,
      'group_title': groupTitle,
      'tvg_id': tvgId,
      'attributes': attributes,
      'is_favorite': isFavorite,
      'last_watched': lastWatched?.toIso8601String(),
    };
  }

  ChannelModel copyWithModel({
    String? id,
    String? name,
    String? url,
    String? logoUrl,
    String? groupTitle,
    String? tvgId,
    Map<String, String>? attributes,
    bool? isFavorite,
    DateTime? lastWatched,
  }) {
    return ChannelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      logoUrl: logoUrl ?? this.logoUrl,
      groupTitle: groupTitle ?? this.groupTitle,
      tvgId: tvgId ?? this.tvgId,
      attributes: attributes ?? this.attributes,
      isFavorite: isFavorite ?? this.isFavorite,
      lastWatched: lastWatched ?? this.lastWatched,
    );
  }
}

