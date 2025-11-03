import 'package:equatable/equatable.dart';
import 'package:iptvca/domain/entities/settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class UpdateAutoplayEvent extends SettingsEvent {
  const UpdateAutoplayEvent(this.autoplay);
  final bool autoplay;

  @override
  List<Object?> get props => [autoplay];
}

class UpdateVideoQualityEvent extends SettingsEvent {
  const UpdateVideoQualityEvent(this.videoQuality);
  final VideoQuality videoQuality;

  @override
  List<Object?> get props => [videoQuality];
}

class UpdateThemeModeEvent extends SettingsEvent {
  const UpdateThemeModeEvent(this.themeMode);
  final AppThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

class UpdateShowNotificationsEvent extends SettingsEvent {
  const UpdateShowNotificationsEvent(this.showNotifications);
  final bool showNotifications;

  @override
  List<Object?> get props => [showNotifications];
}

class UpdateCacheEnabledEvent extends SettingsEvent {
  const UpdateCacheEnabledEvent(this.cacheEnabled);
  final bool cacheEnabled;

  @override
  List<Object?> get props => [cacheEnabled];
}

class UpdateMaxCacheSizeEvent extends SettingsEvent {
  const UpdateMaxCacheSizeEvent(this.maxCacheSize);
  final int maxCacheSize;

  @override
  List<Object?> get props => [maxCacheSize];
}

class SaveSettingsEvent extends SettingsEvent {
  const SaveSettingsEvent();
}

