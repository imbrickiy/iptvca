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

class _SettingsPageContent extends StatefulWidget {
  const _SettingsPageContent({this.isModal = false});
  final bool isModal;

  @override
  State<_SettingsPageContent> createState() => _SettingsPageContentState();
}

class _SettingsPageContentState extends State<_SettingsPageContent> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        leading: widget.isModal
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
            _buildSection(context, 'О программе', [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Версия'),
                subtitle: Text(
                  '${packageInfo.version} (Build ${packageInfo.buildNumber})',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('О приложении'),
                subtitle: const Text('IPTV приложение для Windows'),
              ),
            ]),
          ],
        );
      },
    );
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
