
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iptvca/presentation/pages/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showSettingsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SettingsModal(),
      barrierDismissible: true,
    );
  }

  void _navigateToPlaylists(BuildContext context) {
    context.push('/playlists');
  }

  void _navigateToChannels(BuildContext context) {
    context.push('/channels');
  }

  void _navigateToFavorites(BuildContext context) {
    context.push('/channels?favorites=true');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPTV'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSettingsModal(context),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: InkWell(
                onTap: () => _navigateToPlaylists(context),
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Icon(Icons.playlist_play, size: 48),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Плейлисты',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('Управление IPTV плейлистами'),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: InkWell(
                onTap: () => _navigateToChannels(context),
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Icon(Icons.tv, size: 48),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Каналы',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('Просмотр доступных каналов'),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: InkWell(
                onTap: () => _navigateToFavorites(context),
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, size: 48, color: Colors.red),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Избранные каналы',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('Просмотр избранных каналов'),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

