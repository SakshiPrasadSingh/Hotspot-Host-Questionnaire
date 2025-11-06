// lib/screens/experience_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../providers/experience_provider.dart';
import '../widgets/experience_card.dart';
import 'question_screen.dart';

class ExperienceSelectionScreen extends ConsumerStatefulWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  ConsumerState<ExperienceSelectionScreen> createState() =>
      _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState
    extends ConsumerState<ExperienceSelectionScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to text changes and update provider
    _textController.addListener(() {
      ref.read(selectionStateProvider.notifier).updateText(_textController.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _navigateToQuestionScreen() {
    // Log the state before navigation
    ref.read(selectionStateProvider.notifier).logState();

    // Navigate to question screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuestionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final experiencesAsync = ref.watch(experiencesProvider);
    final selectionState = ref.watch(selectionStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Select Experiences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: experiencesAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading experiences...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Oops! Something went wrong',
                  style: AppTheme.heading2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  error.toString(),
                  style: AppTheme.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingL),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(experiencesProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (experiences) {
          if (experiences.isEmpty) {
            return const Center(
              child: Text('No experiences available'),
            );
          }

          return Column(
            children: [
              // Experiences Grid
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  itemCount: experiences.length,
                  itemBuilder: (context, index) {
                    final experience = experiences[index];
                    final isSelected = selectionState.isSelected(experience.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                      child: ExperienceCard(
                        experience: experience,
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(selectionStateProvider.notifier)
                              .toggleExperience(experience.id);
                        },
                      ),
                    );
                  },
                ),
              ),

              // Text Input and Next Button
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Multi-line Text Field
                      TextField(
                        controller: _textController,
                        maxLines: 4,
                        maxLength: AppConstants.experienceTextLimit,
                        decoration: InputDecoration(
                          hintText: 'Tell us more about your experience...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          counterText:
                          '${_textController.text.length}/${AppConstants.experienceTextLimit}',
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),

                      // Next Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: selectionState.selectedExperienceIds.isNotEmpty
                              ? _navigateToQuestionScreen
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(AppTheme.radiusM),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: selectionState
                                      .selectedExperienceIds.isNotEmpty
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: selectionState
                                    .selectedExperienceIds.isNotEmpty
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Selection count indicator
                      if (selectionState.selectedExperienceIds.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: AppTheme.spacingS),
                          child: Text(
                            '${selectionState.selectedExperienceIds.length} experience(s) selected',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}