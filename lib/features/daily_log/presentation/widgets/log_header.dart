import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/daily_log_model.dart';

class LogHeader extends StatelessWidget {
  final DailyLog log;

  const LogHeader({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mood Icon
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
                // Date
                Text(
                  _formatDate(log.date),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                // Timeline or Mood Text
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
    );
  }

  Widget _getMoodIcon(String mood, {double size = 24}) {
    Color iconColor;
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

