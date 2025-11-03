
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

class ChannelsLoaded extends ChannelState {
  const ChannelsLoaded({
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

  List<Channel> get filteredChannels {
    var filtered = channels;

    if (showFavoritesOnly) {
      filtered = filtered.where((channel) => channel.isFavorite).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (channel) => channel.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    if (filterGroup != null && filterGroup!.isNotEmpty) {
      filtered = filtered
          .where((channel) => channel.groupTitle == filterGroup)
          .toList();
    }

    return filtered;
  }

  List<String> get availableGroups {
    return channels
        .map((channel) => channel.groupTitle)
        .where((group) => group != null)
        .toSet()
        .toList()
        .cast<String>()
        ..sort();
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

