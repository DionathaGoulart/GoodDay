import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_day/features/settings/data/models/activity_category_model.dart';
import 'package:good_day/features/settings/data/models/activity_item_model.dart';
import 'package:good_day/features/settings/presentation/providers/settings_provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_iconpicker_plus/flutter_iconpicker.dart';
import '../../data/services/backup_service.dart';
import '../../data/services/google_drive_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ManageActivitiesScreen extends ConsumerWidget {
  const ManageActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Activities')),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No categories properly loaded.'));
          }
          return ListView(
            children: [
              // Global Settings

// ... imports
import '../../data/services/google_drive_service.dart';

// ... 

              // Cloud Backup (Google Drive)
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Backup & Restore', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              
              // Google Drive Status
              Consumer(builder: (context, ref, _) {
                 // Watch logic: we need to know if signed in. 
                 // Simple way: check currentUser on service. To make it reactive, we might need a StateNotifier or just use FutureBuilder/Stream?
                 // Given simple Provider setup, let's use a FutureBuilder or assuming service notifies?
                 // The service uses google_sign_in stream. We can watch that stream.
                 final driveService = ref.watch(googleDriveServiceProvider);
                 
                 return StreamBuilder(
                   stream: GoogleSignIn().onCurrentUserChanged, // Hack: accessing static instance or service stream
                   builder: (context, snapshot) {
                     final user = snapshot.data; // or driveService.currentUser if initialized
                     final isSignedIn = user != null;

                     return Column(
                       children: [
                          ListTile(
                            leading: Icon(Icons.add_to_drive, color: isSignedIn ? Colors.blue : Colors.grey),
                            title: Text(isSignedIn ? 'Connected as ${user.email}' : 'Connect Google Drive'),
                            subtitle: const Text('Sync backup file to hidden app folder'),
                            trailing: Switch(
                              value: isSignedIn,
                              onChanged: (val) async {
                                 if (val) {
                                   await ref.read(backupServiceProvider).connectToDrive(context);
                                 } else {
                                   await ref.read(backupServiceProvider).disconnectDrive();
                                 }
                              },
                            ),
                          ),
                          if (isSignedIn) ...[
                             ListTile(
                               title: const Text('Backup to Drive now'),
                               leading: const Icon(Icons.cloud_upload),
                               onTap: () async {
                                  await ref.read(backupServiceProvider).backupToDrive(context);
                               },
                             ),
                             ListTile(
                               title: const Text('Restore from Drive'),
                               leading: const Icon(Icons.cloud_download),
                               onTap: () async {
                                  await ref.read(backupServiceProvider).restoreFromDrive(context);
                               },
                             ),
                          ]
                       ],
                     );
                   }
                 );
              }),

              const Divider(),
              ExpansionTile(
                title: const Text('Advanced / Manual'),
                children: [
                   ListTile(
                    title: const Text('Check Auto Backup Status'),
                    leading: const Icon(Icons.settings_backup_restore),
                    onTap: () async {
                       await ref.read(backupServiceProvider).openSystemBackupSettings(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Export JSON File'),
                    leading: const Icon(Icons.share),
                    onTap: () async {
                       await ref.read(backupServiceProvider).exportData(context);
                    },
                  ),
                   ListTile(
                    title: const Text('Import JSON File'),
                    leading: const Icon(Icons.file_open),
                    onTap: () async {
                       await ref.read(backupServiceProvider).importData(context);
                    },
                  ),
                ],
              ),
              // Categories List
              ...categories.map((category) => _CategoryTile(category: category)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}



// ... (previous imports)

// Helper methods to pick Emoji and Icon
Future<String?> _pickEmoji(BuildContext context) async {
  return showModalBottomSheet<String>(
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            Navigator.pop(context, emoji.emoji);
          },
          config: const Config(
            checkPlatformCompatibility: true,
            emojiViewConfig: EmojiViewConfig(
              columns: 7,
              emojiSizeMax: 32,
            ),
          ),
        ),
      );
    },
  );
}

Future<IconData?> _pickIcon(BuildContext context) async {
  return FlutterIconPicker.showIconPicker(
    context,
    iconPackModes: [IconPack.material],
  );
}

