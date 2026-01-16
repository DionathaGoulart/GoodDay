import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/daily_log_model.dart';
import '../screens/log_image_viewer.dart';

class LogMediaGrid extends StatelessWidget {
  final DailyLog log;

  const LogMediaGrid({super.key, required this.log});

  void _openViewer(BuildContext context, int index) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LogMediaViewer(logId: log.id, initialIndex: index),
        ),
      );
  }

  Widget _buildThumbnail(String path) {
    if (_isVideo(path)) {
      return Stack(
         fit: StackFit.expand,
         children: [
            Container(color: Colors.black),
            const Center(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 48)),
         ],
      );
    }
    return Image.file(File(path), fit: BoxFit.cover);
  }

  bool _isVideo(String path) {
      final ext = path.toLowerCase();
      return ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.avi');
  }

  @override
  Widget build(BuildContext context) {
      final mediaPaths = log.mediaPaths;
      if (mediaPaths.isEmpty) return const SizedBox.shrink();

      if (mediaPaths.length == 1) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => _openViewer(context, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                   height: 250, // Fixed height for sigle item to look nice
                   width: double.infinity,
                   child: _isVideo(mediaPaths.first) 
                     ? _buildThumbnail(mediaPaths.first)
                     : Image.file(
                        File(mediaPaths.first),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                ),
              ),
            ),
          );
      }

      if (mediaPaths.length == 2) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1, 
                    child: InkWell(
                      onTap: () => _openViewer(context, 0),
                      child: ClipRRect(
                         borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                         ),
                         child: _buildThumbnail(mediaPaths[0]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: InkWell(
                      onTap: () => _openViewer(context, 1),
                      child: ClipRRect(
                         borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                         ),
                         child: _buildThumbnail(mediaPaths[1]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
      }

      // 3+ Images -> Grid
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: mediaPaths.length,
            itemBuilder: (context, index) {
               return InkWell(
                 onTap: () => _openViewer(context, index),
                 child: _buildThumbnail(mediaPaths[index]),
               );
            },
          ),
        ),
      );
  }
}
