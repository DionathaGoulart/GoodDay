
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('Lembrete Diário'),
                subtitle: const Text('Receba um lembrete para registrar seu dia'),
                value: settings.isEnabled,
                onChanged: (value) {
                  ref.read(notificationSettingsProvider.notifier).updateSettings(isEnabled: value);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Horário do Lembrete'),
                subtitle: Text(settings.time.format(context)),
                trailing: const Icon(Icons.access_time),
                enabled: settings.isEnabled,
                onTap: () async {
                  final TimeOfDay? newTime = await showTimePicker(
                    context: context,
                    initialTime: settings.time,
                    builder: (BuildContext context, Widget? child) {
                       return MediaQuery(
                         data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), // Force 24h if preferred or stick to system
                         child: child!,
                       );
                    },
                  );
                  
                  if (newTime != null) {
                    ref.read(notificationSettingsProvider.notifier).updateSettings(time: newTime);
                  }
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar configurações: $err')),
      ),
    );
  }
}
