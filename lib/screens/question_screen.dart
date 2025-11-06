// lib/screens/question_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../providers/question_provider.dart';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/video_recorder_widget.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen({super.key});

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey<AudioRecorderWidgetState> _audioKey = GlobalKey();
  final GlobalKey<VideoRecorderWidgetState> _videoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      ref.read(questionStateProvider.notifier).updateText(_textController.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    ref.read(questionStateProvider.notifier).logState();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Response submitted successfully!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionState = ref.watch(questionStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Answer Question',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Text
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.question_answer,
                          color: AppTheme.primaryColor,
                        ),
                        SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Question',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    Text(
                      'Tell us about your experience hosting events and why you would be a great hotspot host?',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Instructions
              const Text(
                'You can answer via text, audio, or video:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: AppTheme.spacingM),

              // Text Answer Field
              TextField(
                controller: _textController,
                maxLines: 6,
                maxLength: AppConstants.questionTextLimit,
                decoration: InputDecoration(
                  hintText: 'Type your answer here...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  counterText:
                  '${_textController.text.length}/${AppConstants.questionTextLimit}',
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Audio Recording Section
              if (questionState.isRecordingAudio || questionState.hasAudioRecording)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Audio Answer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    AudioRecorderWidget(key: _audioKey),
                    const SizedBox(height: AppTheme.spacingL),
                  ],
                ),

              // Video Recording Section
              if (questionState.isRecordingVideo || questionState.hasVideoRecording)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Video Answer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    VideoRecorderWidget(key: _videoKey),
                    const SizedBox(height: AppTheme.spacingL),
                  ],
                ),

              // Recording Buttons (show only if no recording exists)
              if (questionState.canShowRecordButtons &&
                  !questionState.isRecordingAudio &&
                  !questionState.isRecordingVideo)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _audioKey.currentState?.startRecording();
                        },
                        icon: const Icon(Icons.mic),
                        label: const Text('Record Audio'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.primaryColor),
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _videoKey.currentState?.startRecording();
                        },
                        icon: const Icon(Icons.videocam),
                        label: const Text('Record Video'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.primaryColor),
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: AppTheme.spacingXL),

              // Next Button
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _textController.text.isNotEmpty ||
                      questionState.hasAudioRecording ||
                      questionState.hasVideoRecording
                      ? _handleSubmit
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppTheme.primaryColor,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textController.text.isNotEmpty ||
                              questionState.hasAudioRecording ||
                              questionState.hasVideoRecording
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        color: _textController.text.isNotEmpty ||
                            questionState.hasAudioRecording ||
                            questionState.hasVideoRecording
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }
}