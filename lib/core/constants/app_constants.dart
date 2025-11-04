import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'IPTV';
  static const String appVersion = '1.0.0';
  static const String userAgent = 'IPTVCA/1.0';

  // Window Settings
  static const int minWindowWidth = 1024;
  static const int minWindowHeight = 768;

  // Storage Keys
  static const String favoritesKey = 'favorite_channels';
  static const String playlistsKey = 'playlists';
  static const String settingsKey = 'app_settings';
  static const String epgCacheKey = 'epg_cache';
  static const String epgCacheTimestampKey = 'epg_cache_timestamp';
  static const String networkCachePrefix = 'network_cache_';
  static const String networkCacheTimestampPrefix = 'network_cache_timestamp_';

  // Cache File Names
  static const String channelsCacheFileName = 'channels_cache.json';
  static const String channelsCacheMetadataFileName =
      'channels_cache_metadata.json';

  // Durations
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration channelCheckTimeout = Duration(seconds: 5);
  static const Duration channelCacheDuration = Duration(minutes: 30);
  static const Duration epgCacheValidityDuration = Duration(hours: 24);
  static const Duration networkCacheValidityDuration = Duration(hours: 24);
  static const Duration searchDebounceDuration = Duration(milliseconds: 300);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
  static const Duration splashScreenAnimationDuration = Duration(
    milliseconds: 1500,
  );
  static const Duration splashScreenTimeout = Duration(seconds: 5);
  static const Duration playlistSaveDelay = Duration(milliseconds: 500);

  // Retry Settings
  static const int maxRetryAttempts = 3;
  static const int maxHistoryItems = 50;

  // UI Sizes - Player Page
  static const double playerLogoSize = 80.0;
  static const double playerLogoIconSize = 40.0;
  static const double playerChannelIconSize = 48.0;
  static const double playerChannelIconSizeLarge = 100.0;
  static const double playerChannelIconSizeError = 64.0;
  static const double playerChannelImageMemCacheWidth = 96;
  static const double playerChannelImageMemCacheHeight = 96;
  static const double playerChannelImageMemCacheWidthLarge = 200;
  static const double playerChannelImageMemCacheHeightLarge = 200;
  static const double playerProgressIndicatorStrokeWidth = 2.0;
  static const double playerErrorIconSize = 64.0;
  static const double playerDrawerShadowBlurRadius = 12.0;
  static const Offset playerDrawerShadowOffset = Offset(0, 4);
  static const double playerDrawerBorderRadius = 16.0;
  static const double playerChannelNameMaxLines = 2;
  static const int playerListViewCacheExtent = 500;

  // UI Spacing - Player Page
  static const double playerSpacingSmall = 8.0;
  static const double playerSpacingMedium = 16.0;
  static const double playerSpacingLarge = 24.0;
  static const double playerSpacingExtraLarge = 32.0;
  static const double playerPadding = 16.0;
  static const double playerPaddingLarge = 24.0;
  static const double playerPaddingBottom = 16.0;

  // UI Sizes - Splash Screen
  static const double splashScreenLogoSize = 200.0;
  static const double splashScreenProgressIndicatorSize = 40.0;
  static const double splashScreenProgressIndicatorStrokeWidth = 3.0;
  static const double splashScreenSpacing = 48.0;

  // UI Sizes - Channels Page
  static const double channelsPageScrollBarThickness = 6.0;
  static const double channelsPageScrollBarHeight = 60.0;
  static const double channelsPageScrollBarPadding = 8.0;
  static const double channelsPageScrollBarScrollAmount = 200.0;

  // UI Sizes - EPG Dialog
  static const double epgDialogIconSize = 20.0;

  // UI Sizes - General
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Player Settings - Buffer Sizes (in bytes)
  static const int bufferSizeLow = 3 * 1024 * 1024; // 3 MB
  static const int bufferSizeMedium = 5 * 1024 * 1024; // 5 MB
  static const int bufferSizeHigh = 8 * 1024 * 1024; // 8 MB
  static const int bufferSizeBest = 12 * 1024 * 1024; // 12 MB
  static const int bufferSizeAuto = 5 * 1024 * 1024; // 5 MB

  // Player Settings - Initial Buffer Sizes (in bytes)
  static const int initialBufferSizeLow = 512 * 1024; // 512 KB
  static const int initialBufferSizeMedium = 1024 * 1024; // 1 MB
  static const int initialBufferSizeHigh = 2 * 1024 * 1024; // 2 MB
  static const int initialBufferSizeBest = 3 * 1024 * 1024; // 3 MB
  static const int initialBufferSizeAuto = 1024 * 1024; // 1 MB

  // Player Settings - Network Timeouts (in milliseconds)
  static const int networkTimeoutLow = 8000;
  static const int networkTimeoutMedium = 10000;
  static const int networkTimeoutHigh = 15000;
  static const int networkTimeoutBest = 20000;
  static const int networkTimeoutAuto = 12000;

  // HTTP Headers
  static const Map<String, String> httpHeaders = {
    'Connection': 'keep-alive',
    'Accept': '*/*',
    'User-Agent': userAgent,
    'Accept-Encoding': 'identity',
    'Accept-Language': '*',
  };

  // EPG Settings
  static const String defaultEpgUrl = 'http://epg.one/epg.xml.gz';

  // Animation Values
  static const double animationFadeBegin = 0.0;
  static const double animationFadeEnd = 1.0;
  static const double animationScaleBegin = 0.5;
  static const double animationScaleEnd = 1.0;
  static const double opacityLow = 0.1;
  static const double opacityMedium = 0.2;
  static const double opacityHigh = 0.8;

  // Letter Spacing
  static const double letterSpacingSmall = 0.5;

  // Channel Availability Settings
  static const int maxConcurrentChannelChecks = 5;
  static const int channelCheckRangeBytes =
      1024; // 1KB for HEAD request fallback

  // Negative Index (for invalid indices)
  static const int invalidIndex = -1;
}
