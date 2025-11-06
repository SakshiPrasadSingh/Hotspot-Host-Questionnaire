# Hotspot Host Questionnaire

A Flutter application for onboarding hotspot hosts through an interactive questionnaire experience.

## Features Implemented

### Core Requirements

#### 1. Experience Type Selection Screen
- **Dynamic Experience Loading**: Fetches experience data from REST API using Dio
- **Visual Experience Cards**:
    - Cards display with `image_url` as background
    - Clean UI with proper spacing and rounded corners
    - Smooth hover and selection animations
- **Selection Functionality**:
    - Multi-selection support (users can select multiple experiences)
    - Visual feedback with border highlight and checkmark icon
    - Grayscale filter applied to unselected cards
    - Color restoration on selection
- **Text Input**:
    - Multi-line text field for additional comments
    - Character limit of 250 characters
    - Real-time character counter display
- **State Management**:
    - Selected experience IDs stored in state
    - User text persisted across navigation
    - State logged to console on "Next" button click
- **Navigation**:
    - Smart "Next" button (disabled until at least one experience selected)
    - Selection counter showing number of selected experiences
    - Smooth navigation to Question Screen

#### 2. Onboarding Question Screen
- **Question Display**:
    - Prominent question card with icon
    - Clear, readable typography
    - Contextual instructions
- **Text Answer**:
    - Multi-line text field (6 rows visible)
    - Character limit of 600 characters
    - Real-time character counter
- **Audio Recording**:
    - Record audio answers with microphone permission handling
    - Waveform visualization during recording (animated bars)
    - Recording duration timer (MM:SS format)
    - Cancel option during recording
    - Delete recorded audio functionality
    - Audio playback with play/pause controls
    - Saved as .m4a format
- **Video Recording**:
    - Record video answers with camera permission handling
    - Live camera preview during recording
    - Visual recording indicator
    - Cancel option during recording
    - Delete recorded video functionality
    - Video playback controls
    - Saved as .mp4 format
- **Dynamic UI Layout**:
    - Recording buttons (Audio & Video) displayed initially
    - Buttons automatically hide when media is recorded
    - Only one type of media can be recorded at a time
    - Recorded media displayed with playback controls
- **Smart Submit Button**:
    - Enabled only when at least one answer method is used (text/audio/video)
    - Shows success message on submission
    - Logs complete state to console

---

## Brownie Points Implemented

### State Management
- **Riverpod Implementation**:
    - `StateNotifierProvider` for selection state management
    - `FutureProvider` for async API data fetching
    - Separate providers for experience selection and question state
    - Clean separation of concerns
    - Immutable state management

### API Integration
- **Dio HTTP Client**:
    - Configured with base URL and timeouts
    - Request/response interceptors for logging
    - Comprehensive error handling
    - Network error detection and user-friendly messages
    - Retry mechanism on API failure

### UI/UX Enhancements
- **Responsive Design**:
    - `SingleChildScrollView` for keyboard handling
    - SafeArea implementation for notch support
    - Proper viewport adjustment when keyboard appears
    - Smooth scrolling behavior
- **Visual Feedback**:
    - Loading indicators during API calls
    - Error states with retry buttons
    - Empty state handling
    - Success notifications
- **Animations**:
    - Smooth card selection transitions (300ms)
    - Border and shadow animations on selection
    - Waveform animation during audio recording
    - Button state transitions

### Code Quality
- **Clean Architecture**:
    - Organized folder structure (screens, models, services, providers, widgets)
    - Separation of concerns
    - Reusable widgets
    - DRY principles followed
- **Error Handling**:
    - Try-catch blocks for all async operations
    - User-friendly error messages
    - Graceful fallbacks
    - Permission denial handling
- **Code Documentation**:
    - Inline comments for complex logic
    - Clear variable and function naming
    - Proper code formatting

### Additional Features
- **File Management**:
    - Unique filenames with timestamps
    - Proper file path handling
- **Media Controls**:
    - Audio playback with audioplayers package
    - Video playback with video_player package
    - Play/pause functionality
    - Delete confirmation through visual feedback

---

##  Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # API URLs, limits, constants
│   └── theme/
│       └── app_theme.dart             # Colors, text styles, theme
├── models/
│   ├── experience_model.dart          # Experience data model
│   ├── selection_state.dart           # Selection state model
│   └── question_state.dart            # Question state model
├── services/
│   ├── api_service.dart               # Dio API client
│   ├── audio_service.dart             # Audio recording service
│   └── video_service.dart             # Video recording service
├── providers/
│   ├── experience_provider.dart       # Riverpod providers for experiences
│   └── question_provider.dart         # Riverpod providers for questions
├── screens/
│   ├── experience_selection_screen.dart  # Screen 1
│   └── question_screen.dart           # Screen 2
└── widgets/
    ├── experience_card.dart           # Experience card widget
    ├── audio_recorder_widget.dart     # Audio recording widget
    └── video_recorder_widget.dart     # Video recording widget
```

---

## Dependencies Used

```yaml
dependencies:
  flutter_riverpod: ^2.4.9      # State management
  dio: ^5.4.0                    # HTTP client for API calls
  record: ^5.0.4                 # Audio recording
  audio_waveforms: ^1.0.5        # Waveform visualization
  audioplayers: ^5.2.1           # Audio playback
  camera: ^0.10.5+9              # Video recording
  video_player: ^2.8.2           # Video playback
  path_provider: ^2.1.2          # File system paths
  permission_handler: ^11.2.0    # Runtime permissions
```

---

## Key Technical Highlights

### State Management Pattern
- Provider-based architecture using Riverpod
- Immutable state objects with `copyWith` methods
- State persistence across screen navigation
- Console logging for debugging

### Media Recording
- **Audio Format**: AAC-LC (.m4a)
- **Video Format**: MP4
- **Storage**: App documents directory
- **Naming**: Timestamp-based unique filenames

### Performance Optimizations
- Image caching for experience cards
- Lazy loading of list items
- Efficient state updates (only rebuild affected widgets)
- Proper disposal of controllers and streams

---

## Notes

- Requires microphone and camera permissions
- Internet connection needed for loading experiences
- Minimum SDK version: 21 (Android 5.0)

---

## Developer

Sakshi Prasad Singh
- Email: sakshiprasad842@gmail.com
- GitHub: [@SakshiPrasadSingh](https://github.com/SakshiPrasadSingh)
