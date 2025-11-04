
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iptvca/core/storage/storage_interface.dart';
import 'package:iptvca/data/models/channel_model.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:iptvca/domain/usecases/get_all_channels.dart';
import 'package:iptvca/presentation/bloc/channel/channel_event.dart';
import 'package:iptvca/presentation/bloc/channel/channel_state.dart';

class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  ChannelBloc(this._getAllChannels, this._storage) : super(const ChannelInitial()) {
    on<LoadChannelsEvent>(_onLoadChannels);
    on<SelectChannelEvent>(_onSelectChannel);
    on<SearchChannelsEvent>(_onSearchChannels);
    on<FilterChannelsByGroupEvent>(_onFilterChannelsByGroup);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<FilterFavoritesEvent>(_onFilterFavorites);
  }

  final GetAllChannels _getAllChannels;
  final StorageInterface _storage;
  static const String _favoritesKey = 'favorite_channels';
  static const String _lastChannelKey = 'last_channel_id';
  List<Channel> _allChannels = [];
  Map<String, Channel> _channelsMap = {};
  Set<String> _favoriteChannelIds = {};

  Future<void> _onLoadChannels(
    LoadChannelsEvent event,
    Emitter<ChannelState> emit,
  ) async {
    emit(const ChannelLoading());
    await _loadFavorites();
    if (_allChannels.isEmpty) {
      final result = await _getAllChannels();
      result.fold(
        (failure) => emit(ChannelError(failure.message ?? 'Ошибка загрузки каналов')),
        (channels) {
          _allChannels = _applyFavoritesToChannels(channels);
          _updateChannelsMap();
          emit(ChannelsLoaded(
            channels: _allChannels,
            showFavoritesOnly: event.showFavoritesOnly,
          ));
        },
      );
    } else {
      _allChannels = _applyFavoritesToChannels(_allChannels);
      _updateChannelsMap();
      emit(ChannelsLoaded(
        channels: _allChannels,
        showFavoritesOnly: event.showFavoritesOnly,
      ));
    }
  }

  void _updateChannelsMap() {
    _channelsMap = {
      for (final channel in _allChannels) channel.id: channel,
    };
  }

  Future<void> _loadFavorites() async {
    try {
      final favoritesJson = await _storage.getString(_favoritesKey);
      if (favoritesJson != null) {
        final favoritesList = await compute(_decodeFavoritesJsonCompute, favoritesJson);
        _favoriteChannelIds = favoritesList.toSet();
        developer.log('Загружено избранных каналов: ${_favoriteChannelIds.length}',
            name: 'ChannelBloc');
      }
    } catch (e) {
      developer.log('Ошибка загрузки избранных каналов: $e', name: 'ChannelBloc');
      _favoriteChannelIds = {};
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final favoritesList = _favoriteChannelIds.toList();
      final favoritesJson = await compute(_encodeFavoritesJsonCompute, favoritesList);
      await _storage.setString(_favoritesKey, favoritesJson);
      developer.log('Сохранено избранных каналов: ${_favoriteChannelIds.length}',
          name: 'ChannelBloc');
    } catch (e) {
      developer.log('Ошибка сохранения избранных каналов: $e', name: 'ChannelBloc');
    }
  }

  static String _encodeFavoritesJsonCompute(List<String> favoritesList) {
    try {
      return json.encode(favoritesList);
    } catch (e) {
      throw Exception('Ошибка кодирования JSON избранных: $e');
    }
  }

  static List<String> _decodeFavoritesJsonCompute(String jsonString) {
    try {
      final List<dynamic> favoritesList = json.decode(jsonString);
      return favoritesList.map((id) => id.toString()).toList();
    } catch (e) {
      throw Exception('Ошибка декодирования JSON избранных: $e');
    }
  }

  List<Channel> _applyFavoritesToChannels(List<Channel> channels) {
    return channels.map((channel) {
      if (_favoriteChannelIds.contains(channel.id)) {
        return ChannelModel.fromEntity(channel).copyWithModel(isFavorite: true);
      }
      return channel;
    }).toList();
  }

  void setChannels(List<Channel> channels) {
    _allChannels = channels;
    if (state is ChannelsLoaded) {
      final currentState = state as ChannelsLoaded;
      add(LoadChannelsEvent(showFavoritesOnly: currentState.showFavoritesOnly));
    }
  }

  Future<void> _onSelectChannel(
    SelectChannelEvent event,
    Emitter<ChannelState> emit,
  ) async {
    if (state is ChannelsLoaded) {
      final currentState = state as ChannelsLoaded;
      emit(
        currentState.copyWith(selectedChannel: event.channel),
      );
      await _saveLastChannel(event.channel);
    }
  }

  Future<void> _onSearchChannels(
    SearchChannelsEvent event,
    Emitter<ChannelState> emit,
  ) async {
    if (state is ChannelsLoaded) {
      final currentState = state as ChannelsLoaded;
      emit(
        currentState.copyWith(searchQuery: event.query),
      );
    }
  }

  Future<void> _onFilterChannelsByGroup(
    FilterChannelsByGroupEvent event,
    Emitter<ChannelState> emit,
  ) async {
    if (state is ChannelsLoaded) {
      final currentState = state as ChannelsLoaded;
      final filterGroup = event.groupTitle.isEmpty ? null : event.groupTitle;
      emit(
        currentState.copyWith(filterGroup: filterGroup),
      );
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<ChannelState> emit,
  ) async {
    if (state is ChannelsLoaded) {
      final currentState = state as ChannelsLoaded;
      final isFavorite = !event.channel.isFavorite;
      if (isFavorite) {
        _favoriteChannelIds.add(event.channel.id);
      } else {
        _favoriteChannelIds.remove(event.channel.id);
      }
      final updatedChannels = currentState.channels.map((channel) {
        if (channel.id == event.channel.id) {
          return ChannelModel.fromEntity(channel).copyWithModel(
            isFavorite: isFavorite,
          );
        }
        return channel;
      }).toList();

      final updatedChannel = _channelsMap[event.channel.id];
      if (updatedChannel != null) {
        final newChannel = ChannelModel.fromEntity(updatedChannel).copyWithModel(
          isFavorite: isFavorite,
        );
        _allChannels = _allChannels.map((channel) {
          return channel.id == event.channel.id ? newChannel : channel;
        }).toList();
        _channelsMap[event.channel.id] = newChannel;
      }

      emit(
        currentState.copyWith(channels: updatedChannels),
      );
      _saveFavorites();
    }
  }

  Future<void> _onFilterFavorites(
    FilterFavoritesEvent event,
    Emitter<ChannelState> emit,
  ) async {
    if (state is ChannelsLoaded) {
      final currentState = state as ChannelsLoaded;
      emit(
        currentState.copyWith(showFavoritesOnly: event.showFavoritesOnly),
      );
    }
  }

  Future<void> _saveLastChannel(Channel channel) async {
    try {
      await _storage.setString(_lastChannelKey, channel.id);
      developer.log('Сохранен последний канал: ${channel.name}', name: 'ChannelBloc');
    } catch (e) {
      developer.log('Ошибка сохранения последнего канала: $e', name: 'ChannelBloc');
    }
  }

  Future<String?> getLastChannelId() async {
    try {
      return await _storage.getString(_lastChannelKey);
    } catch (e) {
      developer.log('Ошибка загрузки последнего канала: $e', name: 'ChannelBloc');
      return null;
    }
  }

  Future<Channel?> getLastChannel() async {
    final lastChannelId = await getLastChannelId();
    if (lastChannelId == null || _channelsMap.isEmpty) {
      return null;
    }
    try {
      return _channelsMap[lastChannelId];
    } catch (e) {
      developer.log('Последний канал не найден: $e', name: 'ChannelBloc');
      return null;
    }
  }
}

