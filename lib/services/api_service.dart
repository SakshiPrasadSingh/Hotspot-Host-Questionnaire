// lib/services/api_service.dart

import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../models/experience_model.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor for logging (useful for debugging)
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );
  }

  // Fetch experiences from API
  Future<List<Experience>> getExperiences() async {
    try {
      final response = await _dio.get(AppConstants.experiencesEndpoint);

      if (response.statusCode == 200) {
        final experienceResponse = ExperienceResponse.fromJson(response.data);
        return experienceResponse.experiences;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to load experiences',
        );
      }
    } on DioException catch (e) {
      print('[API Error] ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(AppConstants.networkError);
      } else {
        throw Exception('Failed to load experiences: ${e.message}');
      }
    } catch (e) {
      print('[Unexpected Error] $e');
      throw Exception(AppConstants.genericError);
    }
  }
}