
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/activity_presets_data.dart';
import '../providers/settings_provider.dart';

class AddActivityGroupScreen extends ConsumerStatefulWidget {
  const AddActivityGroupScreen({super.key});

  @override
  ConsumerState<AddActivityGroupScreen> createState() => _AddActivityGroupScreenState();
}

class _AddActivityGroupScreenState extends ConsumerState<AddActivityGroupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Atividades'),
            Tab(text: 'Escalas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPresetList(context, ActivityPresetsData.groupPresets, isScale: false),
          _buildPresetList(context, ActivityPresetsData.scalePresets, isScale: true),
        ],
      ),
    );
  }

  Widget _buildPresetList(BuildContext context, List<PresetCategory> presets, {required bool isScale}) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Button for custom creation
        ElevatedButton.icon(
          onPressed: () {
            // Return with a signal to open manual creation, or handle it here?
            // The existing dialogs are in ManageActivitiesScreen. 
            // We can return a specific value pop(context, 'create_manual')
            // Or ideally, this screen should handle the manual creation too.
            // But reuse is tricky without refactoring.
            // Let's pass 'create_manual' back to the previous screen to handle it nicely.
            Navigator.pop(context, isScale ? 'create_scale' : 'create_group');
          },
          icon: const Icon(Icons.add),
          label: Text(isScale ? 'Criar Escala Personalizada' : 'Criar Grupo Personalizado'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Sugestões',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...presets.map((preset) => _PresetCard(preset: preset)),
      ],
    );
  }
}

class _PresetCard extends ConsumerWidget {
  final PresetCategory preset;

  const _PresetCard({required this.preset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Text(preset.emoji ?? '📁', style: const TextStyle(fontSize: 24)),
        title: Text(preset.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${preset.items.length} itens'),
        trailing: TextButton(
          onPressed: () => _addPreset(context, ref),
          child: const Text('Adicionar'),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: preset.items.map((item) => Chip(
                label: Text(item.name),
                avatar: item.emoji != null ? Text(item.emoji!) : null,
              )).toList(),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _addPreset(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Add Category
    // We assume the repository method handles ID generation.
    // Ideally we need the ID back to add items.
    // But SettingsRepository.addCategory returns void and generates ID internally consistently? 
    // Wait, let's check SettingsRepository.addCategory.
    // It generates ID but doesn't return it.
    // I MUST modifying SettingsRepository to return the ID.
    // Or I check how UUID is generated. It's generated inside.
    
    // I will need to modify SettingsRepository to return the ID of the created category.
    // Otherwise I cannot add items to it.
    
    // For now I will assume I will fix SettingsRepository.
    
    // Logic placeholder:
    /*
    final newCategoryId = await ref.read(settingsRepositoryProvider).addCategoryReturningId(...);
    for (var item in preset.items) {
       await ref.read(settingsRepositoryProvider).addItem(..., newCategoryId, ...);
    }
    */
    // Since I can't restart the task boundary to fix repo first without getting messy, 
    // I'll assume I can edit the repo in the next step.
    
    // But wait, I'm writing this file now.
    // I can put the logic here assuming the method exists, or just copy the logic effectively?
    // No, better to modify the repo.
    
    // So I will defer the implementation of _addPreset strictly speaking to after I fix the repo?
    // Or I can just write the call assuming it returns the string ID.
    
    // Let's assume `addCategory` returns `Future<String>`.
    
    try {
       final repo = ref.read(settingsRepositoryProvider);
       final newCategoryId = await repo.addCategory(
         preset.name,
         preset.iconCode ?? Icons.category.codePoint,
         preset.colorValue,
         emoji: preset.emoji,
       );
       
       for (var item in preset.items) {
         await repo.addItem(
           item.name,
           newCategoryId,
           iconCode: item.iconCode,
           emoji: item.emoji,
         );
       }
       
       ref.refresh(categoriesProvider);
       if (context.mounted) {
         scaffoldMessenger.showSnackBar(SnackBar(content: Text('${preset.name} adicionado!')));
         Navigator.pop(context);
       }

    } catch (e) {
       if (context.mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Erro ao adicionar: $e')));
       }
    }
  }
}
