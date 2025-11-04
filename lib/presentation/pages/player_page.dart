import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iptvca/core/constants/app_constants.dart';
import 'package:iptvca/core/di/injection_container.dart';
import 'package:iptvca/core/theme/app_colors.dart';
import 'package:iptvca/presentation/bloc/channel/channel_bloc.dart';
import 'package:iptvca/presentation/bloc/channel/channel_event.dart';
import 'package:iptvca/presentation/bloc/channel/channel_state.dart';
import 'package:iptvca/presentation/bloc/settings/settings_bloc.dart';
import 'package:iptvca/presentation/bloc/settings/settings_state.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:iptvca/domain/entities/settings.dart' as entities;
import 'package:iptvca/presentation/widgets/epg_programs_dialog.dart';
import 'package:window_manager/window_manager.dart';
import 'package:iptvca/core/utils/debounce.dart';

class _ChannelSelectorDrawer extends StatefulWidget {
  const _ChannelSelectorDrawer({required this.onChannelSelected});
  final void Function(Channel) onChannelSelected;

  @override
  State<_ChannelSelectorDrawer> createState() => _ChannelSelectorDrawerState();
}

class _ChannelSelectorDrawerState extends State<_ChannelSelectorDrawer> {
  late final Debounce _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchDebounce = Debounce(AppConstants.searchDebounceDuration);
  }

  @override
  void dispose() {
    _searchDebounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.shadow.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        height: 80,
                        width: 80,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.tv,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Выберите канал',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Поиск каналов',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  onChanged: (value) {
                    _searchDebounce(() {
                      try {
                        context.read<ChannelBloc>().add(SearchChannelsEvent(value));
                      } catch (e) {
                        developer.log(
                          'ChannelBloc не доступен для поиска: $e',
                          name: 'PlayerPage',
                        );
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          BlocBuilder<ChannelBloc, ChannelState>(
            builder: (context, state) {
              if (state is ChannelsLoaded) {
                return ListTile(
                  leading: Icon(
                    state.showFavoritesOnly
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: state.showFavoritesOnly ? AppColors.favorite : null,
                  ),
                  title: const Text('Только избранные'),
                  trailing: Switch(
                    value: state.showFavoritesOnly,
                    onChanged: (value) {
                      try {
                        context.read<ChannelBloc>().add(FilterFavoritesEvent(value));
                      } catch (e) {
                        developer.log(
                          'ChannelBloc не доступен для фильтра: $e',
                          name: 'PlayerPage',
                        );
                      }
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Главная'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/');
            },
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<ChannelBloc, ChannelState>(
              builder: (context, state) {
                if (state is ChannelLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChannelError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.favorite,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (state is ChannelsLoaded) {
                  if (state.filteredChannels.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.tv_off,
                            size: 64,
                            color: AppColors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Каналы не найдены',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    );
                  }
                  return _ChannelsGroupedList(
                    channels: state.filteredChannels,
                    onChannelSelected: widget.onChannelSelected,
                  );
                }
                return const Center(child: Text('Загрузите плейлист'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelsGroupedList extends StatefulWidget {
  const _ChannelsGroupedList({
    required this.channels,
    required this.onChannelSelected,
  });
  final List<Channel> channels;
  final void Function(Channel) onChannelSelected;

  @override
  State<_ChannelsGroupedList> createState() => _ChannelsGroupedListState();
}

class _ChannelsGroupedListState extends State<_ChannelsGroupedList> {
  Map<String, List<Channel>>? _cachedGroupedChannels;
  List<String>? _cachedCategories;
  List<Channel>? _lastChannels;

  Map<String, List<Channel>> _groupChannelsByCategory(List<Channel> channels) {
    final Map<String, List<Channel>> grouped = {};
    for (final channel in channels) {
      final category = channel.groupTitle ?? 'Без категории';
      grouped.putIfAbsent(category, () => []).add(channel);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedGroupedChannels == null || 
        _lastChannels != widget.channels ||
        _lastChannels?.length != widget.channels.length) {
      _cachedGroupedChannels = _groupChannelsByCategory(widget.channels);
      _cachedCategories = _cachedGroupedChannels!.keys.toList()..sort();
      _lastChannels = widget.channels;
    }
    final groupedChannels = _cachedGroupedChannels!;
    final categories = _cachedCategories!;
    return ListView.builder(
      cacheExtent: AppConstants.playerListViewCacheExtent.toDouble(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryChannels = groupedChannels[category]!;
        return ExpansionTile(
          key: ValueKey(category),
          initiallyExpanded: false,
          leading: const Icon(Icons.folder_outlined),
          title: Text(category),
          subtitle: Text('${categoryChannels.length} каналов'),
          children: categoryChannels.map((channel) {
            return _ChannelDrawerItem(
              key: ValueKey(channel.id),
              channel: channel,
              onChannelSelected: widget.onChannelSelected,
            );
          }).toList(),
        );
      },
    );
  }
}

class _ChannelDrawerItem extends StatefulWidget {
  const _ChannelDrawerItem({
    super.key,
    required this.channel,
    required this.onChannelSelected,
  });
  final Channel channel;
  final void Function(Channel) onChannelSelected;

  @override
  State<_ChannelDrawerItem> createState() => _ChannelDrawerItemState();
}

class _ChannelDrawerItemState extends State<_ChannelDrawerItem> {
  bool? _localIsFavorite;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelBloc, ChannelState>(
      buildWhen: (previous, current) {
        if (previous is ChannelsLoaded && current is ChannelsLoaded) {
          final prevChannelIndex = previous.channels.indexWhere(
            (c) => c.id == widget.channel.id,
          );
          final currChannelIndex = current.channels.indexWhere(
            (c) => c.id == widget.channel.id,
          );
          if (prevChannelIndex == AppConstants.invalidIndex && currChannelIndex == AppConstants.invalidIndex) {
            return false;
          }
          if (prevChannelIndex != AppConstants.invalidIndex && currChannelIndex != AppConstants.invalidIndex) {
            final prevChannel = previous.channels[prevChannelIndex];
            final currChannel = current.channels[currChannelIndex];
            if (prevChannel.isFavorite != currChannel.isFavorite) {
              _localIsFavorite = null;
              return true;
            }
          }
        }
        return previous != current;
      },
      builder: (context, blocState) {
        Channel currentChannel = widget.channel;
        bool isFavorite = widget.channel.isFavorite;
        if (blocState is ChannelsLoaded) {
          final channel = blocState.channelsMap[widget.channel.id];
          if (channel != null) {
            currentChannel = channel;
            isFavorite = channel.isFavorite;
          }
        }
        if (_localIsFavorite != null) {
          isFavorite = _localIsFavorite!;
        }
        return ListTile(
          leading: currentChannel.logoUrl != null
              ? CachedNetworkImage(
                  imageUrl: currentChannel.logoUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  memCacheWidth: 96,
                  memCacheHeight: 96,
                  placeholder: (context, url) => const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.tv),
                )
              : const Icon(Icons.tv),
          title: Text(currentChannel.name),
          subtitle: currentChannel.groupTitle != null
              ? Text(currentChannel.groupTitle!)
              : null,
            trailing: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppColors.favorite : null,
              ),
              onPressed: () {
                final newFavoriteStatus = !isFavorite;
                setState(() {
                  _localIsFavorite = newFavoriteStatus;
                });
                try {
                  context.read<ChannelBloc>().add(ToggleFavoriteEvent(currentChannel));
                } catch (e) {
                  developer.log(
                    'ChannelBloc не доступен для избранного: $e',
                    name: 'PlayerPage',
                  );
                }
              },
            ),
          onTap: () {
            try {
              context.read<ChannelBloc>().add(SelectChannelEvent(currentChannel));
            } catch (e) {
              developer.log(
                'ChannelBloc не доступен для выбора канала: $e',
                name: 'PlayerPage',
              );
            }
            Navigator.of(context).pop();
            widget.onChannelSelected(currentChannel);
          },
        );
      },
    );
  }
}

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerAppBar extends StatefulWidget implements PreferredSizeWidget {
  const _PlayerAppBar({
    required this.currentChannel,
    required this.localIsFavorite,
    required this.onLocalFavoriteChanged,
    required this.showAlwaysOnTopControl,
    required this.isAlwaysOnTop,
    required this.onToggleAlwaysOnTop,
    required this.onShowEpg,
  });

  final Channel currentChannel;
  final bool? localIsFavorite;
  final void Function(bool) onLocalFavoriteChanged;
  final bool showAlwaysOnTopControl;
  final bool isAlwaysOnTop;
  final VoidCallback onToggleAlwaysOnTop;
  final VoidCallback onShowEpg;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<_PlayerAppBar> createState() => _PlayerAppBarState();
}

class _PlayerAppBarState extends State<_PlayerAppBar> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelBloc, ChannelState>(
      buildWhen: (previous, current) {
        if (previous is ChannelsLoaded && current is ChannelsLoaded) {
          final prevChannelIndex = previous.channels.indexWhere(
            (c) => c.id == widget.currentChannel.id,
          );
          final currChannelIndex = current.channels.indexWhere(
            (c) => c.id == widget.currentChannel.id,
          );
          if (prevChannelIndex != AppConstants.invalidIndex && currChannelIndex != AppConstants.invalidIndex) {
            final prevChannel = previous.channels[prevChannelIndex];
            final currChannel = current.channels[currChannelIndex];
            return prevChannel.isFavorite != currChannel.isFavorite;
          }
        }
        return previous != current;
      },
      builder: (context, state) {
        Channel channel = widget.currentChannel;
        bool favorite = widget.currentChannel.isFavorite;
        if (state is ChannelsLoaded) {
          final channelIndex = state.channels.indexWhere(
            (c) => c.id == widget.currentChannel.id,
          );
          if (channelIndex != AppConstants.invalidIndex) {
            channel = state.channels[channelIndex];
            favorite = channel.isFavorite;
          }
        }
        if (widget.localIsFavorite != null) {
          favorite = widget.localIsFavorite!;
        }
        return AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(channel.name, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  widget.onLocalFavoriteChanged(!favorite);
                  try {
                    context.read<ChannelBloc>().add(ToggleFavoriteEvent(channel));
                  } catch (e) {
                    developer.log(
                      'ChannelBloc не доступен для избранного: $e',
                      name: 'PlayerPage',
                    );
                  }
                },
                child: Icon(
                  favorite ? Icons.favorite : Icons.favorite_border,
                  color: favorite ? AppColors.favorite : null,
                  size: 20,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Телепрограмма',
              icon: const Icon(Icons.schedule),
              onPressed: widget.onShowEpg,
            ),
            if (widget.showAlwaysOnTopControl)
              IconButton(
                tooltip: widget.isAlwaysOnTop
                    ? 'Отключить закрепление поверх всех окон'
                    : 'Развернуть поверх всех окон',
                icon: Icon(
                  widget.isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
                ),
                onPressed: widget.onToggleAlwaysOnTop,
              ),
          ],
        );
      },
    );
  }
}

class _PlayerPageState extends State<PlayerPage> {
  Player? _player;
  VideoController? _videoController;
  String? _videoUrl;
  Channel? _currentChannel;
  String? _errorMessage;
  bool _isInitializing = false;
  bool _errorListenerSet = false;
  bool? _localIsFavorite;
  late final bool _supportsWindowControls;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isAlwaysOnTop = false;
  bool _hasInitializedFromExtra = false;
  StreamSubscription? _errorSubscription;
  ChannelBloc? _channelBloc;

  int _getBufferSizeForQuality(entities.VideoQuality quality) {
    switch (quality) {
      case entities.VideoQuality.low:
        return AppConstants.bufferSizeLow;
      case entities.VideoQuality.medium:
        return AppConstants.bufferSizeMedium;
      case entities.VideoQuality.high:
        return AppConstants.bufferSizeHigh;
      case entities.VideoQuality.best:
        return AppConstants.bufferSizeBest;
      case entities.VideoQuality.auto:
        return AppConstants.bufferSizeAuto;
    }
  }

  int _getInitialBufferSize(entities.VideoQuality quality) {
    switch (quality) {
      case entities.VideoQuality.low:
        return AppConstants.initialBufferSizeLow;
      case entities.VideoQuality.medium:
        return AppConstants.initialBufferSizeMedium;
      case entities.VideoQuality.high:
        return AppConstants.initialBufferSizeHigh;
      case entities.VideoQuality.best:
        return AppConstants.initialBufferSizeBest;
      case entities.VideoQuality.auto:
        return AppConstants.initialBufferSizeAuto;
    }
  }

  int _getNetworkTimeoutForQuality(entities.VideoQuality quality) {
    switch (quality) {
      case entities.VideoQuality.low:
        return AppConstants.networkTimeoutLow;
      case entities.VideoQuality.medium:
        return AppConstants.networkTimeoutMedium;
      case entities.VideoQuality.high:
        return AppConstants.networkTimeoutHigh;
      case entities.VideoQuality.best:
        return AppConstants.networkTimeoutBest;
      case entities.VideoQuality.auto:
        return AppConstants.networkTimeoutAuto;
    }
  }


  entities.VideoQuality _getVideoQualityFromSettings(BuildContext context) {
    try {
      final settingsState = context.read<SettingsBloc>().state;
      if (settingsState is SettingsLoaded) {
        return settingsState.settings.videoQuality;
      }
    } catch (e) {
      developer.log('Ошибка получения настроек качества: $e', name: 'PlayerPage');
    }
    return entities.VideoQuality.auto;
  }

  @override
  void initState() {
    super.initState();
    _supportsWindowControls =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);
    if (_supportsWindowControls) {
      _syncAlwaysOnTopStatus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasInitializedFromExtra) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasInitializedFromExtra) {
        return;
      }
      final extra = GoRouterState.of(context).extra;
      if (extra != null) {
        Channel? channel;
        String? url;
        if (extra is Channel) {
          channel = extra;
          url = channel.url;
        } else if (extra is String) {
          url = extra;
        }
        if (url != null && url.isNotEmpty && _videoUrl != url) {
          _disposeController();
          _videoUrl = url;
          _currentChannel = channel;
          _errorMessage = null;
          _localIsFavorite = null;
          _hasInitializedFromExtra = true;
          final quality = _getVideoQualityFromSettings(context);
          _initializePlayer(_videoUrl!, quality: quality).then((_) {
            if (mounted && channel != null) {
              _notifyChannelSelected(channel);
            }
          });
        }
      }
    });
  }


  Widget _buildPlayerScaffold() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _currentChannel != null
          ? _PlayerAppBar(
              currentChannel: _currentChannel!,
              localIsFavorite: _localIsFavorite,
              onLocalFavoriteChanged: (newStatus) {
                setState(() {
                  _localIsFavorite = newStatus;
                });
              },
              showAlwaysOnTopControl: _supportsWindowControls,
              isAlwaysOnTop: _isAlwaysOnTop,
              onToggleAlwaysOnTop: _toggleAlwaysOnTop,
              onShowEpg: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            )
          : AppBar(title: const Text('Плеер')),
      drawer: _ChannelSelectorDrawer(
        onChannelSelected: (channel) {
          _switchChannel(channel);
        },
      ),
      endDrawer: _currentChannel != null
          ? EpgProgramsDialog(
              channel: _currentChannel!,
            )
          : null,
      body: Stack(
        children: [
          if (_videoController != null)
            Center(child: Video(controller: _videoController!)),
          if (_isInitializing && _currentChannel != null)
            Container(
              color: AppColors.black87,
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_currentChannel!.logoUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: _currentChannel!.logoUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                memCacheWidth: 200,
                                memCacheHeight: 200,
                                placeholder: (context, url) => Container(
                                  width: 100,
                                  height: 100,
                                  color: AppColors.grey800,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 100,
                                  height: 100,
                                  color: AppColors.grey800,
                                  child: const Icon(
                                    Icons.tv,
                                    size: 40,
                                    color: AppColors.white70,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.tv,
                                size: 40,
                                color: AppColors.white70,
                              ),
                            ),
                          ),
                        Text(
                          _currentChannel!.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Загрузка...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.white70,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else if (_isInitializing)
            Container(
              color: AppColors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  void _disposeController() {
    _errorSubscription?.cancel();
    _errorSubscription = null;
    _player?.dispose();
    _videoController = null;
    _player = null;
    _errorListenerSet = false;
  }

  Future<void> _syncAlwaysOnTopStatus() async {
    try {
      final isOnTop = await windowManager.isAlwaysOnTop();
      if (!mounted) {
        return;
      }
      setState(() {
        _isAlwaysOnTop = isOnTop;
      });
    } catch (e, stackTrace) {
      developer.log(
        'Не удалось получить состояние always-on-top: $e',
        name: 'PlayerPage',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _toggleAlwaysOnTop() async {
    final targetState = !_isAlwaysOnTop;
    try {
      await windowManager.setAlwaysOnTop(targetState);
      if (!mounted) {
        return;
      }
      setState(() {
        _isAlwaysOnTop = targetState;
      });
    } catch (e, stackTrace) {
      developer.log(
        'Не удалось изменить состояние always-on-top: $e',
        name: 'PlayerPage',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _initializePlayer(String url, {entities.VideoQuality? quality}) async {
    if (_isInitializing) return;
    final videoQuality = quality ?? entities.VideoQuality.auto;
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });
    }
    try {
      developer.log('Инициализация плеера для URL: $url', name: 'PlayerPage');
      if (_player == null) {
        final bufferSize = _getBufferSizeForQuality(videoQuality);
        final initialBufferSize = _getInitialBufferSize(videoQuality);
        final networkTimeout = _getNetworkTimeoutForQuality(videoQuality);
        developer.log(
          'Настройка качества: $videoQuality, размер буфера: ${bufferSize ~/ (1024 * 1024)} MB, начальный буфер: ${initialBufferSize ~/ (1024 * 1024)} MB, таймаут сети: ${networkTimeout ~/ 1000}s',
          name: 'PlayerPage',
        );
        _player = Player(
          configuration: PlayerConfiguration(
            title: 'IPTVCA Player',
            bufferSize: bufferSize,
            protocolWhitelist: ['http', 'https', 'rtmp', 'rtsp', 'tcp', 'udp'],
            vo: 'gpu',
            ready: () {
              developer.log('MediaKit Player инициализирован и готов', name: 'PlayerPage');
            },
          ),
        );
        _videoController = VideoController(
          _player!,
          configuration: VideoControllerConfiguration(
            enableHardwareAcceleration: true,
          ),
        );
        if (!_errorListenerSet) {
          _errorSubscription?.cancel();
          _errorSubscription = _player!.stream.error.listen((error) {
            developer.log('Ошибка воспроизведения: $error', name: 'PlayerPage');
            if (mounted) {
              setState(() {
                _errorMessage = error.toString();
              });
            }
          });
          _errorListenerSet = true;
        }
      }
      final media = Media(
        url,
        httpHeaders: AppConstants.httpHeaders,
        extras: {
          'channel': _currentChannel?.name ?? 'Unknown',
          'quality': videoQuality.toString(),
        },
      );
      await _player!.open(media, play: true);
      developer.log('MediaKit Player создан и запущен с оптимизацией', name: 'PlayerPage');
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e, stackTrace) {
      developer.log(
        'Ошибка инициализации плеера: $e',
        name: 'PlayerPage',
        error: e,
        stackTrace: stackTrace,
      );
      _disposeController();
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  ChannelBloc? _getChannelBloc() {
    if (_channelBloc != null) {
      return _channelBloc;
    }
    try {
      _channelBloc = context.read<ChannelBloc>();
      return _channelBloc;
    } catch (e) {
      developer.log(
        'ChannelBloc еще не доступен: $e',
        name: 'PlayerPage',
      );
      return null;
    }
  }

  void _notifyChannelSelected(Channel channel) {
    final bloc = _getChannelBloc();
    if (bloc != null) {
      bloc.add(SelectChannelEvent(channel));
    }
  }

  Future<void> _switchChannel(Channel channel) async {
    final player = _player;
    if (player == null || _videoController == null) {
      setState(() {
        _currentChannel = channel;
        _videoUrl = channel.url;
        _localIsFavorite = null;
        _errorMessage = null;
      });
      _notifyChannelSelected(channel);
      final quality = _getVideoQualityFromSettings(context);
      await _initializePlayer(channel.url, quality: quality);
      return;
    }
    if (_isInitializing) {
      developer.log(
        'Плеер уже инициализируется, ожидание...',
        name: 'PlayerPage',
      );
      return;
    }
    setState(() {
      _videoUrl = channel.url;
      _currentChannel = channel;
      _errorMessage = null;
      _isInitializing = true;
      _localIsFavorite = null;
    });
    try {
      developer.log(
        'Переключение канала на: ${channel.name}',
        name: 'PlayerPage',
      );
      final currentPlayer = _player;
      if (currentPlayer != null) {
        final quality = _getVideoQualityFromSettings(context);
        final media = Media(
          channel.url,
          httpHeaders: {
            'Connection': 'keep-alive',
            'Accept': '*/*',
            'User-Agent': 'IPTVCA/1.0',
            'Accept-Encoding': 'identity',
            'Accept-Language': '*',
          },
          extras: {
            'channel': channel.name,
            'quality': quality.toString(),
          },
        );
        await currentPlayer.open(media, play: true);
        developer.log(
          'Канал переключен и воспроизведение запущено с оптимизацией',
          name: 'PlayerPage',
        );
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
          _notifyChannelSelected(channel);
        }
      } else {
        developer.log(
          'Плеер стал null во время переключения',
          name: 'PlayerPage',
        );
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
      }
    } catch (e, stackTrace) {
      developer.log(
        'Ошибка переключения канала: $e',
        name: 'PlayerPage',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoUrl == null || _videoUrl!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Плеер')),
        body: const Center(child: Text('URL видео не указан')),
      );
    }
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Плеер')),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.errorIcon),
                  const SizedBox(height: 24),
                  Text(
                    'Ошибка воспроизведения',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                      final quality = _getVideoQualityFromSettings(context);
                      _initializePlayer(_videoUrl!, quality: quality);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Повторить'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Назад'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (_isInitializing || _player == null || _videoController == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Плеер')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final bloc = InjectionContainer.instance.createChannelBloc();
            bloc.add(const LoadChannelsEvent());
            _channelBloc = bloc;
            return bloc;
          },
        ),
        BlocProvider.value(
          value: context.read<SettingsBloc>(),
        ),
      ],
      child: BlocBuilder<ChannelBloc, ChannelState>(
        builder: (context, state) {
          if (_channelBloc == null) {
            try {
              _channelBloc = context.read<ChannelBloc>();
            } catch (e) {
              developer.log(
                'ChannelBloc еще не доступен: $e',
                name: 'PlayerPage',
              );
            }
          }
          return _buildPlayerScaffold();
        },
      ),
    );
  }
}
