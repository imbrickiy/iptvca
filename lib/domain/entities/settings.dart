import 'package:equatable/equatable.dart';

class Settings extends Equatable {
  const Settings({
    this.autoplay = true,
    this.videoQuality = VideoQuality.auto,
    this.themeMode = AppThemeMode.system,
    this.showNotifications = true,
    this.cacheEnabled = true,
    this.maxCacheSize = 500,
  });

  final bool autoplay;
  final VideoQuality videoQuality;
  final AppThemeMode themeMode;
  final bool showNotifications;
  final bool cacheEnabled;
  final int maxCacheSize;

  Settings copyWith({
    bool? autoplay,
    VideoQuality? videoQuality,
    AppThemeMode? themeMode,
    bool? showNotifications,
    bool? cacheEnabled,
    int? maxCacheSize,
  }) {
    return Settings(
      autoplay: autoplay ?? this.autoplay,
      videoQuality: videoQuality ?? this.videoQuality,
      themeMode: themeMode ?? this.themeMode,
      showNotifications: showNotifications ?? this.showNotifications,
      cacheEnabled: cacheEnabled ?? this.cacheEnabled,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
    );
  }

  @override
  List<Object?> get props => [
        autoplay,
        videoQuality,
        themeMode,
        showNotifications,
        cacheEnabled,
        maxCacheSize,
      ];
}

enum VideoQuality {
  auto,
  low,
  medium,
  high,
  best,
}

enum AppThemeMode {
  system,
  light,
  dark,
}

