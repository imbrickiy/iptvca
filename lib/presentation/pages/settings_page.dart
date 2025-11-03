import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:iptvca/domain/entities/settings.dart' as entities;
import 'package:iptvca/presentation/bloc/settings/settings_bloc.dart';
import 'package:iptvca/presentation/bloc/settings/settings_event.dart';
import 'package:iptvca/presentation/bloc/settings/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBloc = context.read<SettingsBloc>();
    if (settingsBloc.state is! SettingsLoaded) {
      settingsBloc.add(const LoadSettingsEvent());
    }
    return const _SettingsPageContent();
  }
}

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBloc = context.read<SettingsBloc>();
    if (settingsBloc.state is! SettingsLoaded) {
      settingsBloc.add(const LoadSettingsEvent());
    }
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(0),
        ),
        child: const _SettingsPageContent(isModal: true),
      ),
    );
  }
}

class _SettingsPageContent extends StatelessWidget {
  const _SettingsPageContent({this.isModal = false});
  final bool isModal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        leading: isModal
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SettingsBloc>().add(
                        const LoadSettingsEvent(),
                      );
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }
          if (state is SettingsLoaded) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSection(context, 'Воспроизведение', [
                  _buildSwitchTile(
                    context,
                    'Автовоспроизведение',
                    'Автоматически запускать воспроизведение при выборе канала',
                    Icons.play_arrow,
                    state.settings.autoplay,
                    (value) {
                      context.read<SettingsBloc>().add(
                        UpdateAutoplayEvent(value),
                      );
                    },
                  ),
                  _buildDropdownTile<entities.VideoQuality>(
                    context,
                    'Качество видео',
                    'Качество видео для воспроизведения',
                    Icons.high_quality,
                    state.settings.videoQuality,
                    entities.VideoQuality.values,
                    (value) {
                      context.read<SettingsBloc>().add(
                        UpdateVideoQualityEvent(value),
                      );
                    },
                    _getVideoQualityLabel,
                  ),
                ]),
                _buildSection(context, 'Внешний вид', [
                  _buildDropdownTile<entities.AppThemeMode>(
                    context,
                    'Тема',
                    'Выбор темы приложения',
                    Icons.palette,
                    state.settings.themeMode,
                    entities.AppThemeMode.values,
                    (value) {
                      context.read<SettingsBloc>().add(
                        UpdateThemeModeEvent(value),
                      );
                    },
                    _getThemeModeLabel,
                  ),
                ]),
                _buildSection(context, 'Уведомления', [
                  _buildSwitchTile(
                    context,
                    'Показывать уведомления',
                    'Разрешить показ уведомлений',
                    Icons.notifications,
                    state.settings.showNotifications,
                    (value) {
                      context.read<SettingsBloc>().add(
                        UpdateShowNotificationsEvent(value),
                      );
                    },
                  ),
                ]),
                _buildSection(context, 'Кэш', [
                  _buildSwitchTile(
                    context,
                    'Включить кэш',
                    'Кэширование данных для быстрой загрузки',
                    Icons.storage,
                    state.settings.cacheEnabled,
                    (value) {
                      context.read<SettingsBloc>().add(
                        UpdateCacheEnabledEvent(value),
                      );
                    },
                  ),
                  if (state.settings.cacheEnabled)
                    _buildSliderTile(
                      context,
                      'Максимальный размер кэша (МБ)',
                      'Размер кэша в мегабайтах',
                      Icons.data_usage,
                      state.settings.maxCacheSize.toDouble(),
                      100,
                      2000,
                      (value) {
                        context.read<SettingsBloc>().add(
                          UpdateMaxCacheSizeEvent(value.toInt()),
                        );
                      },
                    ),
                ]),
                const Divider(height: 32),
                _buildInfoSection(context),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const Divider(height: 16),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildDropdownTile<T>(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    T value,
    List<T> items,
    ValueChanged<T> onChanged,
    String Function(T) getLabel,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<T>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem<T>(value: item, child: Text(getLabel(item)));
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _buildSliderTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 50).round(),
            label: '${value.toInt()} МБ',
            onChanged: onChanged,
          ),
          Text(
            '${value.toInt()} МБ',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final packageInfo = snapshot.data!;
        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Версия приложения'),
              subtitle: Text(
                '${packageInfo.version} (${packageInfo.buildNumber})',
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('О приложении'),
              subtitle: const Text('IPTV приложение для Windows'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Имя пакета'),
              subtitle: Text(packageInfo.packageName),
            ),
          ],
        );
      },
    );
  }

  String _getVideoQualityLabel(entities.VideoQuality quality) {
    switch (quality) {
      case entities.VideoQuality.auto:
        return 'Автоматически';
      case entities.VideoQuality.low:
        return 'Низкое';
      case entities.VideoQuality.medium:
        return 'Среднее';
      case entities.VideoQuality.high:
        return 'Высокое';
      case entities.VideoQuality.best:
        return 'Лучшее';
    }
  }

  String _getThemeModeLabel(entities.AppThemeMode mode) {
    switch (mode) {
      case entities.AppThemeMode.system:
        return 'Системная';
      case entities.AppThemeMode.light:
        return 'Светлая';
      case entities.AppThemeMode.dark:
        return 'Темная';
    }
  }
}
