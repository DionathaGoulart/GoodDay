import 'package:hive/hive.dart';

part 'daily_log_model.g.dart';

@HiveType(typeId: 0)
class DailyLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String mood;

  @HiveField(3)
  final String? weather;

  @HiveField(4)
  final List<String> activityItemIds;

  @HiveField(5)
  final String? food; // Keeping for legacy/simple text, but could also be an activity item

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final List<String> mediaPaths;

  @HiveField(8)
  final List<MoodRecord> moodHistory;


  @HiveField(9)
  final List<String> audioPaths;

  DailyLog({
    required this.id,
    required this.date,
    required this.mood,
    this.weather,
    required this.activityItemIds,
    this.food,
    this.notes,
    this.mediaPaths = const [],
    this.moodHistory = const [],
    this.audioPaths = const [],
  });
}

@HiveType(typeId: 3)
class MoodRecord extends HiveObject {
  @HiveField(0)
  final String mood;

  @HiveField(1)
  final DateTime timestamp;

  MoodRecord({required this.mood, required this.timestamp});
}
