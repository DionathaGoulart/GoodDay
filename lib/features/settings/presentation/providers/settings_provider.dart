import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/activity_category_model.dart';
import '../../data/models/activity_item_model.dart';
import '../../data/repositories/settings_repository.dart';

// Boxes
final categoryBoxProvider = Provider<Box<ActivityCategory>>((ref) => Hive.box<ActivityCategory>('activity_categories_v3'));
final itemBoxProvider = Provider<Box<ActivityItem>>((ref) => Hive.box<ActivityItem>('activity_items_v3'));
final settingsBoxProvider = Provider<Box>((ref) => Hive.box('settings_v3'));

// Repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    ref.watch(categoryBoxProvider),
    ref.watch(itemBoxProvider),
  );
});

// Categories Provider
final categoriesProvider = FutureProvider<List<ActivityCategory>>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  // Ensure defaults exist

  return repo.getCategories();
});

// Items Provider Family
final itemsProvider = FutureProvider.family<List<ActivityItem>, String>((ref, categoryId) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getItems(categoryId);
});


