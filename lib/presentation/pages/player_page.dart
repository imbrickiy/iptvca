import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iptvca/core/di/injection_container.dart';
import 'package:iptvca/core/utils/debounce.dart';
import 'package:iptvca/presentation/bloc/channel/channel_bloc.dart';
import 'package:iptvca/presentation/bloc/channel/channel_event.dart';
import 'package:iptvca/presentation/bloc/channel/channel_state.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:iptvca/presentation/widgets/epg_programs_dialog.dart';
import 'package:window_manager/window_manager.dart';

class _ChannelSelectorDrawer extends StatefulWidget {
  const _ChannelSelectorDrawer({required this.onChannelSelected});
  final void Function(Channel) onChannelSelected;

  @override
  State<_ChannelSelectorDrawer> createState() => _ChannelSelectorDrawerState();
}

class _ChannelSelectorDrawerState extends State<_ChannelSelectorDrawer> {
  late final Debounce _debounce;

  @override
  void initState() {
    super.initState();
    _debounce = Debounce(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _debounce.dispose();
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
                    context.read<ChannelBloc>().add(SearchChannelsEvent(value));
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
                    color: state.showFavoritesOnly ? Colors.red : null,
                  ),
                  title: const Text('Только избранные'),
                  trailing: Switch(
                    value: state.showFavoritesOnly,
                    onChanged: (value) {
                      context.read<ChannelBloc>().add(
                        FilterFavoritesEvent(value),
                      );
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
            onTap: () => _debounce(() {
              Navigator.of(context).pop();
              context.go('/');
            }),
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
                          color: Colors.red,
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
                            color: Colors.grey,
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
    final groupedChannels = _groupChannelsByCategory(widget.channels);
    final categories = groupedChannels.keys.toList()..sort();
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryChannels = groupedChannels[category]!;
        return ExpansionTile(
          initiallyExpanded: false,
          leading: const Icon(Icons.folder_outlined),
          title: Text(category),
          subtitle: Text('${categoryChannels.length} каналов'),
          children: categoryChannels.map((channel) {
            return _ChannelDrawerItem(
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
    required this.channel,
    required this.onChannelSelected,
  });
  final Channel channel;
  final void Function(Channel) onChannelSelected;

  @override
  State<_ChannelDrawerItem> createState() => _ChannelDrawerItemState();
}

class _ChannelDrawerItemState extends State<_ChannelDrawerItem> {
  late final Debounce _debounce;
  bool? _localIsFavorite;

  @override
  void initState() {
    super.initState();
    _debounce = Debounce(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _debounce.dispose();
    super.dispose();
  }

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
          if (prevChannelIndex == -1 && currChannelIndex == -1) {
            return false;
          }
          if (prevChannelIndex != -1 && currChannelIndex != -1) {
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
          final channelIndex = blocState.channels.indexWhere(
            (c) => c.id == widget.channel.id,
          );
          if (channelIndex != -1) {
            currentChannel = blocState.channels[channelIndex];
            isFavorite = currentChannel.isFavorite;
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
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => _debounce(() {
                final newFavoriteStatus = !isFavorite;
                setState(() {
                  _localIsFavorite = newFavoriteStatus;
                });
                context.read<ChannelBloc>().add(
                      ToggleFavoriteEvent(currentChannel),
                    );
              }),
            ),
          onTap: () => _debounce(() {
            context.read<ChannelBloc>().add(SelectChannelEvent(currentChannel));
            Navigator.of(context).pop();
            widget.onChannelSelected(currentChannel);
          }),
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
  late final Debounce _debounce;

  @override
  void initState() {
    super.initState();
    _debounce = Debounce(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _debounce.dispose();
    super.dispose();
  }

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
          if (prevChannelIndex != -1 && currChannelIndex != -1) {
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
          if (channelIndex != -1) {
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
                onTap: () => _debounce(() {
                  widget.onLocalFavoriteChanged(!favorite);
                  context.read<ChannelBloc>().add(ToggleFavoriteEvent(channel));
                }),
                child: Icon(
                  favorite ? Icons.favorite : Icons.favorite_border,
                  color: favorite ? Colors.red : null,
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
  bool? _localIsFavorite;
  late final bool _supportsWindowControls;
  late final Debounce _debounce;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isAlwaysOnTop = false;
  bool _hasInitializedFromExtra = false;

  @override
  void initState() {
    super.initState();
    _debounce = Debounce(const Duration(milliseconds: 300));
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
        if (channel != null) {
          context.read<ChannelBloc>().add(SelectChannelEvent(channel));
        }
        _initializePlayer(_videoUrl!);
      }
    } else {
      try {
        final bloc = context.read<ChannelBloc>();
        _restoreLastChannel(bloc);
      } catch (e) {
        developer.log(
          'ChannelBloc еще не доступен, восстановление будет выполнено позже',
          name: 'PlayerPage',
        );
      }
    }
  }

  Future<void> _restoreLastChannel(ChannelBloc bloc) async {
    if (_hasInitializedFromExtra || _currentChannel != null) {
      return;
    }
    try {
      if (bloc.state is! ChannelsLoaded) {
        developer.log(
          'Каналы еще не загружены, ожидание...',
          name: 'PlayerPage',
        );
        bloc.stream.firstWhere((state) => state is ChannelsLoaded).then((_) {
          if (mounted) {
            _restoreLastChannel(bloc);
          }
        });
        return;
      }
      final lastChannel = await bloc.getLastChannel();
      if (lastChannel != null && mounted) {
        developer.log(
          'Восстановление последнего канала: ${lastChannel.name}',
          name: 'PlayerPage',
        );
        _disposeController();
        _videoUrl = lastChannel.url;
        _currentChannel = lastChannel;
        _errorMessage = null;
        _localIsFavorite = null;
        _hasInitializedFromExtra = true;
        _initializePlayer(_videoUrl!);
      }
    } catch (e, stackTrace) {
      developer.log(
        'Ошибка восстановления последнего канала: $e',
        name: 'PlayerPage',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _disposeController() {
    _player?.dispose();
    _videoController = null;
    _player = null;
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

  Future<void> _initializePlayer(String url) async {
    if (_isInitializing) return;
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });
    try {
      developer.log('Инициализация плеера для URL: $url', name: 'PlayerPage');
      final isHls =
          url.toLowerCase().endsWith('.m3u8') ||
          url.toLowerCase().contains('/hls/') ||
          url.toLowerCase().contains('m3u8');
      if (isHls) {
        developer.log('Обнаружен HLS поток (.m3u8)', name: 'PlayerPage');
      }
      _player = Player();
      _videoController = VideoController(_player!);
      _player!.stream.error.listen((error) {
        developer.log('Ошибка воспроизведения: $error', name: 'PlayerPage');
        if (mounted) {
          setState(() {
            _errorMessage = error.toString();
          });
        }
      });
      await _player!.open(Media(url));
      developer.log('MediaKit Player создан и запущен', name: 'PlayerPage');
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

  Future<void> _switchChannel(Channel channel) async {
    final player = _player;
    if (player == null || _videoController == null) {
      _currentChannel = channel;
      _videoUrl = channel.url;
      _localIsFavorite = null;
      context.read<ChannelBloc>().add(SelectChannelEvent(channel));
      await _initializePlayer(channel.url);
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
    context.read<ChannelBloc>().add(SelectChannelEvent(channel));
    try {
      developer.log(
        'Переключение канала на: ${channel.name}',
        name: 'PlayerPage',
      );
      final currentPlayer = _player;
      if (currentPlayer != null) {
        await currentPlayer.stop();
        await currentPlayer.open(Media(channel.url));
        await currentPlayer.play();
        developer.log(
          'Канал переключен и воспроизведение запущено',
          name: 'PlayerPage',
        );
      } else {
        developer.log(
          'Плеер стал null во время переключения',
          name: 'PlayerPage',
        );
      }
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
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
    _debounce.dispose();
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                  onPressed: () => _debounce(() {
                    setState(() {
                      _errorMessage = null;
                    });
                    _initializePlayer(_videoUrl!);
                  }),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Повторить'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _debounce(() => context.pop()),
                  child: const Text('Назад'),
                ),
              ],
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
    return BlocProvider(
      create: (context) {
        final bloc = InjectionContainer.instance.createChannelBloc();
        bloc.add(const LoadChannelsEvent());
        bloc.stream.firstWhere((state) => state is ChannelsLoaded).then((_) {
          if (mounted && !_hasInitializedFromExtra && _currentChannel == null) {
            _restoreLastChannel(bloc);
          }
        });
        return bloc;
      },
      child: Scaffold(
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
            Center(child: Video(controller: _videoController!)),
            if (_isInitializing)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
