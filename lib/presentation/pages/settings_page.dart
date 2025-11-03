
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Версия приложения'),
            subtitle: Text('1.0.0'),
          ),
          const Divider(),
          const ListTile(
            title: Text('О приложении'),
            subtitle: Text('IPTV приложение для Windows'),
          ),
        ],
      ),
    );
  }
}

