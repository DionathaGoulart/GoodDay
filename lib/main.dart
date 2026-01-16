
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/daily_log/data/models/daily_log_model.dart';
import 'features/settings/data/models/activity_category_model.dart';
import 'features/settings/data/models/activity_item_model.dart';
import 'features/navigation/presentation/screens/main_scaffold.dart'; 
import 'core/theme/app_theme.dart';

import 'features/settings/data/services/notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();
  Hive.registerAdapter(DailyLogAdapter());
  Hive.registerAdapter(ActivityCategoryAdapter());
  Hive.registerAdapter(ActivityItemAdapter());
  Hive.registerAdapter(MoodRecordAdapter());
  await Hive.openBox<ActivityCategory>('activity_categories_v3');
  await Hive.openBox<ActivityItem>('activity_items_v3');
  await Hive.openBox('settings_v3');

  try {
    await Hive.openBox<DailyLog>('daily_logs_v3');
  } catch (e) {
    debugPrint('Error opening daily_logs_v3 box: $e');
    await Hive.deleteBoxFromDisk('daily_logs_v3');
    await Hive.openBox<DailyLog>('daily_logs_v3');
  }

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();

  // Initialize Date Formatting
  await initializeDateFormatting('pt_BR', null);

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'GoodDay',
      theme: AppTheme.theme,
      themeMode: ThemeMode.dark, 
      home: const MainScaffold(), 
      debugShowCheckedModeBanner: false,
    );

  }
}
