# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Essential Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device
flutter run -d [device_id]

# Run tests
flutter test

# Analyze code
flutter analyze

# Build for release
flutter build apk          # Android APK
flutter build appbundle    # Android App Bundle
flutter build ios          # iOS (requires Mac)
```

### Project-specific commands
```bash
# Clean build artifacts
flutter clean

# Upgrade dependencies
flutter pub upgrade

# Run specific test file
flutter test test/widget_test.dart
```

## Architecture Overview

This is a TikTok clone app built with Flutter, featuring a vertical video feed with social features.

### State Management
- **flutter_riverpod** (v2.4.9) - Used for state management across the app
- Provider pattern with ProviderScope wrapping the main app

### Backend Integration  
- **supabase_flutter** (v2.3.2) - Backend service for data storage
- Initialized in main.dart with project-specific URL and anon key
- Used for user data, video metadata, and social features

### Video Playback
- **video_player** (v2.8.2) - Core video playback functionality
- **chewie** (v1.7.4) - Video player UI wrapper
- Custom VideoPlayerItem widget handles:
  - Network video loading
  - Play/pause on tap
  - Looping playback
  - Loading states

### Navigation Structure
- MainScreen acts as the navigation container
- Bottom navigation with 5 tabs:
  1. Home (video feed)
  2. Discover (search)
  3. Upload (gradient button)
  4. Inbox (messages)
  5. Profile (user profile)
- System UI mode changes based on current screen (immersive for home)

### Key UI Patterns
- **Vertical PageView** - Swipe navigation between videos
- **Stack-based layouts** - Overlaying UI elements on videos
- **Gradient effects** - TikTok-style upload button and overlays
- **Action buttons** - Right-side vertical button layout for interactions

## Project Structure

```
lib/
├── main.dart                 # App entry, Supabase init, theme config
├── models/
│   └── video_model.dart     # Video data model with sample data
├── screens/
│   ├── main_screen.dart     # Navigation container, bottom tabs
│   ├── home_screen.dart     # Video feed with PageView
│   ├── discover_screen.dart # Search/explore screen
│   ├── upload_screen.dart   # Video upload interface  
│   ├── inbox_screen.dart    # Messages screen
│   └── profile_screen.dart  # User profile screen
└── widgets/
    └── video_player_item.dart # Reusable video player component
```

## Code Patterns

### Widget Structure
- Stateful widgets for screens with dynamic content
- Separation of presentation (widgets) and data (models)
- Custom widgets for reusable components

### Styling Approach
- Dark theme by default (black background)
- Inline styling with TextStyle and Container decorations
- Custom gradients for TikTok-style effects

### Data Flow
- Sample data provided via static methods (VideoModel.getSampleVideos())
- Ready for Supabase integration for real data
- Local state management for UI interactions (likes, play/pause)