import 'package:flutter/material.dart';

class ActivitySelector extends StatelessWidget {
  final List<String> selectedActivities;
  final ValueChanged<List<String>> onChanged;

  const ActivitySelector({
    super.key,
    required this.selectedActivities,
    required this.onChanged,
  });

  final List<Map<String, dynamic>> _activities = const [
    {'label': 'Work', 'icon': Icons.work},
    {'label': 'Study', 'icon': Icons.school},
    {'label': 'Relax', 'icon': Icons.weekend},
    {'label': 'Friends', 'icon': Icons.people},
    {'label': 'Family', 'icon': Icons.family_restroom},
    {'label': 'Sport', 'icon': Icons.fitness_center},
    {'label': 'Movie', 'icon': Icons.movie},
    {'label': 'Gaming', 'icon': Icons.videogame_asset},
    {'label': 'Reading', 'icon': Icons.book},
    {'label': 'Shopping', 'icon': Icons.shopping_cart},
    {'label': 'Cleaning', 'icon': Icons.cleaning_services},
    {'label': 'Travel', 'icon': Icons.flight},
  ];

  void _toggleActivity(String label) {
    if (selectedActivities.contains(label)) {
      onChanged(selectedActivities.where((a) => a != label).toList());
    } else {
      onChanged([...selectedActivities, label]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _activities.map((activity) {
        final isSelected = selectedActivities.contains(activity['label']);
        return FilterChip(
          label: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                activity['icon'],
                color: isSelected ? Colors.white : Colors.grey[700],
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                activity['label'],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => _toggleActivity(activity['label']),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          backgroundColor: Colors.grey[200],
          selectedColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.grey[300]!,
            ),
          ),
        );
      }).toList(),
    );
  }
}
