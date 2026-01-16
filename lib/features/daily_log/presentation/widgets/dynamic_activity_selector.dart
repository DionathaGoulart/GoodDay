import 'package:flutter/material.dart';
import 'package:good_day/features/settings/data/models/activity_category_model.dart';
import 'package:good_day/features/settings/data/models/activity_item_model.dart';
import 'package:good_day/core/theme/app_theme.dart';

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
              padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
              child: Row(
                children: [
                  if (category.emoji != null && category.emoji!.isNotEmpty)
                    Text(category.emoji!, style: const TextStyle(fontSize: 18))
                  else
                    Icon(IconData(category.iconCode, fontFamily: 'MaterialIcons'), 
                         color: Color(category.colorValue), size: 18),
                  const SizedBox(width: 8),
                  Text(category.name, 
                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

                return GestureDetector(
                  onTap: () => _toggleItem(item.id),
                  child: Container(
                    width: 70, 
                    height: 70,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(category.colorValue) : AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected ? null : Border.all(color: Colors.grey[800]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        iconWidget,
                         const SizedBox(height: 6),
                         Text(
                           item.name, 
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             color: isSelected ? Colors.black : Colors.grey[400],
                             fontSize: 11,
                             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                           ),
                           maxLines: 2,
                           overflow: TextOverflow.ellipsis,
                         )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }
}
