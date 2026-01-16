
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/daily_log/data/models/daily_log_model.dart';
import 'features/settings/data/models/activity_category_model.dart';
import 'features/settings/data/models/activity_item_model.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/daily_log/presentation/providers/daily_log_provider.dart';
import 'features/daily_log/presentation/screens/add_daily_log_screen.dart';
import 'features/daily_log/presentation/widgets/audio_player_widget.dart'; // NEW
import 'features/settings/presentation/screens/manage_activities_screen.dart';
import 'features/daily_log/presentation/widgets/log_header.dart';
import 'features/daily_log/presentation/widgets/log_media_grid.dart';



import 'core/theme/app_theme.dart';

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

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Mood Tracker',
      theme: AppTheme.normalTheme,
      // We can also set darkTheme if we want to support system dark mode separately,
      // but for this specific "Manga vs Purple" request, we might just want to force these styles.
      // Let's stick to the requested themes as the primary look.
      themeMode: ThemeMode.light, 
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );

  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyLogsAsync = ref.watch(dailyLogsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageActivitiesScreen()),
              );
            },
          ),
        ],
      ),
      body: dailyLogsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('No logs yet. Add one!'));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              
              // Complex View

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddDailyLogScreen(logToEdit: log),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Mood + Date + Timeline
                      LogHeader(log: log),


                      
                      // Content: Activities, Notes, Food
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             // Activities
                             if (log.activityItemIds.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final settingsRepo = ref.watch(settingsRepositoryProvider);
                                      final items = log.activityItemIds
                                          .map((id) => settingsRepo.getItem(id))
                                          .whereType<ActivityItem>()
                                          .toList();
                                      
                                      if (items.isEmpty) return const SizedBox();

                                      return Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: items.map((item) {
                                          final category = settingsRepo.getCategory(item.categoryId);
                                          final color = category != null ? Color(category.colorValue) : Colors.grey;
                                          
                                          Widget? avatar;
                                          if (item.emoji != null && item.emoji!.isNotEmpty) {
                                            avatar = Text(item.emoji!, style: const TextStyle(fontSize: 14));
                                          } else if (category != null && category.emoji != null && category.emoji!.isNotEmpty) {
                                            avatar = Text(category.emoji!, style: const TextStyle(fontSize: 14));
                                          } else if (item.iconCode != null || category != null) {
                                            avatar = Icon(IconData(item.iconCode ?? category!.iconCode, fontFamily: 'MaterialIcons'), 
                                                     size: 14, color: Colors.white);
                                          }

                                          return Chip(
                                            avatar: avatar,
                                            label: Text(item.name, style: const TextStyle(fontSize: 10, color: Colors.white)),
                                            backgroundColor: color,
                                            visualDensity: VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                            side: BorderSide.none,
                                          );
                                        }).toList(),
                                      );
                                    }
                                  ),
                                ),
                             
                             // Notes
                             if (log.notes != null && log.notes!.isNotEmpty)
                               Padding(
                                 padding: const EdgeInsets.only(bottom: 8.0),
                                 child: Text(log.notes!, maxLines: 3, overflow: TextOverflow.ellipsis),
                               ),

                             // Food
                             if (log.food != null && log.food!.isNotEmpty)
                               Padding(
                                 padding: const EdgeInsets.only(bottom: 8.0),
                                 child: Row(
                                   children: [
                                     const Icon(Icons.restaurant, size: 16, color: Colors.grey),
                                     const SizedBox(width: 4),
                                     Text(log.food!, style: const TextStyle(color: Colors.grey)),
                                   ],
                                 ),
                               ),
                          ],
                        ),
                      ),

                      // Full Width Media
                      if (log.mediaPaths.isNotEmpty)
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 16.0),
                         child: LogMediaGrid(log: log),
                         ),

                      
                      // Audio
                      if (log.audioPaths.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            children: log.audioPaths.map((path) => 
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: AudioPlayerWidget(audioPath: path),
                              )
                            ).toList(),
                          ),
                        ),
                      const SizedBox(height: 8), // Bottom padding
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDailyLogScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }


}
