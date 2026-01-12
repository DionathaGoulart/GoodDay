import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final bool isMinimalist;

  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
    this.isMinimalist = false,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    // Set source - assuming local file path
    await _player.setSource(DeviceFileSource(widget.audioPath));
    
    // Listeners
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerStateChanged.listen((s) async {
      if (mounted) {
         setState(() => _isPlaying = s == PlayerState.playing);
         // Sometimes duration is only available after playback starts
         if (s == PlayerState.playing && _duration == Duration.zero) {
           final d = await _player.getDuration();
           if (d != null && mounted) {
             setState(() => _duration = d);
           }
         }
      }
    });
    
    // Explicitly try to get duration now
    final d = await _player.getDuration();
    if (d != null && mounted) {
       setState(() => _duration = d);
    }
    
    // Resume listening to completion
    _player.onPlayerComplete.listen((_) {
        if (mounted) {
            setState(() {
                _isPlaying = false;
                _position = Duration.zero;
            });
        }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isMinimalist ? Colors.white : Theme.of(context).colorScheme.primary;
    final textColor = widget.isMinimalist ? Colors.white : null;

    if (widget.isMinimalist) {
       // Minimalist: [Play] 00:00 / 00:00 [Audio]
       return Row(
           children: [
               IconButton(
                   icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: color),
                   onPressed: () {
                       if (_isPlaying) _player.pause();
                       else _player.resume();
                   },
                   padding: EdgeInsets.zero,
                   constraints: const BoxConstraints(),
               ),
               const SizedBox(width: 8),
               Text('${_formatDuration(_position)} / ${_formatDuration(_duration)}', style: TextStyle(color: textColor, fontSize: 12, fontFamily: 'Courier New')),
               const Spacer(),
               Icon(Icons.audiotrack, size: 16, color: color.withOpacity(0.5)),
           ],
       );
    }
    
    // Complex
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          IconButton(
             icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 36, color: color),
             onPressed: () async {
                 if (_isPlaying) {
                     await _player.pause();
                 } else {
                     await _player.resume();
                 }
             },
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                trackHeight: 2,
              ),
              child: Slider(
                activeColor: color,
                inactiveColor: color.withOpacity(0.2),
                min: 0,
                max: (_duration.inMilliseconds > 0) ? _duration.inMilliseconds.toDouble() : 1.0,
                value: _position.inMilliseconds.toDouble().clamp(0, (_duration.inMilliseconds > 0) ? _duration.inMilliseconds.toDouble() : 1.0),
                onChanged: (val) {
                  _player.seek(Duration(milliseconds: val.toInt()));
                },
              ),
            ),
          ),
          Text(_formatDuration(_position), style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
