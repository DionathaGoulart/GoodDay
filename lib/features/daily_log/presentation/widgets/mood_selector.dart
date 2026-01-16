import 'package:flutter/material.dart';
import 'package:good_day/core/theme/app_theme.dart';

class MoodSelector extends StatelessWidget {
  final String selectedMood;
  final ValueChanged<String> onSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onSelected,
  });

  final List<Map<String, dynamic>> _moods = const [
    {'label': 'Feliz', 'icon': Icons.sentiment_very_satisfied, 'color': AppTheme.pastelGreen},
    {'label': 'Bom', 'icon': Icons.sentiment_satisfied, 'color': AppTheme.pastelBlue},
    {'label': 'Neutro', 'icon': Icons.sentiment_neutral, 'color': AppTheme.pastelPurple},
    {'label': 'Triste', 'icon': Icons.sentiment_dissatisfied, 'color': AppTheme.pastelOrange},
    {'label': 'Terrível', 'icon': Icons.sentiment_very_dissatisfied, 'color': AppTheme.pastelPink},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _moods.map((mood) {
        final isSelected = mood['label'] == selectedMood;
        return GestureDetector(
          onTap: () => onSelected(mood['label']),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? mood['color'] : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: mood['color'],
                    width: 2,
                  ),
                ),
                child: Icon(
                  mood['icon'],
                  color: isSelected ? Colors.white : mood['color'],
                  size: 32,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mood['label'],
                style: TextStyle(
                  color: isSelected ? mood['color'] : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
