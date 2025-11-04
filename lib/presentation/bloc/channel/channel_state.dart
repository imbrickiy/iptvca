
import 'package:equatable/equatable.dart';
import 'package:iptvca/domain/entities/channel.dart';

abstract class ChannelState extends Equatable {
  const ChannelState();

  @override
  List<Object?> get props => [];
}

class ChannelInitial extends ChannelState {
  const ChannelInitial();
}

class ChannelLoading extends ChannelState {
  const ChannelLoading();
}

// ignore: must_be_immutable
class ChannelsLoaded extends ChannelState {
  ChannelsLoaded({
    required this.channels,
    this.selectedChannel,
    this.searchQuery = '',
    this.filterGroup,
    this.showFavoritesOnly = false,
  });

  final List<Channel> channels;
  final Channel? selectedChannel;
  final String searchQuery;
  final String? filterGroup;
  final bool showFavoritesOnly;
  List<Channel>? _cachedFilteredChannels;
  String? _lastSearchQuery;
  String? _lastFilterGroup;
  bool? _lastShowFavoritesOnly;
  Map<String, Channel>? _channelsMap;

  List<Channel> get filteredChannels {
    if (_cachedFilteredChannels != null &&
        _lastSearchQuery == searchQuery &&
        _lastFilterGroup == filterGroup &&
        _lastShowFavoritesOnly == showFavoritesOnly) {
      return _cachedFilteredChannels!;
    }
    var filtered = channels;
    if (showFavoritesOnly) {
      filtered = filtered.where((channel) => channel.isFavorite).toList();
    }
    if (searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (channel) => channel.name.toLowerCase().contains(queryLower),
          )
          .toList();
    }
    if (filterGroup != null && filterGroup!.isNotEmpty) {
      filtered = filtered
          .where((channel) => channel.groupTitle == filterGroup)
          .toList();
    }
    _cachedFilteredChannels = filtered;
    _lastSearchQuery = searchQuery;
    _lastFilterGroup = filterGroup;
    _lastShowFavoritesOnly = showFavoritesOnly;
    _channelsMap = null;
    _cachedAvailableGroups = null;
    return filtered;
  }

  Map<String, Channel> get channelsMap {
    if (_channelsMap != null) {
      return _channelsMap!;
    }
    _channelsMap = {
      for (final channel in channels) channel.id: channel,
    };
    return _channelsMap!;
  }

  List<String>? _cachedAvailableGroups;

  List<String> get availableGroups {
    if (_cachedAvailableGroups != null) {
      return _cachedAvailableGroups!;
    }
    final groups = channels
        .map((channel) => channel.groupTitle)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    _cachedAvailableGroups = groups;
    return groups;
  }

  @override
  List<Object?> get props => [
        channels,
        selectedChannel,
        searchQuery,
        filterGroup,
        showFavoritesOnly,
      ];

  ChannelsLoaded copyWith({
    List<Channel>? channels,
    Channel? selectedChannel,
    String? searchQuery,
    String? filterGroup,
    bool? showFavoritesOnly,
  }) {
    return ChannelsLoaded(
      channels: channels ?? this.channels,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      searchQuery: searchQuery ?? this.searchQuery,
      filterGroup: filterGroup ?? this.filterGroup,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
    );
  }
}

class ChannelError extends ChannelState {
  const ChannelError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}


