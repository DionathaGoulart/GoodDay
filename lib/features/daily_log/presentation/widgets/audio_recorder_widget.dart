import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class AudioRecorderWidget extends StatefulWidget {
  final Function(String path) onRecordingComplete;

  const AudioRecorderWidget({super.key, required this.onRecordingComplete});

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final _audioRecorder = AudioRecorder(); // Using AudioRecorder for v5
  bool _isRecording = false;
  Timer? _timer;
  int _recordDuration = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/audio_${const Uuid().v4()}.m4a';

        await _audioRecorder.start(
          const RecordConfig(),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });

        _startTimer();
      }
    } catch (e) {
      debugPrint('Error starting record: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      _timer?.cancel();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        widget.onRecordingComplete(path);
      }
    } catch (e) {
      debugPrint('Error stopping record: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isRecording)
          Text(
            _formatDuration(_recordDuration),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (_isRecording) {
              _stopRecording();
            } else {
              _startRecording();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red : Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isRecording ? 'Tap to Stop' : 'Tap to Record',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
