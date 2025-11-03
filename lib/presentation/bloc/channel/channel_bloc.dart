
import 'dart:convert';
import 'dart:developer' as developer;
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
  List<Channel> _allChannels = [];
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
          emit(ChannelsLoaded(
            channels: _allChannels,
            showFavoritesOnly: event.showFavoritesOnly,
          ));
        },
      );
    } else {
      _allChannels = _applyFavoritesToChannels(_allChannels);
      emit(ChannelsLoaded(
        channels: _allChannels,
        showFavoritesOnly: event.showFavoritesOnly,
      ));
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favoritesJson = await _storage.getString(_favoritesKey);
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = json.decode(favoritesJson);
        _favoriteChannelIds = favoritesList.map((id) => id.toString()).toSet();
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
      final favoritesJson = json.encode(favoritesList);
      await _storage.setString(_favoritesKey, favoritesJson);
      developer.log('Сохранено избранных каналов: ${_favoriteChannelIds.length}',
          name: 'ChannelBloc');
    } catch (e) {
      developer.log('Ошибка сохранения избранных каналов: $e', name: 'ChannelBloc');
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

      final index = _allChannels.indexWhere(
        (channel) => channel.id == event.channel.id,
      );
      if (index >= 0) {
        _allChannels[index] = updatedChannels.firstWhere(
          (channel) => channel.id == event.channel.id,
        );
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
}