// Dialog Helpers (Top Level)

void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        title: 'New Category',
        onSave: (name, emoji, iconCode) async {
            await ref.read(settingsRepositoryProvider).addCategory(
              name,
              iconCode ?? Icons.category.codePoint, 
              Colors.blue.value,
              emoji: emoji,
            );
            ref.refresh(categoriesProvider);
        },
      ),
    );
}

void _showEditCategoryDialog(BuildContext context, WidgetRef ref, ActivityCategory category) {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        title: 'Edit Category',
        initialName: category.name,
        initialEmoji: category.emoji,
        initialIconCode: category.iconCode,
        onSave: (name, emoji, iconCode) async {
            await ref.read(settingsRepositoryProvider).updateCategory(
              category.id,
              name: name,
              iconCode: iconCode,
              emoji: emoji,
            );
            ref.refresh(categoriesProvider);
        },
      ),
    );
}

void _showAddItemDialog(BuildContext context, WidgetRef ref, String categoryId) {
     showDialog(
      context: context,
      builder: (context) => _ItemDialog(
        title: 'New Activity Item',
        onSave: (name, emoji, iconCode) async {
             await ref.read(settingsRepositoryProvider).addItem(
               name, 
               categoryId,
               emoji: emoji,
               iconCode: iconCode
             );
             ref.refresh(itemsProvider(categoryId));
        },
      ),
    );
}

void _showEditItemDialog(BuildContext context, WidgetRef ref, ActivityItem item) {
    showDialog(
      context: context,
      builder: (context) => _ItemDialog(
        title: 'Edit Item',
        initialName: item.name,
        initialEmoji: item.emoji,
        initialIconCode: item.iconCode,
        onSave: (name, emoji, iconCode) async {
             await ref.read(settingsRepositoryProvider).updateItem(
               item.id,
               name: name,
               emoji: emoji,
               iconCode: iconCode
             );
             ref.refresh(itemsProvider(item.categoryId));
        },
      ),
    );
}

// ... inside _showAddCategoryDialog, _showAddItemDialog, _showEditCategoryDialog, _showEditItemDialog
// We will replace the text field for emoji with a Row of buttons.

class _CategoryTile extends ConsumerWidget {
  final ActivityCategory category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider(category.id));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: category.emoji != null && category.emoji!.isNotEmpty
            ? Text(category.emoji!, style: const TextStyle(fontSize: 24))
            : Icon(
                IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                color: Color(category.colorValue),
              ),
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             IconButton(
               icon: const Icon(Icons.edit, color: Colors.blue),
               onPressed: () => _showEditCategoryDialog(context, ref, category),
             ),
          ],
        ),
        children: [
          itemsAsync.when(
            data: (items) => Column(
              children: [
                ...items.map((item) => ListTile(
                  leading: item.emoji != null && item.emoji!.isNotEmpty
                      ? Text(item.emoji!, style: const TextStyle(fontSize: 20))
                      : null,
                  title: Text(item.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                        onPressed: () => _showEditItemDialog(context, ref, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
                        onPressed: () {
                          ref.read(settingsRepositoryProvider).deleteItem(item.id);
                          ref.refresh(itemsProvider(category.id));
                        },
                      ),
                    ],
                  ),
                )),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Item'),
                  onTap: () => _showAddItemDialog(context, ref, category.id),
                ),
              ],
            ),
            loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
            error: (err, stack) => Padding(padding: const EdgeInsets.all(16), child: Text('Error: $err')),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                    onPressed: () async {
                        await ref.read(settingsRepositoryProvider).deleteCategory(category.id);
                        ref.refresh(categoriesProvider);
                    }, 
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text("Delete Category", style: TextStyle(color: Colors.red)),
                )
            ),
          )
        ],
      ),
    );
  }
}

// Reusable State widgets for Dialogs to handle the selection state

