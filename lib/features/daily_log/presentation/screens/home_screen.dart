import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/daily_log/data/models/daily_log_model.dart';
import '../../../../features/settings/data/models/activity_category_model.dart';
import '../../../../features/settings/data/models/activity_item_model.dart';
import '../../../../features/settings/presentation/providers/settings_provider.dart';
import '../providers/daily_log_provider.dart';
import 'add_daily_log_screen.dart';
import '../widgets/audio_player_widget.dart';
import '../../../dashboard/data/services/stats_service.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/log_header.dart';
import '../widgets/log_media_grid.dart';
import 'package:good_day/core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyLogsAsync = ref.watch(dailyLogsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GoodDay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: dailyLogsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('Nenhum registro ainda. Adicione um!'));
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
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDailyLogScreen()),
          );

          if (result is int && result >= 2 && context.mounted) {
             final streak = result;
             // Show toast
             showDialog(
                context: context,
                barrierDismissible: false,
                barrierColor: Colors.transparent,
                builder: (ctx) {
                  Future.delayed(const Duration(seconds: 2), () {
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  });
                  
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    alignment: Alignment.bottomCenter,
                    insetPadding: const EdgeInsets.only(bottom: 80),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department, color: AppTheme.pastelGreen, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            '$streak dias seguidos!', 
                            style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),
                  );
                },
             );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
