// lib/providers/experience_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/experience_model.dart';
import '../models/selection_state.dart';
import '../services/api_service.dart';

// Provider for API Service
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider for fetching experiences (FutureProvider for async data)
final experiencesProvider = FutureProvider<List<Experience>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getExperiences();
});

// Provider for managing selection state
final selectionStateProvider = StateNotifierProvider<SelectionNotifier, SelectionState>((ref) {
  return SelectionNotifier();
});

// StateNotifier to manage selection state
class SelectionNotifier extends StateNotifier<SelectionState> {
  SelectionNotifier() : super(SelectionState());

  // Toggle experience selection
  void toggleExperience(int id) {
    state = state.toggleSelection(id);
    print('Selection State Updated: $state');
  }

  // Update user text
  void updateText(String text) {
    state = state.copyWith(userText: text);
  }

  // Get current state for logging
  void logState() {
    print('=== Current Selection State ===');
    print('Selected IDs: ${state.selectedExperienceIds}');
    print('User Text: ${state.userText}');
    print('==============================');
  }

  // Reset state
  void reset() {
    state = SelectionState();
  }
}