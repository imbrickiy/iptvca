
import 'package:equatable/equatable.dart';

class Channel extends Equatable {
  const Channel({
    required this.id,
    required this.name,
    required this.url,
    this.logoUrl,
    this.groupTitle,
    this.tvgId,
    this.attributes,
    this.isFavorite = false,
    this.lastWatched,
  });

  final String id;
  final String name;
  final String url;
  final String? logoUrl;
  final String? groupTitle;
  final String? tvgId;
  final Map<String, String>? attributes;
  final bool isFavorite;
  final DateTime? lastWatched;

  Channel copyWith({
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
    return Channel(
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

  @override
  List<Object?> get props => [
        id,
        name,
        url,
        logoUrl,
        groupTitle,
        tvgId,
        attributes,
        isFavorite,
        lastWatched,
      ];
}

