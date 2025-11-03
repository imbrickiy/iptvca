import 'package:iptvca/domain/entities/settings.dart';

class SettingsModel extends Settings {
  const SettingsModel({
    super.autoplay = true,
    super.videoQuality = VideoQuality.auto,
    super.themeMode = AppThemeMode.system,
    super.showNotifications = true,
    super.cacheEnabled = true,
    super.maxCacheSize = 500,
  });

  factory SettingsModel.fromEntity(Settings settings) {
    return SettingsModel(
      autoplay: settings.autoplay,
      videoQuality: settings.videoQuality,
      themeMode: settings.themeMode,
      showNotifications: settings.showNotifications,
      cacheEnabled: settings.cacheEnabled,
      maxCacheSize: settings.maxCacheSize,
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      autoplay: json['autoplay'] as bool? ?? true,
      videoQuality: _parseVideoQuality(json['video_quality'] as String?),
      themeMode: _parseThemeMode(json['theme_mode'] as String?),
      showNotifications: json['show_notifications'] as bool? ?? true,
      cacheEnabled: json['cache_enabled'] as bool? ?? true,
      maxCacheSize: json['max_cache_size'] as int? ?? 500,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoplay': autoplay,
      'video_quality': _videoQualityToString(videoQuality),
      'theme_mode': _themeModeToString(themeMode),
      'show_notifications': showNotifications,
      'cache_enabled': cacheEnabled,
      'max_cache_size': maxCacheSize,
    };
  }

  static VideoQuality _parseVideoQuality(String? value) {
    switch (value) {
      case 'low':
        return VideoQuality.low;
      case 'medium':
        return VideoQuality.medium;
      case 'high':
        return VideoQuality.high;
      case 'best':
        return VideoQuality.best;
      default:
        return VideoQuality.auto;
    }
  }

  static String _videoQualityToString(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.low:
        return 'low';
      case VideoQuality.medium:
        return 'medium';
      case VideoQuality.high:
        return 'high';
      case VideoQuality.best:
        return 'best';
      case VideoQuality.auto:
        return 'auto';
    }
  }

  static AppThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  static String _themeModeToString(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  SettingsModel copyWithModel({
    bool? autoplay,
    VideoQuality? videoQuality,
    AppThemeMode? themeMode,
    bool? showNotifications,
    bool? cacheEnabled,
    int? maxCacheSize,
  }) {
    return SettingsModel(
      autoplay: autoplay ?? this.autoplay,
      videoQuality: videoQuality ?? this.videoQuality,
      themeMode: themeMode ?? this.themeMode,
      showNotifications: showNotifications ?? this.showNotifications,
      cacheEnabled: cacheEnabled ?? this.cacheEnabled,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
    );
  }
}

