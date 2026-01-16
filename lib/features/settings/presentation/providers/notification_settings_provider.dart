
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/notification_service.dart';

class NotificationSettings {
  final bool isEnabled;
  final TimeOfDay time;

  NotificationSettings({required this.isEnabled, required this.time});

  NotificationSettings copyWith({bool? isEnabled, TimeOfDay? time}) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      time: time ?? this.time,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<AsyncValue<NotificationSettings>> {
  final NotificationService _notificationService;

  NotificationSettingsNotifier(this._notificationService) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('daily_reminder_enabled') ?? false;
      final hour = prefs.getInt('daily_reminder_hour') ?? 20;
      final minute = prefs.getInt('daily_reminder_minute') ?? 0;

      state = AsyncValue.data(NotificationSettings(
        isEnabled: isEnabled,
        time: TimeOfDay(hour: hour, minute: minute),
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSettings({bool? isEnabled, TimeOfDay? time}) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final newSettings = currentSettings.copyWith(
      isEnabled: isEnabled,
      time: time,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('daily_reminder_enabled', newSettings.isEnabled);
      await prefs.setInt('daily_reminder_hour', newSettings.time.hour);
      await prefs.setInt('daily_reminder_minute', newSettings.time.minute);

      state = AsyncValue.data(newSettings);

      if (newSettings.isEnabled) {
        await _notificationService.requestPermissions();
        await _notificationService.scheduleDailyNotification(newSettings.time);
      } else {
        await _notificationService.cancelNotifications();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, AsyncValue<NotificationSettings>>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationSettingsNotifier(notificationService);
});
