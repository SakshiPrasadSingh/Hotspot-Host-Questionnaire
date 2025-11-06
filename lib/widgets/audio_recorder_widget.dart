// lib/widgets/audio_recorder_widget.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/theme/app_theme.dart';
import '../providers/question_provider.dart';

class AudioRecorderWidget extends ConsumerStatefulWidget {
  const AudioRecorderWidget({super.key});

  @override
  ConsumerState<AudioRecorderWidget> createState() => AudioRecorderWidgetState();
}

class AudioRecorderWidgetState extends ConsumerState<AudioRecorderWidget> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  int _recordDuration = 0;
  Timer? _timer;
  String? _audioPath;

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });

        ref.read(questionStateProvider.notifier).setAudioRecording(true);

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordDuration++;
          });
        });
      } else {
        await Permission.microphone.request();
      }
    } catch (e) {
      print('Error starting recording: $e');
      _showError('Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _timer?.cancel();

      setState(() {
        _isRecording = false;
        _audioPath = path;
      });

      if (path != null) {
        ref.read(questionStateProvider.notifier).saveAudioPath(path);
      }
    } catch (e) {
      print('Error stopping recording: $e');
      _showError('Failed to stop recording');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      _timer?.cancel();

      setState(() {
        _isRecording = false;
        _recordDuration = 0;
      });

      ref.read(questionStateProvider.notifier).setAudioRecording(false);
    } catch (e) {
      print('Error canceling recording: $e');
    }
  }

  Future<void> _playAudio() async {
    if (_audioPath == null) return;

    try {
      await _audioPlayer.play(DeviceFileSource(_audioPath!));
      setState(() => _isPlaying = true);

      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() => _isPlaying = false);
      });
    } catch (e) {
      print('Error playing audio: $e');
      _showError('Failed to play audio');
    }
  }

  Future<void> _stopPlaying() async {
    await _audioPlayer.stop();
    setState(() => _isPlaying = false);
  }

  void _deleteAudio() {
    setState(() {
      _audioPath = null;
      _recordDuration = 0;
    });
    ref.read(questionStateProvider.notifier).deleteAudio();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final questionState = ref.watch(questionStateProvider);

    // If audio is already recorded, show player
    if (questionState.hasAudioRecording && !_isRecording) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.audiotrack,
              color: AppTheme.primaryColor,
              size: 32,
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Audio Recorded',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _formatDuration(_recordDuration),
                    style: AppTheme.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _isPlaying ? _stopPlaying : _playAudio,
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              color: AppTheme.primaryColor,
            ),
            IconButton(
              onPressed: _deleteAudio,
              icon: const Icon(Icons.delete),
              color: AppTheme.errorColor,
            ),
          ],
        ),
      );
    }

    // If recording, show recording interface
    if (_isRecording) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(color: Colors.red.shade200, width: 2),
        ),
        child: Column(
          children: [
            // Waveform animation (simplified)
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(20, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    curve: Curves.easeInOut,
                    width: 4,
                    height: 10 + (index % 5) * 10.0,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              _formatDuration(_recordDuration),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _cancelRecording,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                ElevatedButton.icon(
                  onPressed: _stopRecording,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Default: Show record button
    return const SizedBox.shrink();
  }

  // Method to be called from parent to start recording
  void startRecording() {
    _startRecording();
  }
}