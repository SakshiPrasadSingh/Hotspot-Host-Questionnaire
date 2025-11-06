// lib/core/constants/app_constants.dart

class AppConstants {
  // API URLs
  static const String baseUrl = 'https://staging.chamberofsecrets.8club.co';
  static const String experiencesEndpoint = '/v1/experiences?active=true';

  // Character Limits
  static const int experienceTextLimit = 250;
  static const int questionTextLimit = 600;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);

  // File paths
  static const String audioDirectory = 'audio_recordings';
  static const String videoDirectory = 'video_recordings';

  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String permissionDenied = 'Permission denied. Please enable permissions in settings.';
}