
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/backup_service.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dados e Backup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
           Card(
             child: Column(
               children: [
                 ListTile(
                  title: const Text('Verificar Status do Backup (Android)'),
                  subtitle: const Text('Gerenciar backup do sistema'),
                  leading: const Icon(Icons.settings_backup_restore),
                  onTap: () async {
                     await ref.read(backupServiceProvider).openSystemBackupSettings(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Exportar Dados'),
                  subtitle: const Text('Salvar backup em arquivo JSON'),
                  leading: const Icon(Icons.upload_file),
                  onTap: () async {
                     await ref.read(backupServiceProvider).exportData(context);
                  },
                ),
                const Divider(height: 1),
                 ListTile(
                  title: const Text('Importar Dados'),
                  subtitle: const Text('Restaurar backup de arquivo JSON'),
                  leading: const Icon(Icons.file_download),
                  onTap: () async {
                     await ref.read(backupServiceProvider).importData(context);
                  },
                ),
               ],
             ),
           ),
           const Padding(
             padding: EdgeInsets.all(16.0),
             child: Text(
               'Nota: O backup gerado inclui suas configurações de atividades e registros diários. Mantenha o arquivo em local seguro.',
               style: TextStyle(color: Colors.grey, fontSize: 12),
               textAlign: TextAlign.center,
             ),
           ),
        ],
      ),
    );
  }
}
