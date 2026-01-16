import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:good_day/features/daily_log/data/models/daily_log_model.dart';
import 'package:good_day/features/settings/data/models/activity_category_model.dart';
import 'package:good_day/features/settings/data/models/activity_item_model.dart';
import 'package:good_day/features/settings/presentation/providers/settings_provider.dart';
import '../../../dashboard/data/services/stats_service.dart';
import '../providers/daily_log_provider.dart';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/mood_selector.dart';
import '../widgets/dynamic_activity_selector.dart';
import 'package:good_day/core/theme/app_theme.dart';

class AddDailyLogScreen extends ConsumerStatefulWidget {
  final DailyLog? logToEdit;

  const AddDailyLogScreen({super.key, this.logToEdit});

  @override
  ConsumerState<AddDailyLogScreen> createState() => _AddDailyLogScreenState();
}

class _AddDailyLogScreenState extends ConsumerState<AddDailyLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  String _mood = 'Feliz';
  List<String> _selectedItemIds = [];
  final List<String> _mediaPaths = [];
  final List<String> _audioPaths = []; // NEW
  final _weatherController = TextEditingController();
  final _foodController = TextEditingController(); 
  final _notesController = TextEditingController();

  Map<ActivityCategory, List<ActivityItem>> _groupedItems = {};
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadData();
  }

  void _initializeData() {
    if (widget.logToEdit != null) {
      final log = widget.logToEdit!;
      _selectedDate = log.date;
      _mood = log.mood;
      _selectedItemIds = List.from(log.activityItemIds);
      _mediaPaths.addAll(log.mediaPaths);
      _audioPaths.addAll(log.audioPaths); // NEW
      _weatherController.text = log.weather ?? '';
      _foodController.text = log.food ?? '';
      _notesController.text = log.notes ?? '';
    } else {
      _selectedDate = DateTime.now();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _mediaPaths.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao selecionar imagem: $e')));
      }
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(source: source);
      if (video != null) {
        setState(() {
          _mediaPaths.add(video.path);
        });
      }
    } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao selecionar vídeo: $e')));
        }
    }
  }

  void _showMediaPickerOptions() {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar Foto'),
                onTap: () {
                   Navigator.pop(context);
                   _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Escolher Foto'),
                 onTap: () {
                   Navigator.pop(context);
                   _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Gravar Vídeo'),
                 onTap: () {
                   Navigator.pop(context);
                   _pickVideo(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Escolher Vídeo'),
                 onTap: () {
                   Navigator.pop(context);
                   _pickVideo(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaPaths.removeAt(index);
    });
  }

  void _removeAudio(int index) {
    setState(() {
      _audioPaths.removeAt(index);
    });
  }

  Future<void> _loadData() async {
    // Bootstrap if needed (via provider)
    final categories = await ref.read(categoriesProvider.future);
    final group = <ActivityCategory, List<ActivityItem>>{};
    
    for (var cat in categories) {
      final items = await ref.read(itemsProvider(cat.id).future);
      group[cat] = items;
    }
    
    if (mounted) {
      setState(() {
        _groupedItems = group;
      });
    }
  }

  void _saveLog() async {
    if (_formKey.currentState!.validate()) {
      final log = DailyLog(
        id: widget.logToEdit?.id ?? const Uuid().v4(), // Use existing ID if editing
        date: _selectedDate,
        mood: _mood,
        weather: _weatherController.text,
        activityItemIds: _selectedItemIds,
        food: _foodController.text,
        notes: _notesController.text,
        mediaPaths: _mediaPaths,
        audioPaths: _audioPaths, // NEW
      );

      ref.read(dailyLogsControllerProvider.notifier).addLog(log);

      if (mounted) {
        // If new log, calculate streak to pass back
        if (widget.logToEdit == null) {
           final currentLogs = ref.read(dailyLogsControllerProvider).value ?? [];
           final updatedLogs = [...currentLogs, log];
           final streak = StatsService().calculateCurrentStreak(updatedLogs);
           Navigator.pop(context, streak);
        } else {
           Navigator.pop(context, null);
        }
      }
    }
  }

  void _deleteLog() {
    if (widget.logToEdit != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Excluir Registro?'),
          content: const Text('Tem certeza que deseja excluir este registro? Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                ref.read(dailyLogsControllerProvider.notifier).deleteLog(widget.logToEdit!.id);
                Navigator.pop(context); // Close Dialog
                Navigator.pop(context); // Close Screen
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.logToEdit != null ? 'Editar Registro' : 'Novo Registro'),
        actions: [
          TextButton(
            onPressed: _saveLog,
            child: const Text('Salvar', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date Picker Row
            Row(
              children: [
                const Text('Data:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            const Text('Como você está?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            MoodSelector(
              selectedMood: _mood,
              onSelected: (val) => setState(() => _mood = val),
            ),
            const SizedBox(height: 24),

            const Text('O que você tem feito?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_groupedItems.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              Consumer(
                builder: (context, ref, _) {
                  return DynamicActivitySelector(
                    categoryItems: _groupedItems,
                    selectedItemIds: _selectedItemIds,
                    onChanged: (val) => setState(() => _selectedItemIds = val),
                  );
                }
              ),
            
            const SizedBox(height: 24),
            
            // Media Section
            const Text('Mídia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add Button
                  GestureDetector(
                    onTap: () => _showMediaPickerOptions(),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        // border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: Colors.grey),
                          SizedBox(height: 4),
                          Text('Adicionar', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // List of Images
                  ..._mediaPaths.asMap().entries.map((entry) {
                    final index = entry.key;
                    final path = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeMedia(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Audio Section
            const Text('Áudio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            AudioRecorderWidget(
              onRecordingComplete: (path) {
                setState(() {
                  _audioPaths.add(path);
                });
              },
            ),
            if (_audioPaths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  children: _audioPaths.asMap().entries.map((entry) {
                    final index = entry.key;
                    final path = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(child: AudioPlayerWidget(audioPath: path)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeAudio(index),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 24),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas e Pensamentos',
                prefixIcon: Icon(Icons.note),
                border: InputBorder.none,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            if (widget.logToEdit != null)
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: TextButton.icon(
                  onPressed: _deleteLog,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Excluir Registro', style: TextStyle(color: Colors.red)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
