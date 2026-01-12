import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'features/daily_log/data/models/daily_log_model.dart';
import 'features/settings/data/models/activity_category_model.dart';
import 'features/settings/data/models/activity_item_model.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/daily_log/presentation/providers/daily_log_provider.dart';
import 'features/daily_log/presentation/screens/add_daily_log_screen.dart';
import 'features/daily_log/presentation/widgets/audio_player_widget.dart'; // NEW
import 'features/settings/presentation/screens/manage_activities_screen.dart';

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
    final isMinimalist = ref.watch(minimalistModeProvider);

    return MaterialApp(
      title: 'Mood Tracker',
      theme: isMinimalist ? AppTheme.minimalistTheme : AppTheme.normalTheme,
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

          final isMinimalist = ref.watch(minimalistModeProvider);

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              
              if (isMinimalist) {
                 // Minimalist View: Simple Text List, but with Moods, now matching Normal Header structure
                 return InkWell(
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
                       // Unified Header (Matches Normal View)
                       Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mood Icon (Grayscale)
                            ColorFiltered(
                              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.saturation),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 24,
                                child: _getMoodIcon(log.mood, size: 36, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date
                                  Text(
                                    _formatDate(log.date),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  // Timeline
                                  if (log.moodHistory.isNotEmpty && log.moodHistory.length > 1)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: log.moodHistory.map((record) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                DateFormat.Hm().format(record.timestamp),
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              ),
                                              const SizedBox(width: 2),
                                              ColorFiltered(
                                                colorFilter: const ColorFilter.mode(Colors.black, BlendMode.saturation),
                                                child: _getMoodIcon(record.mood, size: 14, color: Colors.white),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  else
                                    Text(
                                      log.mood,
                                      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Content (Activities, Notes, Media)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              // Activities
                              Consumer(
                                builder: (context, ref, _) {
                                   final settingsRepo = ref.watch(settingsRepositoryProvider);
                                   final names = log.activityItemIds
                                        .map((id) => settingsRepo.getItem(id)?.name ?? 'Unknown')
                                        .join(', ');
                                   if (names.isEmpty) return const SizedBox();
                                   return Padding(
                                     padding: const EdgeInsets.only(bottom: 4.0),
                                     child: Text(names, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
                                   );
                                }
                             ),

                             // Notes
                             if (log.notes != null && log.notes!.isNotEmpty)
                               Padding(
                                 padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                                 child: Text(
                                   log.notes!, 
                                   maxLines: 3, 
                                   overflow: TextOverflow.ellipsis,
                                   style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
                                 ),
                               ),

                             // Grayscale Media
                             if (log.mediaPaths.isNotEmpty)
                               Padding(
                                 padding: const EdgeInsets.only(bottom: 8.0),
                                 child: SizedBox(
                                   height: 120,
                                   child: ListView(
                                     scrollDirection: Axis.horizontal,
                                     children: log.mediaPaths.map((path) {
                                       return Padding(
                                         padding: const EdgeInsets.only(right: 8.0),
                                         child: ColorFiltered(
                                           colorFilter: const ColorFilter.matrix(<double>[
                                             0.2126, 0.7152, 0.0722, 0, 0,
                                             0.2126, 0.7152, 0.0722, 0, 0,
                                             0.2126, 0.7152, 0.0722, 0, 0,
                                             0,      0,      0,      1, 0,
                                           ]),
                                           child: ClipRRect(
                                              borderRadius: BorderRadius.zero,
                                              child: Image.file(File(path), width: 120, height: 120, fit: BoxFit.cover),
                                           ),
                                         ),
                                       );
                                     }).toList(),
                                   ),
                                 ),
                               ),
                               
                             // Audio
                             if (log.audioPaths.isNotEmpty)
                               Padding(
                                 padding: const EdgeInsets.only(bottom: 8.0),
                                 child: Column(
                                   children: log.audioPaths.map((path) => 
                                     Padding(
                                       padding: const EdgeInsets.only(bottom: 4.0),
                                       child: AudioPlayerWidget(audioPath: path, isMinimalist: true),
                                     )
                                   ).toList(),
                                 ),
                               ),
                           ],
                         ),
                       ),
                       const Divider(height: 1, color: Colors.white24), // Separator
                     ],
                   ),
                 );
              }

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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 24,
                              child: _getMoodIcon(log.mood, size: 36),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(log.date),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  if (log.moodHistory.isNotEmpty && log.moodHistory.length > 1)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: log.moodHistory.map((record) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                DateFormat.Hm().format(record.timestamp),
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              ),
                                              const SizedBox(width: 2),
                                              _getMoodIcon(record.mood, size: 14),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  else
                                    Text(
                                      log.mood,
                                      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
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
                        SizedBox(
                          height: 200,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: log.mediaPaths.map((path) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(path),
                                    fit: BoxFit.cover,
                                    width: 200,
                                    height: 200,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
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
  Widget _getMoodIcon(String mood, {double size = 24, Color? color}) {
    Color iconColor;
    if (color != null) {
      iconColor = color;
    } else {
      switch (mood) {
        case 'Rad':
          iconColor = Colors.green;
          break;
        case 'Good':
          iconColor = Colors.lightGreen;
          break;
        case 'Meh':
          iconColor = Colors.grey;
          break;
        case 'Bad':
          iconColor = Colors.orange;
          break;
        case 'Awful':
          iconColor = Colors.red;
          break;
        default:
          iconColor = Colors.grey;
      }
    }

    switch (mood) {
      case 'Rad':
        return Icon(Icons.sentiment_very_satisfied, color: iconColor, size: size);
      case 'Good':
        return Icon(Icons.sentiment_satisfied, color: iconColor, size: size);
      case 'Meh':
        return Icon(Icons.sentiment_neutral, color: iconColor, size: size);
      case 'Bad':
        return Icon(Icons.sentiment_dissatisfied, color: iconColor, size: size);
      case 'Awful':
        return Icon(Icons.sentiment_very_dissatisfied, color: iconColor, size: size);
      default:
        return Icon(Icons.help_outline, color: iconColor, size: size);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Hoje';
    } else if (checkDate == yesterday) {
      return 'Ontem';
    } else {
      return DateFormat('EEEE, d MMM').format(date);
    }
  }
}
