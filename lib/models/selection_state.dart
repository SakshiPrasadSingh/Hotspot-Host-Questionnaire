// lib/models/selection_state.dart

class SelectionState {
  final List<int> selectedExperienceIds;
  final String userText;

  SelectionState({
    this.selectedExperienceIds = const [],
    this.userText = '',
  });

  SelectionState copyWith({
    List<int>? selectedExperienceIds,
    String? userText,
  }) {
    return SelectionState(
      selectedExperienceIds: selectedExperienceIds ?? this.selectedExperienceIds,
      userText: userText ?? this.userText,
    );
  }

  // Check if an experience is selected
  bool isSelected(int id) {
    return selectedExperienceIds.contains(id);
  }

  // Add or remove experience ID
  SelectionState toggleSelection(int id) {
    final newList = List<int>.from(selectedExperienceIds);
    if (newList.contains(id)) {
      newList.remove(id);
    } else {
      newList.add(id);
    }
    return copyWith(selectedExperienceIds: newList);
  }

  @override
  String toString() {
    return 'SelectionState(selectedIds: $selectedExperienceIds, text: $userText)';
  }
}