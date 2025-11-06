// lib/widgets/video_recorder_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/question_provider.dart';

class VideoRecorderWidget extends ConsumerStatefulWidget {
  const VideoRecorderWidget({super.key});

  @override
  ConsumerState<VideoRecorderWidget> createState() => VideoRecorderWidgetState();
}

class VideoRecorderWidgetState extends ConsumerState<VideoRecorderWidget> {
  CameraController? _cameraController;
  VideoPlayerController? _videoPlayerController;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  bool _isCameraInitialized = false;
  String? _videoPath;

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        _showError('No camera available');
        return;
      }

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      _showError('Failed to initialize camera');
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      await _initializeCamera();
    }

    if (_cameraController == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _cameraController!.startVideoRecording();

      setState(() {
        _isRecording = true;
      });

      ref.read(questionStateProvider.notifier).setVideoRecording(true);
    } catch (e) {
      print('Error starting video recording: $e');
      _showError('Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      final file = await _cameraController!.stopVideoRecording();

      setState(() {
        _isRecording = false;
        _videoPath = file.path;
        _isCameraInitialized = false;
      });

      await _cameraController?.dispose();
      _cameraController = null;

      ref.read(questionStateProvider.notifier).saveVideoPath(file.path);

      // Initialize video player
      await _initializeVideoPlayer(file.path);
    } catch (e) {
      print('Error stopping video recording: $e');
      _showError('Failed to stop recording');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
        await _cameraController!.stopVideoRecording();
      }

      await _cameraController?.dispose();
      _cameraController = null;

      setState(() {
        _isRecording = false;
        _isCameraInitialized = false;
      });

      ref.read(questionStateProvider.notifier).setVideoRecording(false);
    } catch (e) {
      print('Error canceling recording: $e');
    }
  }

  Future<void> _initializeVideoPlayer(String path) async {
    _videoPlayerController = VideoPlayerController.file(File(path));
    await _videoPlayerController!.initialize();
    setState(() {});
  }

  void _deleteVideo() {
    _videoPlayerController?.dispose();
    _videoPlayerController = null;

    setState(() {
      _videoPath = null;
    });

    ref.read(questionStateProvider.notifier).deleteVideo();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionState = ref.watch(questionStateProvider);

    // If video is recorded, show player
    if (questionState.hasVideoRecording && _videoPath != null) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          children: [
            if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                child: AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController!),
                ),
              ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (_videoPlayerController!.value.isPlaying) {
                      _videoPlayerController!.pause();
                    } else {
                      _videoPlayerController!.play();
                    }
                    setState(() {});
                  },
                  icon: Icon(
                    _videoPlayerController?.value.isPlaying ?? false
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  label: Text(
                    _videoPlayerController?.value.isPlaying ?? false
                        ? 'Pause'
                        : 'Play',
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                ElevatedButton.icon(
                  onPressed: _deleteVideo,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // If recording, show camera preview
    if (_isRecording && _isCameraInitialized && _cameraController != null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(color: Colors.red, width: 3),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              child: CameraPreview(_cameraController!),
            ),
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Recording...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
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
            ),
          ],
        ),
      );
    }

    // Default: empty
    return const SizedBox.shrink();
  }

  // Method to be called from parent
  void startRecording() {
    _startRecording();
  }
}