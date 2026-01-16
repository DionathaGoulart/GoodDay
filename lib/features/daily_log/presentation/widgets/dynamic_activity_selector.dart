import 'package:flutter/material.dart';
import 'package:good_day/features/settings/data/models/activity_category_model.dart';
import 'package:good_day/features/settings/data/models/activity_item_model.dart';

class DynamicActivitySelector extends StatelessWidget {
  final Map<ActivityCategory, List<ActivityItem>> categoryItems;
  final List<String> selectedItemIds;
  final ValueChanged<List<String>> onChanged;

  const DynamicActivitySelector({
    super.key,
    required this.categoryItems,
    required this.selectedItemIds,
    required this.onChanged,
  });

  void _toggleItem(String itemId) {
    if (selectedItemIds.contains(itemId)) {
      onChanged(selectedItemIds.where((id) => id != itemId).toList());
    } else {
      onChanged([...selectedItemIds, itemId]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (categoryItems.isEmpty) return const SizedBox();

    return Column(
      children: categoryItems.entries.map((entry) {
        final category = entry.key;
        final items = entry.value;

        if (items.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  if (category.emoji != null && category.emoji!.isNotEmpty)
                    Text(category.emoji!, style: const TextStyle(fontSize: 18))
                  else
                    Icon(IconData(category.iconCode, fontFamily: 'MaterialIcons'), 
                         color: Color(category.colorValue), size: 18),
                  const SizedBox(width: 8),
                  Text(category.name, 
                       style: TextStyle(color: Color(category.colorValue), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            // Default: Chips
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: items.map((item) {
                final isSelected = selectedItemIds.contains(item.id);
                
                Widget iconWidget;
                if (item.emoji != null && item.emoji!.isNotEmpty) {
                  iconWidget = Text(item.emoji!, style: const TextStyle(fontSize: 16));
                } else {
                    final itemIcon = item.iconCode != null 
                      ? IconData(item.iconCode!, fontFamily: 'MaterialIcons') 
                      : IconData(category.iconCode, fontFamily: 'MaterialIcons');
                    iconWidget = Icon(
                      itemIcon,
                      color: isSelected ? Colors.white : Colors.grey[700],
                      size: 20,
                    );
                }

                return FilterChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      iconWidget,
                      const SizedBox(height: 4),
                      Text(
                        item.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => _toggleItem(item.id),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  backgroundColor: Colors.grey[200],
                  selectedColor: Color(category.colorValue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : Colors.grey[300]!,
                    ),
                  ),
                );
              }).toList(),
            ),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }
}
