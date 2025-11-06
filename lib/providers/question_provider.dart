// lib/providers/question_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question_state.dart';

// Provider for managing question state
final questionStateProvider = StateNotifierProvider<QuestionNotifier, QuestionState>((ref) {
  return QuestionNotifier();
});

class QuestionNotifier extends StateNotifier<QuestionState> {
  QuestionNotifier() : super(QuestionState());

  // Update text answer
  void updateText(String text) {
    state = state.copyWith(textAnswer: text);
  }

  // Set audio recording status
  void setAudioRecording(bool isRecording) {
    state = state.copyWith(isRecordingAudio: isRecording);
  }

  // Set video recording status
  void setVideoRecording(bool isRecording) {
    state = state.copyWith(isRecordingVideo: isRecording);
  }

  // Save audio path
  void saveAudioPath(String path) {
    state = state.copyWith(audioPath: path, isRecordingAudio: false);
    print('Audio saved: $path');
  }

  // Save video path
  void saveVideoPath(String path) {
    state = state.copyWith(videoPath: path, isRecordingVideo: false);
    print('Video saved: $path');
  }

  // Delete audio
  void deleteAudio() {
    state = state.copyWith(clearAudio: true);
    print('Audio deleted');
  }

  // Delete video
  void deleteVideo() {
    state = state.copyWith(clearVideo: true);
    print('Video deleted');
  }

  // Log current state
  void logState() {
    print('=== Current Question State ===');
    print('Text: ${state.textAnswer}');
    print('Audio: ${state.audioPath ?? "None"}');
    print('Video: ${state.videoPath ?? "None"}');
    print('============================');
  }

  // Reset state
  void reset() {
    state = QuestionState();
  }
}