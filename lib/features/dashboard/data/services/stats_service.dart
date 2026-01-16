import 'package:good_day/features/daily_log/data/models/daily_log_model.dart';
import 'package:intl/intl.dart';

class StatsService {
  
  // --- Helpers ---
  int moodToScore(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': 
      case 'feliz': return 5;
      case 'good': 
      case 'bom': return 4;
      case 'neutral': 
      case 'neutro': return 3;
      case 'sad': 
      case 'triste': return 2;
      case 'terrible': 
      case 'terrível': return 1;
      default: return 3;
    }
  }

  // --- Streaks ---
  int calculateCurrentStreak(List<DailyLog> logs) {
    if (logs.isEmpty) return 0;

    // Sort descending (newest first)
    final sorted = List<DailyLog>.from(logs)..sort((a, b) => b.date.compareTo(a.date));
    
    // Check if today or yesterday has a log
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Normalize to dates only
    bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

    if (!isSameDay(sorted.first.date, today) && !isSameDay(sorted.first.date, yesterday)) {
      return 0; // Streak broken if no log today AND no log yesterday
    }

    int streak = 0;
    DateTime lastDate = today;

    // If latest log is today, start counting from today. If it's yesterday, start there.
    // Actually, simple algorithm:
    // Iterate unique dates backwards.
    // 1. Get unique dates sorted descending
    final uniqueDates = sorted.map((l) => DateTime(l.date.year, l.date.month, l.date.day)).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    if (uniqueDates.isEmpty) return 0;
    
    // If the most recent log is not today or yesterday, streak is 0
    if (!isSameDay(uniqueDates.first, today) && !isSameDay(uniqueDates.first, yesterday)) {
        return 0;
    }

    DateTime current = uniqueDates.first;
    streak = 1;

    for (int i = 1; i < uniqueDates.length; i++) {
       final prev = uniqueDates[i];
       final diff = current.difference(prev).inDays;
       if (diff == 1) {
         streak++;
         current = prev;
       } else {
         break;
       }
    }
    return streak;
  }

  int calculateLongestHappyStreak(List<DailyLog> logs) {
      if (logs.isEmpty) return 0;
      
       // Sort ascending
      final sorted = List<DailyLog>.from(logs)..sort((a, b) => a.date.compareTo(b.date));

      int maxStreak = 0;
      int currentStreak = 0;
      
      // Filter distinct dates to avoid double counting same day
      final uniqueLogs = <String, DailyLog>{};
      for(var log in sorted) {
          final key = "${log.date.year}-${log.date.month}-${log.date.day}";
          // If multiple logs per day, maybe take the "best" mood? Or just if ANY is happy?
          // Let's assume we take the best mood score of the day
          if (!uniqueLogs.containsKey(key)) {
             uniqueLogs[key] = log;
          } else {
             if (moodToScore(log.mood) > moodToScore(uniqueLogs[key]!.mood)) {
                uniqueLogs[key] = log;
             }
          }
      }
      
      final dateKeys = uniqueLogs.keys.toList()..sort();
      
      if (dateKeys.isEmpty) return 0;
      
      DateTime? lastDate;

      for (var key in dateKeys) {
          final log = uniqueLogs[key]!;
          final date = DateTime(log.date.year, log.date.month, log.date.day);
          final isHappy = moodToScore(log.mood) >= 4; // Good or Happy

          if (isHappy) {
             if (lastDate == null) {
                currentStreak = 1;
             } else {
                final diff = date.difference(lastDate).inDays;
                if (diff == 1) {
                   currentStreak++;
                } else {
                   currentStreak = 1; // Restart streak
                }
             }
             lastDate = date;
          } else {
             currentStreak = 0;
             lastDate = null;
          }
          
          if (currentStreak > maxStreak) maxStreak = currentStreak;
      }
      return maxStreak;
  }

  // --- Averages ---
  double calculateAverageMood(List<DailyLog> logs) {
    if (logs.isEmpty) return 0;
    final total = logs.fold(0, (sum, log) => sum + moodToScore(log.mood));
    return total / logs.length;
  }

  Map<int, double> calculateMonthlyAverages(List<DailyLog> logs, int year) {
    // Returns Map<MonthIndex 1-12, AverageScore>
    final yearLogs = logs.where((l) => l.date.year == year).toList();
    final monthlySums = <int, int>{};
    final monthlyCounts = <int, int>{};

    for (var log in yearLogs) {
       monthlySums[log.date.month] = (monthlySums[log.date.month] ?? 0) + moodToScore(log.mood);
       monthlyCounts[log.date.month] = (monthlyCounts[log.date.month] ?? 0) + 1;
    }

    final averages = <int, double>{};
    for (int i = 1; i <= 12; i++) {
       if (monthlyCounts.containsKey(i)) {
         averages[i] = monthlySums[i]! / monthlyCounts[i]!;
       } else {
         averages[i] = 0.0;
       }
    }
    return averages;
  }
  
  Map<int, double> calculateDayOfWeekAverages(List<DailyLog> logs) {
     final sums = <int, int>{}; // 1 = Monday, 7 = Sunday
     final counts = <int, int>{};

     for (var log in logs) {
        final weekday = log.date.weekday;
        sums[weekday] = (sums[weekday] ?? 0) + moodToScore(log.mood);
        counts[weekday] = (counts[weekday] ?? 0) + 1;
     }
     
     final averages = <int, double>{};
     for (int i = 1; i <= 7; i++) {
        if (counts.containsKey(i)) {
           averages[i] = sums[i]! / counts[i]!;
        } else {
           averages[i] = 0.0;
        }
     }
     return averages;
  }

  // --- Counts ---
  Map<String, int> calculateActivityCounts(List<DailyLog> logs, {int? year}) {
      final relevantLogs = year != null ? logs.where((l) => l.date.year == year).toList() : logs;
      
      final counts = <String, int>{};
      for (var log in relevantLogs) {
         for (var activityId in log.activityItemIds) {
            counts[activityId] = (counts[activityId] ?? 0) + 1;
         }
      }
      return counts;
  }

  Map<String, int> calculateMoodCounts(List<DailyLog> logs, {int? year}) {
     final relevantLogs = year != null ? logs.where((l) => l.date.year == year).toList() : logs;
     final counts = <String, int>{};
      for (var log in relevantLogs) {
         counts[log.mood] = (counts[log.mood] ?? 0) + 1;
      }
      return counts;
  }

  // --- Year in Pixels Data ---
  // returns Map<DateTime (normalized), int Score>
  Map<DateTime, int> getYearInPixelsData(List<DailyLog> logs, int year) {
      final yearLogs = logs.where((l) => l.date.year == year).toList();
      final data = <DateTime, int>{};
      
      // If multiple logs on same day, use average? Or max? Let's use Average rounded.
      final dayScores = <DateTime, List<int>>{};
      
      for(var log in yearLogs) {
          final date = DateTime(log.date.year, log.date.month, log.date.day);
          if (dayScores[date] == null) dayScores[date] = [];
          dayScores[date]!.add(moodToScore(log.mood));
      }

      dayScores.forEach((date, scores) {
          final avg = scores.reduce((a, b) => a + b) / scores.length;
          data[date] = avg.round();
      });
      
      return data;
  }
}
