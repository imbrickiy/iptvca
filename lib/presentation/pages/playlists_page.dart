
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iptvca/core/di/injection_container.dart';
import 'package:iptvca/presentation/bloc/playlist/playlist_bloc.dart';
import 'package:iptvca/presentation/bloc/playlist/playlist_event.dart';
import 'package:iptvca/presentation/bloc/playlist/playlist_state.dart';
import 'package:iptvca/data/models/playlist_model.dart';
import 'package:iptvca/domain/entities/channel.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InjectionContainer.instance.createPlaylistBloc()
            ..add(const LoadPlaylistsEvent()),
      child: const PlaylistsPageView(),
    );
  }
}

class PlaylistsPageView extends StatefulWidget {
  const PlaylistsPageView({super.key});

  @override
  State<PlaylistsPageView> createState() => _PlaylistsPageViewState();
}

class _PlaylistsPageViewState extends State<PlaylistsPageView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Плейлисты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPlaylistDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PlaylistError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PlaylistBloc>().add(
                            const LoadPlaylistsEvent(),
                          );
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (state is ChannelsLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _savePlaylistFromChannels(context, state.channels);
            });
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is PlaylistLoaded) {
            if (state.playlists.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.playlist_play, size: 64),
                    const SizedBox(height: 16),
                    const Text('Нет плейлистов'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showAddPlaylistDialog(context),
                      child: const Text('Добавить плейлист'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: state.playlists.length,
              itemBuilder: (context, index) {
                final playlist = state.playlists[index];
                return ListTile(
                  key: ValueKey(playlist.id),
                  title: Text(playlist.name),
                  subtitle: Text('${playlist.channels.length} каналов'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<PlaylistBloc>().add(
                            DeletePlaylistEvent(playlist.id),
                          );
                    },
                  ),
                  onTap: () {
                    context.push('/channels', extra: playlist.channels);
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddPlaylistDialog(BuildContext context) {
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Добавить плейлист'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL плейлиста',
                hintText: 'https://example.com/playlist.m3u',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['m3u', 'm3u8'],
                );
                if (result != null && result.files.single.path != null) {
                  Navigator.pop(dialogContext);
                  context.read<PlaylistBloc>().add(
                        LoadPlaylistFromFileEvent(
                          result.files.single.path!,
                        ),
                      );
                }
              },
              icon: const Icon(Icons.folder),
              label: const Text('Выбрать файл'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                Navigator.pop(dialogContext);
                context.read<PlaylistBloc>().add(
                      LoadPlaylistFromUrlEvent(urlController.text),
                    );
              }
            },
            child: const Text('Загрузить'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePlaylistFromChannels(
    BuildContext context,
    List<Channel> channels,
  ) async {
    if (channels.isEmpty) {
      context.read<PlaylistBloc>().add(const LoadPlaylistsEvent());
      return;
    }

    final uuid = const Uuid();
    final playlist = PlaylistModel(
      id: uuid.v4(),
      name: 'Новый плейлист',
      source: 'local',
      lastUpdated: DateTime.now(),
      channels: channels,
    );

    context.read<PlaylistBloc>().add(SavePlaylistEvent(playlist));
    
    await Future.delayed(const Duration(milliseconds: 500));
    await context.read<PlaylistBloc>().stream.firstWhere(
      (state) => state is PlaylistLoaded || state is PlaylistError,
    );
    
    if (context.mounted) {
      context.push('/channels', extra: channels);
    }
  }
}

