
import 'package:equatable/equatable.dart';
import 'package:iptvca/domain/entities/channel.dart';

class Playlist extends Equatable {
  const Playlist({
    required this.id,
    required this.name,
    required this.source,
    required this.lastUpdated,
    required this.channels,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String source;
  final DateTime lastUpdated;
  final List<Channel> channels;
  final bool isActive;

  Playlist copyWith({
    String? id,
    String? name,
    String? source,
    DateTime? lastUpdated,
    List<Channel>? channels,
    bool? isActive,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      channels: channels ?? this.channels,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        source,
        lastUpdated,
        channels,
        isActive,
      ];
}

