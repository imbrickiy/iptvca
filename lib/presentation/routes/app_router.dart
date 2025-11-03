
import 'package:go_router/go_router.dart';
import 'package:iptvca/presentation/pages/home_page.dart';
import 'package:iptvca/presentation/pages/channels_page.dart';
import 'package:iptvca/presentation/pages/player_page.dart';
import 'package:iptvca/presentation/pages/settings_page.dart';
import 'package:iptvca/presentation/pages/playlists_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/channels',
      builder: (context, state) => const ChannelsPage(),
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) => const PlayerPage(),
    ),
    GoRoute(
      path: '/playlists',
      builder: (context, state) => const PlaylistsPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

