import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:good_day/features/daily_log/data/models/daily_log_model.dart';
import 'package:good_day/features/daily_log/presentation/providers/daily_log_provider.dart';

class LogMediaViewer extends ConsumerStatefulWidget {
  final String logId;
  final int initialIndex;

  const LogMediaViewer({
    super.key,
    required this.logId,
    required this.initialIndex,
  });

  @override
  ConsumerState<LogMediaViewer> createState() => _LogMediaViewerState();
}

class _LogMediaViewerState extends ConsumerState<LogMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isVideo(String path) {
      final ext = path.toLowerCase();
      return ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.avi');
  }

  Future<void> _saveMedia(String path) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final fileName = path.split('/').last;
      
      // Separate folder for clarity
      final savedDir = Directory('${appDocDir.path}/SavedMedia');
      if (!await savedDir.exists()) {
        await savedDir.create(recursive: true);
      }
      
      final newPath = '${savedDir.path}/$fileName';
      await File(path).copy(newPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Media saved to: $newPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving media: $e')),
        );
      }
    }
  }

  Future<void> _deleteMedia(DailyLog log, String path) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media?'),
        content: const Text('Are you sure you want to delete this?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final newMediaPaths = List<String>.from(log.mediaPaths);
      newMediaPaths.remove(path);

      final updatedLog = DailyLog(
        id: log.id,
        date: log.date,
        mood: log.mood,
        weather: log.weather,
        activityItemIds: log.activityItemIds,
        food: log.food,
        notes: log.notes,
        mediaPaths: newMediaPaths,
        moodHistory: log.moodHistory,
        audioPaths: log.audioPaths,
      );

      await ref.read(dailyLogsControllerProvider.notifier).addLog(updatedLog);

      if (mounted) {
        if (newMediaPaths.isEmpty) {
          Navigator.pop(context);
        } else {
           setState(() {
              if (_currentIndex >= newMediaPaths.length) {
                _currentIndex = newMediaPaths.length - 1;
              }
           });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(dailyLogsControllerProvider);
    
    return logsAsync.when(
      data: (logs) {
        final log = logs.firstWhere(
           (l) => l.id == widget.logId, 
           orElse: () => DailyLog(id: 'deleted', date: DateTime.now(), mood: 'Meh', activityItemIds: [], mediaPaths: []),
        );

        if (log.id == 'deleted' || log.mediaPaths.isEmpty) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.pop(context);
           });
           return const SizedBox();
        }

        final safeIndex = (_currentIndex >= log.mediaPaths.length) 
           ? log.mediaPaths.length - 1 
           : _currentIndex;
        final currentPath = log.mediaPaths[safeIndex];

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _saveMedia(currentPath),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteMedia(log, currentPath),
              ),
            ],
          ),
          body: PageView.builder(
            controller: _pageController,
            itemCount: log.mediaPaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final path = log.mediaPaths[index];
              if (_isVideo(path)) {
                 return _VideoPlayerItem(path: path);
              }
              return Center(
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        );
      },
      loading: () => const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(backgroundColor: Colors.black, body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white)))),
    );
  }
}

class _VideoPlayerItem extends StatefulWidget {
  final String path;
  const _VideoPlayerItem({required this.path});

  @override
  State<_VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<_VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
         if (mounted) {
           setState(() {
             _initialized = true;
           });
         }
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            // Play/Pause Overlay
            GestureDetector(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              },
              child: Container(
                color: Colors.transparent, // Hit test for entire video area
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _controller.value.isPlaying ? 0.0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
