import 'package:equatable/equatable.dart';
import 'package:iptvca/domain/entities/settings.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.settings,
    this.isSaving = false,
  });

  final Settings settings;
  final bool isSaving;

  @override
  List<Object?> get props => [settings, isSaving];

  SettingsLoaded copyWith({
    Settings? settings,
    bool? isSaving,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class SettingsError extends SettingsState {
  const SettingsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

