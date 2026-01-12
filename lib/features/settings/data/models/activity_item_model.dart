import 'package:hive/hive.dart';

part 'activity_item_model.g.dart';

@HiveType(typeId: 2)
class ActivityItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String categoryId;

  @HiveField(3)
  final int? iconCode; // Optional specific icon, otherwise use category icon

  @HiveField(4)
  final String? emoji; // NEW

  ActivityItem({
    required this.id,
    required this.name,
    required this.categoryId,
    this.iconCode,
    this.emoji,
  });
}
