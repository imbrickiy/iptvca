
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iptvca/core/di/injection_container.dart';
import 'package:iptvca/presentation/bloc/channel/channel_bloc.dart';
import 'package:iptvca/presentation/bloc/channel/channel_event.dart';
import 'package:iptvca/presentation/bloc/channel/channel_state.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:iptvca/presentation/widgets/channel_item.dart';
import 'package:go_router/go_router.dart';

class _GroupsScrollWidget extends StatefulWidget {
  const _GroupsScrollWidget({
    required this.groups,
    this.selectedGroup,
  });
  final List<String> groups;
  final String? selectedGroup;

  @override
  State<_GroupsScrollWidget> createState() => _GroupsScrollWidgetState();
}

class _GroupsScrollWidgetState extends State<_GroupsScrollWidget> {
  late final ScrollController _scrollController;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollButtons);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollButtons();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollButtons);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (!_scrollController.hasClients) {
      return;
    }
    final canScrollLeft = _scrollController.offset > 0;
    final canScrollRight =
        _scrollController.offset < _scrollController.position.maxScrollExtent;
    if (canScrollLeft != _canScrollLeft || canScrollRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canScrollLeft;
        _canScrollRight = canScrollRight;
      });
    }
  }

  void _scrollLeft() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        (_scrollController.offset - 200).clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollRight() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        (_scrollController.offset + 200).clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _canScrollLeft ? _scrollLeft : null,
            tooltip: 'Прокрутить влево',
          ),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 6,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: widget.groups.length,
                itemBuilder: (context, index) {
                  final group = widget.groups[index];
                  final isSelected = widget.selectedGroup == group;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(group),
                      selected: isSelected,
                      onSelected: (selected) {
                        context.read<ChannelBloc>().add(
                              FilterChannelsByGroupEvent(
                                selected ? group : '',
                              ),
                            );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _canScrollRight ? _scrollRight : null,
            tooltip: 'Прокрутить вправо',
          ),
        ],
      ),
    );
  }
}

class ChannelsPage extends StatelessWidget {
  const ChannelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final channels = GoRouterState.of(context).extra as List<Channel>?;
    final showFavorites = GoRouterState.of(context).uri.queryParameters['favorites'] == 'true';
    return BlocProvider(
      create: (context) {
        final bloc = InjectionContainer.instance.createChannelBloc();
        if (channels != null && channels.isNotEmpty) {
          bloc.setChannels(channels);
          bloc.add(LoadChannelsEvent(showFavoritesOnly: showFavorites));
        } else {
          bloc.add(LoadChannelsEvent(showFavoritesOnly: showFavorites));
        }
        return bloc;
      },
      key: ValueKey(channels?.length ?? 0),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Каналы'),
        ),
        body: BlocBuilder<ChannelBloc, ChannelState>(
          builder: (context, state) {
            if (state is ChannelLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChannelsLoaded) {
              if (state.channels.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.tv_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 24),
                        Text(
                          'Нет доступных каналов',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Загрузите плейлист, чтобы увидеть каналы',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/playlists'),
                          icon: const Icon(Icons.playlist_play),
                          label: const Text('Перейти к плейлистам'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Поиск каналов',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              context.read<ChannelBloc>().add(
                                    SearchChannelsEvent(value),
                                  );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            state.showFavoritesOnly
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          color: state.showFavoritesOnly ? Colors.red : null,
                          tooltip: state.showFavoritesOnly
                              ? 'Показать все каналы'
                              : 'Показать только избранные',
                          onPressed: () {
                            context.read<ChannelBloc>().add(
                                  FilterFavoritesEvent(!state.showFavoritesOnly),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                  if (state.availableGroups.isNotEmpty && !state.showFavoritesOnly)
                    _GroupsScrollWidget(groups: state.availableGroups, selectedGroup: state.filterGroup),
                  Expanded(
                    child: state.filteredChannels.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Каналы не найдены',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Попробуйте изменить параметры поиска или фильтр',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.filteredChannels.length,
                            itemBuilder: (context, index) {
                              final channel = state.filteredChannels[index];
                              return ChannelItem(channel: channel);
                            },
                          ),
                  ),
                ],
              );
            }

            if (state is ChannelError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 24),
                      Text(
                        'Ошибка загрузки каналов',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<ChannelBloc>().add(
                                const LoadChannelsEvent(),
                              );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: Text('Загрузите плейлист'));
          },
        ),
      ),
    );
  }
}

