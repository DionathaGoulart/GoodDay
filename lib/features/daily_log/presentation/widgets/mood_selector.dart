import 'package:flutter/material.dart';

class MoodSelector extends StatelessWidget {
  final String selectedMood;
  final ValueChanged<String> onSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onSelected,
  });

  final List<Map<String, dynamic>> _moods = const [
    {'label': 'Rad', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.green},
    {'label': 'Good', 'icon': Icons.sentiment_satisfied, 'color': Colors.lightGreen},
    {'label': 'Meh', 'icon': Icons.sentiment_neutral, 'color': Colors.grey},
    {'label': 'Bad', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.orange},
    {'label': 'Awful', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.red},
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
