
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationService {
  final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize Timezone
    tz.initializeTimeZones();
    final dynamic localTimezone = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = localTimezone.toString();
    
    try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
        // Fallback to UTC or a default if failed
        debugPrint('Failed to set location: $e');
        tz.setLocalLocation(tz.local);
    }

    // Android Initialization
    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    const fln.DarwinInitializationSettings initializationSettingsDarwin =
        fln.DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const fln.InitializationSettings initializationSettings = fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
     await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
     
     await flutterLocalNotificationsPlugin
           .resolvePlatformSpecificImplementation<
               fln.IOSFlutterLocalNotificationsPlugin>()
           ?.requestPermissions(
             alert: true,
             badge: true,
             sound: true,
           );
  }

  Future<void> scheduleDailyNotification(TimeOfDay time) async {
    // Cancel existing to ensure only one is active
    await cancelNotifications();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID
      'Hora de registrar!',
      'Não se esqueça de registrar como foi o seu dia no GoodDay.',
      _nextInstanceOfTime(time),
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'daily_reminder_channel',
          'Lembrete Diário',
          channelDescription: 'Canal para lembretes diários de registro',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
        ),
        iOS: fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: fln.DateTimeComponents.time, // Daily match
    );
  }

  Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
