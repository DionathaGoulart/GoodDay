import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_day/features/settings/data/models/activity_category_model.dart';
import 'package:good_day/features/settings/data/models/activity_item_model.dart';
import 'package:good_day/features/settings/presentation/providers/settings_provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// ... imports
// ... imports
import 'add_activity_group_screen.dart';
import 'package:good_day/features/settings/presentation/widgets/categorized_icon_picker.dart';
import 'package:good_day/core/theme/app_theme.dart';

class ManageActivitiesScreen extends ConsumerWidget {
  const ManageActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Atividades')),
      body: categoriesAsync.when(
        data: (categories) {
          final hasCategories = categories.isNotEmpty;
          
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
               if (!hasCategories)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.list_alt, size: 60, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhuma atividade ou escala configurada.',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToAddGroupScreen(context, ref),
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Adicionar grupo ou escala'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
               else
                  ...categories.map((category) => _CategoryTile(category: category)),

               const SizedBox(height: 80), // Fab space
            ],
          );
        },


        loading: () => const Center(child: CircularProgressIndicator()),

        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddGroupScreen(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddGroupScreen(BuildContext context, WidgetRef ref) async {
     final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddActivityGroupScreen()));
     if (result == 'create_group') {
       _showAddCategoryDialog(context, ref);
     } else if (result == 'create_scale') {
       _showAddCategoryDialog(context, ref, title: 'Nova Escala');
     }
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



// Dialog Helpers (Top Level)

void _showAddCategoryDialog(BuildContext context, WidgetRef ref, {String title = 'Nova Categoria'}) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        title: title,
        initialColorValue: AppTheme.pastelColors.first.value,
        onSave: (name, emoji, iconCode, colorValue) async {
            await ref.read(settingsRepositoryProvider).addCategory(
              name,
              iconCode ?? Icons.category.codePoint, 
              colorValue,
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
        title: 'Editar Categoria',
        initialName: category.name,
        initialEmoji: category.emoji,
        initialIconCode: category.iconCode,
        initialColorValue: category.colorValue,
        onSave: (name, emoji, iconCode, colorValue) async {
            await ref.read(settingsRepositoryProvider).updateCategory(
              category.id,
              name: name,
              iconCode: iconCode,
              colorValue: colorValue, 
              emoji: emoji,
              clearEmoji: emoji == null,
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
        title: 'Nova Atividade',
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
        title: 'Editar Atividade',
        initialName: item.name,
        initialEmoji: item.emoji,
        initialIconCode: item.iconCode,
        onSave: (name, emoji, iconCode) async {
             await ref.read(settingsRepositoryProvider).updateItem(
               item.id,
               name: name,
               emoji: emoji,
               iconCode: iconCode,
               clearEmoji: emoji == null,
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
               icon: const Icon(Icons.edit, color: AppTheme.pastelTeal),
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
                        icon: const Icon(Icons.edit, size: 20, color: AppTheme.pastelTeal),
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
                  title: const Text('Adicionar Atividade'),
                  onTap: () => _showAddItemDialog(context, ref, category.id),
                ),
              ],
            ),
            loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
            error: (err, stack) => Padding(padding: const EdgeInsets.all(16), child: Text('Erro: $err')),
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
                    icon: const Icon(Icons.delete_forever, color: AppTheme.pastelPink),
                    label: const Text("Excluir Categoria", style: TextStyle(color: AppTheme.pastelPink)),
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
  final int? initialColorValue;
  final Function(String name, String? emoji, int? iconCode, int colorValue) onSave;

  const _CategoryDialog({
    required this.title,
    required this.onSave,
    this.initialName,
    this.initialEmoji,
    this.initialIconCode,
    this.initialColorValue,
  });

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late TextEditingController _nameController;
  String? _selectedEmoji;
  int? _selectedIconCode;
  late int _selectedColorValue;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedEmoji = widget.initialEmoji;
    _selectedIconCode = widget.initialIconCode;
    _selectedColorValue = widget.initialColorValue ?? AppTheme.pastelColors.first.value;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 24),
            const Text('Cor', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppTheme.pastelColors.map((color) {
                final isSelected = color.value == _selectedColorValue;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorValue = color.value),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: isSelected ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Ícone (Emoji ou Ícone)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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
                const Text('OU'),
                // Icon Selector - Simplified to Single Trigger
                Column(
                  children: [
                    const Text('Ícone', style: TextStyle(fontSize: 12)),
                    IconButton(
                      icon: Icon(
                          _selectedIconCode != null 
                               ? IconData(_selectedIconCode!, fontFamily: 'MaterialIcons') 
                               : Icons.add_circle_outline, // Default "Add" look if none selected, or Category if prefer 
                          size: 32,
                          color: _selectedIconCode != null ? Color(_selectedColorValue) : Colors.grey,
                      ),
                      onPressed: () async {
                         await showModalBottomSheet(
                           context: context,
                           isScrollControlled: true,
                           backgroundColor: Colors.transparent,
                           builder: (context) => CategorizedIconPicker(
                             onIconSelected: (icon) {
                               setState(() {
                                  _selectedIconCode = icon.codePoint;
                                  _selectedEmoji = null;
                               });
                               Navigator.pop(context);
                             },
                           ),
                         );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.onSave(_nameController.text, _selectedEmoji, _selectedIconCode, _selectedColorValue);
              Navigator.pop(context);
            }
          },
          child: const Text('Salvar'),
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
            decoration: const InputDecoration(labelText: 'Nome'),
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
                const Text('OU'),
                // Icon Selector - Simplified
                Column(
                  children: [
                    const Text('Ícone', style: TextStyle(fontSize: 12)),
                    IconButton(
                      icon: Icon(
                          _selectedIconCode != null 
                               ? IconData(_selectedIconCode!, fontFamily: 'MaterialIcons') 
                               : Icons.add_circle_outline, 
                          size: 32,
                           // Note: ItemDialog doesn't have _selectedColorValue, use primary or white
                          color: _selectedIconCode != null ? AppTheme.primaryColor : Colors.grey,
                      ),
                      onPressed: () async {
                         await showModalBottomSheet(
                           context: context,
                           isScrollControlled: true,
                           backgroundColor: Colors.transparent,
                           builder: (context) => CategorizedIconPicker(
                             onIconSelected: (icon) {
                               setState(() {
                                  _selectedIconCode = icon.codePoint;
                                  _selectedEmoji = null;
                               });
                               Navigator.pop(context);
                             },
                           ),
                         );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.onSave(_nameController.text, _selectedEmoji, _selectedIconCode);
              Navigator.pop(context);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
