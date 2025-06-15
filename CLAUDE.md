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

App Forge is an AI-powered application that transforms Figma designs into Flutter code.

### State Management
- **flutter_riverpod** (v2.4.9) - Used for state management across the app
- Provider pattern with ProviderScope wrapping the main app

### Backend Integration  
- **supabase_flutter** (v2.3.2) - Backend service for:
  - User authentication
  - Project storage
  - Generated code management
  - API integration

### HTTP Communications
- **dio** (v5.4.0) - Advanced HTTP client for API requests
- **http** (v1.1.0) - Simple HTTP requests

### Key Features to Implement
1. **Figma Integration** - Connect to Figma API to fetch designs
2. **AI Code Generation** - Process designs and generate Flutter code
3. **Project Management** - Handle multiple projects and versions
4. **Code Preview** - Live preview of generated code
5. **Export Options** - Download generated Flutter project

## Project Structure

```
lib/
├── main.dart              # App entry, Supabase init, Material3 theme
├── models/               # Data models (to be created)
│   ├── project.dart     # Project model
│   ├── figma_design.dart # Figma design model
│   └── generated_code.dart # Generated code model
├── screens/              # App screens (to be created)
│   ├── home_screen.dart # Project list
│   ├── import_screen.dart # Figma import
│   ├── generation_screen.dart # Code generation
│   └── preview_screen.dart # Code preview
├── services/             # Business logic (to be created)
│   ├── figma_service.dart # Figma API integration
│   ├── ai_service.dart   # AI code generation
│   └── storage_service.dart # Supabase storage
└── widgets/              # Reusable widgets (to be created)
    └── code_viewer.dart  # Code display widget
```

## Code Patterns

### Widget Structure
- Use StatefulWidget for screens with dynamic content
- Use StatelessWidget for static UI components
- Implement responsive design for various screen sizes

### Service Layer
- Separate business logic from UI
- Use dependency injection with Riverpod
- Handle errors gracefully with proper error states

### Data Flow
- Figma Design → AI Service → Generated Code → Preview
- Store projects in Supabase for persistence
- Cache generated code locally for performance