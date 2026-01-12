import 'package:hive/hive.dart';
import '../models/daily_log_model.dart';

class DailyLogRepository {
  final Box<DailyLog> _box;

  DailyLogRepository(this._box);

  List<DailyLog> getLogs() {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addLog(DailyLog newLog) async {
    // Check for existing log on the same day
    final existingLogIndex = _box.values.toList().indexWhere((log) => 
      log.date.year == newLog.date.year && 
      log.date.month == newLog.date.month && 
      log.date.day == newLog.date.day
    );

    if (existingLogIndex != -1) {
      final existingLog = _box.values.elementAt(existingLogIndex);
      
      // If we are editing the SAME log (same UUID), just overwrite.
      if (existingLog.id == newLog.id) {
         await _box.put(newLog.id, newLog);
         return;
      }

      final mergedActivities = <String>{...existingLog.activityItemIds, ...newLog.activityItemIds}.toList();
      final mergedMedia = <String>{...existingLog.mediaPaths, ...newLog.mediaPaths}.toList();
      final mergedAudio = <String>{...existingLog.audioPaths, ...newLog.audioPaths}.toList(); // NEW: Merge Audio
      
      String mergedNotes = existingLog.notes ?? '';
      if (newLog.notes != null && newLog.notes!.isNotEmpty) {
        if (mergedNotes.isNotEmpty) mergedNotes += '\n\n';
        mergedNotes += newLog.notes!;
      }

      // Merge Mood History
      final mergedHistory = List<MoodRecord>.from(existingLog.moodHistory);
      // Add existing main mood if not in history
      if (mergedHistory.isEmpty) {
        mergedHistory.add(MoodRecord(mood: existingLog.mood, timestamp: existingLog.date));
      }
      mergedHistory.add(MoodRecord(mood: newLog.mood, timestamp: newLog.date));

      final mergedLog = DailyLog(
        id: existingLog.id, // Keep original ID
        date: existingLog.date,
        mood: _calculateAverageMood(mergedHistory), // Calculate average mood
        weather: newLog.weather ?? existingLog.weather,
        activityItemIds: mergedActivities,
        food: newLog.food != null && newLog.food!.isNotEmpty ? '${existingLog.food ?? ""}\n${newLog.food}' : existingLog.food,
        notes: mergedNotes,
        mediaPaths: mergedMedia,
        moodHistory: mergedHistory,
        audioPaths: mergedAudio, // NEW
      );

      await _box.put(existingLog.id, mergedLog);
    } else {
      // New Log
      // Create mutable history list
      final history = List<MoodRecord>.from(newLog.moodHistory);
      
      if (history.isEmpty) {
         history.add(MoodRecord(mood: newLog.mood, timestamp: newLog.date));
      }
      
      // Create a new DailyLog instance with the mutable history since the original might have immutable fields/defaults
      final logToSave = DailyLog(
        id: newLog.id,
        date: newLog.date,
        mood: _calculateAverageMood(history), // Ensure initial mood matches average (trivial for 1 item)
        weather: newLog.weather,
        activityItemIds: newLog.activityItemIds,
        food: newLog.food,
        notes: newLog.notes,
        mediaPaths: newLog.mediaPaths,
        moodHistory: history,
        audioPaths: newLog.audioPaths, // NEW
      );

      await _box.put(logToSave.id, logToSave);
    }
  }

  String _calculateAverageMood(List<MoodRecord> history) {
    if (history.isEmpty) return 'Meh';

    int totalScore = 0;
    for (var record in history) {
      totalScore += _getMoodScore(record.mood);
    }

    final double average = totalScore / history.length;
    final int roundedScore = average.round();

    return _getMoodFromScore(roundedScore);
  }

  int _getMoodScore(String mood) {
    switch (mood) {
      case 'Rad': return 5;
      case 'Good': return 4;
      case 'Meh': return 3;
      case 'Bad': return 2;
      case 'Awful': return 1;
      default: return 3; // Default to Meh
    }
  }

  String _getMoodFromScore(int score) {
    if (score >= 5) return 'Rad';
    if (score == 4) return 'Good';
    if (score == 3) return 'Meh';
    if (score == 2) return 'Bad';
    return 'Awful';
  }

  Future<void> deleteLog(String id) async {
    await _box.delete(id);
  }
}
