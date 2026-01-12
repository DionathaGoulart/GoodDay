import 'package:hive/hive.dart';

part 'activity_category_model.g.dart';

@HiveType(typeId: 1)
class ActivityCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int iconCode; // Store IconData.codePoint

  @HiveField(3)
  final int colorValue; // Store Color.value

  @HiveField(4)
  final String? emoji; // NEW

  ActivityCategory({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.emoji,
  });
}
