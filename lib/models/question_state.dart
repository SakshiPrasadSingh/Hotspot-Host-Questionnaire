// lib/models/question_state.dart

class QuestionState {
  final String textAnswer;
  final String? audioPath;
  final String? videoPath;
  final bool isRecordingAudio;
  final bool isRecordingVideo;

  QuestionState({
    this.textAnswer = '',
    this.audioPath,
    this.videoPath,
    this.isRecordingAudio = false,
    this.isRecordingVideo = false,
  });

  QuestionState copyWith({
    String? textAnswer,
    String? audioPath,
    String? videoPath,
    bool? isRecordingAudio,
    bool? isRecordingVideo,
    bool clearAudio = false,
    bool clearVideo = false,
  }) {
    return QuestionState(
      textAnswer: textAnswer ?? this.textAnswer,
      audioPath: clearAudio ? null : (audioPath ?? this.audioPath),
      videoPath: clearVideo ? null : (videoPath ?? this.videoPath),
      isRecordingAudio: isRecordingAudio ?? this.isRecordingAudio,
      isRecordingVideo: isRecordingVideo ?? this.isRecordingVideo,
    );
  }

  bool get hasAudioRecording => audioPath != null && audioPath!.isNotEmpty;
  bool get hasVideoRecording => videoPath != null && videoPath!.isNotEmpty;
  bool get canShowRecordButtons => !hasAudioRecording && !hasVideoRecording;

  @override
  String toString() {
    return 'QuestionState(text: $textAnswer, audio: $audioPath, video: $videoPath, recordingAudio: $isRecordingAudio, recordingVideo: $isRecordingVideo)';
  }
}