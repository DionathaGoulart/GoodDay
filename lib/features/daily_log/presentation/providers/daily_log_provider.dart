import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/daily_log_model.dart';
import '../../data/repositories/daily_log_repository.dart';

// Box Provider
final dailyLogsBoxProvider = Provider<Box<DailyLog>>((ref) {
  return Hive.box<DailyLog>('daily_logs_v3');
});

// Repository Provider
final dailyLogRepositoryProvider = Provider<DailyLogRepository>((ref) {
  final box = ref.watch(dailyLogsBoxProvider);
  return DailyLogRepository(box);
});

// Controller
class DailyLogsController extends AsyncNotifier<List<DailyLog>> {
  @override
  List<DailyLog> build() {
    return ref.read(dailyLogRepositoryProvider).getLogs();
  }

  Future<void> addLog(DailyLog log) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(dailyLogRepositoryProvider).addLog(log);
      return ref.read(dailyLogRepositoryProvider).getLogs();
    });
  }

  Future<void> deleteLog(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(dailyLogRepositoryProvider).deleteLog(id);
      return ref.read(dailyLogRepositoryProvider).getLogs();
    });
  }
}

final dailyLogsControllerProvider = AsyncNotifierProvider<DailyLogsController, List<DailyLog>>(() {
  return DailyLogsController();
});