class _CategoryDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final String? initialEmoji;
  final int? initialIconCode;
  final Function(String name, String? emoji, int? iconCode) onSave;

  const _CategoryDialog({
    required this.title,
    required this.onSave,
    this.initialName,
    this.initialEmoji,
    this.initialIconCode,
  });

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late TextEditingController _nameController;
  String? _selectedEmoji;
  int? _selectedIconCode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedEmoji = widget.initialEmoji;
    _selectedIconCode = widget.initialIconCode;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Emoji Selector
              Column(
                children: [
                  const Text('Emoji', style: TextStyle(fontSize: 12)),
                  IconButton(
                    icon: Text(_selectedEmoji ?? '😀', style: const TextStyle(fontSize: 24)),
                    onPressed: () async {
                      final emoji = await showModalBottomSheet<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return EmojiPicker(
                            onEmojiSelected: (category, emoji) {
                              Navigator.pop(context, emoji.emoji);
                            },
                            config: const Config(
                              height: 300,
                              viewOrderConfig: ViewOrderConfig(
                                top: EmojiPickerItem.categoryBar,
                                middle: EmojiPickerItem.emojiView,
                                bottom: EmojiPickerItem.searchBar,
                              ),
                            ),
                          );
                        },
                      );
                      if (emoji != null) {
                        setState(() {
                             _selectedEmoji = emoji;
                             _selectedIconCode = null; // Prefer Emoji
                        });
                      }
                    },
                  ),
                ],
              ),
              const Text('OR'),
              // Icon Selector
              Column(
                children: [
                  const Text('Icon', style: TextStyle(fontSize: 12)),
                  IconButton(
                    icon: Icon(
                        _selectedIconCode != null 
                             ? IconData(_selectedIconCode!, fontFamily: 'MaterialIcons') 
                             : Icons.image, 
                        size: 24
                    ),
                    onPressed: () async {
                       final icon = await FlutterIconPicker.showIconPicker(
                          context,
                          iconPackModes: [IconPack.material],
                       );
                       if (icon != null) {
                          setState(() {
                             _selectedIconCode = icon.codePoint;
                             _selectedEmoji = null; // Prefer Icon
                          });
                       }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.onSave(_nameController.text, _selectedEmoji, _selectedIconCode);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ItemDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final String? initialEmoji;
  final int? initialIconCode;
  final Function(String name, String? emoji, int? iconCode) onSave;

  const _ItemDialog({
    required this.title,
    required this.onSave,
    this.initialName,
    this.initialEmoji,
    this.initialIconCode,
  });

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  late TextEditingController _nameController;
  String? _selectedEmoji;
  int? _selectedIconCode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedEmoji = widget.initialEmoji;
    _selectedIconCode = widget.initialIconCode;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Emoji Selector
              Column(
                children: [
                  const Text('Emoji', style: TextStyle(fontSize: 12)),
                  IconButton(
                    icon: Text(_selectedEmoji ?? '😀', style: const TextStyle(fontSize: 24)),
                    onPressed: () async {
                      final emoji = await showModalBottomSheet<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return EmojiPicker(
                            onEmojiSelected: (category, emoji) {
                              Navigator.pop(context, emoji.emoji);
                            },
                             config: const Config(
                              height: 300,
                              emojiViewConfig: EmojiViewConfig(
                                columns: 7, 
                                emojiSizeMax: 32,
                              ),
                            ),
                          );
                        },
                      );
                      if (emoji != null) {
                        setState(() {
                             _selectedEmoji = emoji;
                             _selectedIconCode = null;
                        });
                      }
                    },
                  ),
                ],
              ),
              const Text('OR'),
              // Icon Selector
              Column(
                children: [
                  const Text('Icon', style: TextStyle(fontSize: 12)),
                  IconButton(
                    icon: Icon(
                        _selectedIconCode != null 
                             ? IconData(_selectedIconCode!, fontFamily: 'MaterialIcons') 
                             : Icons.image, 
                        size: 24
                    ),
                    onPressed: () async {
                       final icon = await FlutterIconPicker.showIconPicker(
                          context,
                          iconPackModes: [IconPack.material],
                       );
                       if (icon != null) {
                          setState(() {
                             _selectedIconCode = icon.codePoint;
                             _selectedEmoji = null;
                          });
                       }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.onSave(_nameController.text, _selectedEmoji, _selectedIconCode);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
