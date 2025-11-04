
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:iptvca/core/storage/file_storage.dart';
import 'package:iptvca/core/storage/shared_preferences_storage.dart';
import 'package:iptvca/core/storage/storage_interface.dart';
import 'package:iptvca/core/services/network_cache_service.dart';
import 'package:iptvca/data/datasources/local/playlist_local_datasource.dart';
import 'package:iptvca/data/datasources/remote/m3u_parser.dart';
import 'package:iptvca/data/datasources/remote/playlist_remote_datasource.dart';
import 'package:iptvca/data/repositories/playlist_repository_impl.dart';
import 'package:iptvca/domain/usecases/delete_playlist.dart';
import 'package:iptvca/domain/usecases/get_all_channels.dart';
import 'package:iptvca/domain/usecases/get_playlists.dart';
import 'package:iptvca/domain/usecases/load_playlist_from_file.dart';
import 'package:iptvca/domain/usecases/load_playlist_from_url.dart';
import 'package:iptvca/domain/usecases/get_settings.dart';
import 'package:iptvca/domain/usecases/save_settings.dart';
import 'package:iptvca/domain/usecases/save_playlist.dart';
import 'package:iptvca/data/repositories/settings_repository_impl.dart';
import 'package:iptvca/presentation/bloc/channel/channel_bloc.dart';
import 'package:iptvca/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:iptvca/presentation/bloc/settings/settings_bloc.dart';

class InjectionContainer {
  static final InjectionContainer instance = InjectionContainer._();
  InjectionContainer._();

  StorageInterface? _storage;
  http.Client? _httpClient;
  NetworkCacheService? _cacheService;
  final Uuid _uuid = const Uuid();

  StorageInterface? get storage => _storage;
  NetworkCacheService? get cacheService => _cacheService;

  Future<void> init() async {
    try {
      _httpClient ??= http.Client();
      try {
        final prefs = await SharedPreferences.getInstance();
        _storage = SharedPreferencesStorage(prefs);
        developer.log('Используется SharedPreferences для хранения');
      } catch (e) {
        if (e.toString().contains('UnimplementedError') ||
            e.toString().contains('init() has not been implemented')) {
          _storage = await FileStorage.create();
          developer.log('Используется файловое хранилище для Windows');
        } else {
          rethrow;
        }
      }
      _cacheService = NetworkCacheService(_storage);
      developer.log('NetworkCacheService инициализирован');
    } catch (e) {
      throw StateError('Ошибка инициализации InjectionContainer: $e');
    }
  }

  PlaylistBloc createPlaylistBloc() {
    if (_storage == null || _httpClient == null) {
      throw StateError('InjectionContainer not initialized. Call init() first.');
    }
    final parser = M3uParser(_uuid);
    final remoteDataSource = PlaylistRemoteDataSourceImpl(
      _httpClient!,
      parser,
      _cacheService,
    );
    final localDataSource = PlaylistLocalDataSourceImpl(_storage!);
    final repository = PlaylistRepositoryImpl(remoteDataSource, localDataSource);

    return PlaylistBloc(
      GetPlaylists(repository),
      LoadPlaylistFromUrl(repository),
      LoadPlaylistFromFile(repository),
      SavePlaylist(repository),
      DeletePlaylist(repository),
    );
  }

  ChannelBloc createChannelBloc() {
    if (_storage == null || _httpClient == null) {
      throw StateError('InjectionContainer not initialized. Call init() first.');
    }
    final parser = M3uParser(_uuid);
    final remoteDataSource = PlaylistRemoteDataSourceImpl(
      _httpClient!,
      parser,
      _cacheService,
    );
    final localDataSource = PlaylistLocalDataSourceImpl(_storage!);
    final repository = PlaylistRepositoryImpl(remoteDataSource, localDataSource);

    return ChannelBloc(GetAllChannels(repository), _storage!);
  }

  SettingsBloc createSettingsBloc() {
    if (_storage == null) {
      throw StateError('InjectionContainer not initialized. Call init() first.');
    }
    final repository = SettingsRepositoryImpl(_storage!);
    return SettingsBloc(GetSettings(repository), SaveSettings(repository));
  }
}

