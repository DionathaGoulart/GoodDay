import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:good_day/features/daily_log/data/models/daily_log_model.dart';
import 'package:good_day/features/settings/data/models/activity_category_model.dart';
import 'package:good_day/features/settings/data/models/activity_item_model.dart';

// ... imports
import 'google_drive_service.dart';

class BackupService {
  final GoogleDriveService _driveService;

  BackupService(this._driveService);

  // ... openSystemBackupSettings (keep existing)

  // System Backup Check ...
  Future<void> openSystemBackupSettings(BuildContext context) async {
    // ... existing logic ...
    if (Platform.isAndroid) {
        try {
           final intent = AndroidIntent(
             action: 'com.google.android.gms.backup.component.BackupSettingsActivity',
             flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
           );
           await intent.launch();
        } catch (_) {
           try {
             final intentIntent = AndroidIntent(
               action: 'android.settings.SETTINGS',
               flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
             );
             await intentIntent.launch();
           } catch (e) {
               if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open settings.')));
               }
           }
        }
    } else {
       if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('System backup check is for Android only.')));
       }
    }
  }

  // --- Manual Export ---
  Future<void> exportData(BuildContext context) async {
    try {
      final file = await _generateBackupFile();
      await Share.shareXFiles([XFile(file.path)], text: 'Good Day Backup');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export Failed: $e')));
      }
    }
  }

  // --- Manual Import ---
  Future<void> importData(BuildContext context) async {
     try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await _restoreFromFile(context, file);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import Failed: $e')));
      }
    }
  }

  // --- Google Drive Logic ---
  
  Future<void> connectToDrive(BuildContext context) async {
      await _driveService.signIn();
  }
  
  Future<void> disconnectDrive() async {
      await _driveService.signOut();
  }

  Future<void> backupToDrive(BuildContext context) async {
    try {
      if (_driveService.currentUser == null) await _driveService.signIn();
      if (_driveService.currentUser == null) return; // Users cancelled

      final file = await _generateBackupFile();
      await _driveService.uploadBackup(file);
      
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup uploaded to Google Drive!')));
      }
    } catch (e) {
       if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Drive Backup Failed: $e')));
       }
    }
  }

  Future<void> restoreFromDrive(BuildContext context) async {
    try {
      if (_driveService.currentUser == null) await _driveService.signIn();
      if (_driveService.currentUser == null) return;

      final metadata = await _driveService.getLatestBackupMetadata();
      if (metadata == null) {
          if (context.mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No backup found in Drive app folder.')));
          }
          return;
      }

      final directory = await getTemporaryDirectory();
      final targetFile = File('${directory.path}/restored_backup.json');
      await _driveService.downloadBackup(metadata.id!, targetFile);
      
      await _restoreFromFile(context, targetFile);

    } catch (e) {
       if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Drive Restore Failed: $e')));
       }
    }
  }
  
  // Helpers
  
  Future<File> _generateBackupFile() async {
      final dailyLogsBox = Hive.box<DailyLog>('daily_logs_v3');
      final categoriesBox = Hive.box<ActivityCategory>('activity_categories_v3');
      final itemsBox = Hive.box<ActivityItem>('activity_items_v3');
      final settingsBox = Hive.box('settings_v3');

      final Map<String, dynamic> backupData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'dailyLogs': dailyLogsBox.values.map((e) => _dailyLogToJson(e)).toList(),
        'categories': categoriesBox.values.map((e) => _categoryToJson(e)).toList(),
        'items': itemsBox.values.map((e) => _itemToJson(e)).toList(),
        'settings': settingsBox.toMap().map((key, value) => MapEntry(key.toString(), value)),
      };

      final jsonString = jsonEncode(backupData);
      final directory = await getTemporaryDirectory();
      final dateStr = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final file = File('${directory.path}/good_day_backup_$dateStr.json');
      await file.writeAsString(jsonString);
      return file;
  }

  Future<void> _restoreFromFile(BuildContext context, File file) async {
        final jsonString = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(jsonString);

        if (data['version'] != 1) throw Exception("Unknown backup version");

        final dailyLogsBox = Hive.box<DailyLog>('daily_logs_v3');
        final categoriesBox = Hive.box<ActivityCategory>('activity_categories_v3');
        final itemsBox = Hive.box<ActivityItem>('activity_items_v3');
        final settingsBox = Hive.box('settings_v3');

        await dailyLogsBox.clear();
        final logs = (data['dailyLogs'] as List).map((e) => _jsonToDailyLog(e)).toList();
        for (var log in logs) {
          await dailyLogsBox.put(log.id, log);
        }

        await categoriesBox.clear();
        final categories = (data['categories'] as List).map((e) => _jsonToCategory(e)).toList();
        for (var cat in categories) {
          await categoriesBox.put(cat.id, cat);
        }

        await itemsBox.clear();
        final items = (data['items'] as List).map((e) => _jsonToItem(e)).toList();
        for (var item in items) {
          await itemsBox.put(item.id, item);
        }

        await settingsBox.clear();
        final settings = data['settings'] as Map<String, dynamic>;
        await settingsBox.putAll(settings);

        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Restore Successful! Please restart app if needed.')),
           );
        }
  }

  // --- Json Helpers (Keep existing _dailyLogToJson etc) ---
  Map<String, dynamic> _dailyLogToJson(DailyLog log) {
    return {
      'id': log.id,
      'date': log.date.toIso8601String(),
      'mood': log.mood,
      'weather': log.weather,
      'activityItemIds': log.activityItemIds,
      'food': log.food,
      'notes': log.notes,
      'mediaPaths': log.mediaPaths, 
      'audioPaths': log.audioPaths,
      'moodHistory': log.moodHistory.map((m) => {'mood': m.mood, 'timestamp': m.timestamp.toIso8601String()}).toList(),
    };
  }

  DailyLog _jsonToDailyLog(Map<String, dynamic> json) {
    return DailyLog(
      id: json['id'],
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      weather: json['weather'],
      activityItemIds: List<String>.from(json['activityItemIds'] ?? []),
      food: json['food'],
      notes: json['notes'],
      mediaPaths: List<String>.from(json['mediaPaths'] ?? []),
      audioPaths: List<String>.from(json['audioPaths'] ?? []),
      moodHistory: (json['moodHistory'] as List).map((m) => MoodRecord(
         mood: m['mood'],
         timestamp: DateTime.parse(m['timestamp']),
      )).toList(),
    );
  }

    Map<String, dynamic> _categoryToJson(ActivityCategory cat) {
    return {
      'id': cat.id,
      'name': cat.name,
      'iconCode': cat.iconCode,
      'colorValue': cat.colorValue,
      'emoji': cat.emoji,
    };
  }

  ActivityCategory _jsonToCategory(Map<String, dynamic> json) {
    return ActivityCategory(
      id: json['id'],
      name: json['name'],
      iconCode: json['iconCode'],
      colorValue: json['colorValue'],
      emoji: json['emoji'],
    );
  }

  Map<String, dynamic> _itemToJson(ActivityItem item) {
    return {
      'id': item.id,
      'name': item.name,
      'categoryId': item.categoryId,
      'iconCode': item.iconCode,
      'emoji': item.emoji,
    };
  }

  ActivityItem _jsonToItem(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'],
      name: json['name'],
      categoryId: json['categoryId'],
      iconCode: json['iconCode'],
      emoji: json['emoji'],
    );
  }
}

final googleDriveServiceProvider = Provider<GoogleDriveService>((ref) {
  return GoogleDriveService();
});

final backupServiceProvider = Provider<BackupService>((ref) {
  final driveService = ref.watch(googleDriveServiceProvider);
  return BackupService(driveService);
});
