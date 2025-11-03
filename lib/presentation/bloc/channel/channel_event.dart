
import 'package:equatable/equatable.dart';
import 'package:iptvca/domain/entities/channel.dart';

abstract class ChannelEvent extends Equatable {
  const ChannelEvent();

  @override
  List<Object?> get props => [];
}

class LoadChannelsEvent extends ChannelEvent {
  const LoadChannelsEvent({this.showFavoritesOnly = false});
  final bool showFavoritesOnly;
  @override
  List<Object?> get props => [showFavoritesOnly];
}

class SelectChannelEvent extends ChannelEvent {
  const SelectChannelEvent(this.channel);
  final Channel channel;

  @override
  List<Object?> get props => [channel];
}

class SearchChannelsEvent extends ChannelEvent {
  const SearchChannelsEvent(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class FilterChannelsByGroupEvent extends ChannelEvent {
  const FilterChannelsByGroupEvent(this.groupTitle);
  final String groupTitle;

  @override
  List<Object?> get props => [groupTitle];
}

class ToggleFavoriteEvent extends ChannelEvent {
  const ToggleFavoriteEvent(this.channel);
  final Channel channel;

  @override
  List<Object?> get props => [channel];
}

class FilterFavoritesEvent extends ChannelEvent {
  const FilterFavoritesEvent(this.showFavoritesOnly);
  final bool showFavoritesOnly;

  @override
  List<Object?> get props => [showFavoritesOnly];
}

