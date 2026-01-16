
import 'package:flutter/material.dart';
import 'package:good_day/features/settings/presentation/screens/manage_activities_screen.dart';
import 'backup_screen.dart';
import 'notification_settings_screen.dart';
import 'package:good_day/core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.category, color: AppTheme.pastelTeal),
            title: const Text('Atividades e Escalas'),
            subtitle: const Text('Gerenciar grupos, atividades e escalas de humor'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageActivitiesScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications, color: AppTheme.pastelYellow),
            title: const Text('Notificações'),
            subtitle: const Text('Configurar lembretes diários'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore, color: AppTheme.pastelGreen),
            title: const Text('Dados e Backup'),
            subtitle: const Text('Exportar, importar e gerenciar dados'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BackupScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
