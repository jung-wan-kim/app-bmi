# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BMI Tracker is a comprehensive weight management mobile application that helps users track their weight, BMI, and visualize their fitness journey through graphs and character representations.

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

# Format code
dart format lib/

# Check for dependency updates
flutter pub outdated
```

## Architecture Overview

A Flutter-based weight management app with real-time data visualization and BMI tracking capabilities.

### Core Features
1. **Weight & BMI Tracking** - Record and monitor weight, height, and BMI calculations
2. **Data Visualization** - Display daily, weekly, and monthly weight trends with interactive graphs
3. **Goal Setting** - Set target weight and track progress
4. **BMI Character** - Visual representation of current and target body shape based on BMI
5. **Data Persistence** - Cloud sync with Supabase backend

### State Management
- **flutter_riverpod** (v2.4.9) - State management solution
- Provider pattern for reactive UI updates
- Separate providers for user data, weight records, and app settings

### Backend Integration  
- **supabase_flutter** (v2.3.2) - Backend services for:
  - User authentication
  - Weight records storage
  - User profiles and settings
  - Real-time data synchronization
  - Cloud backup

### Data Visualization
- **fl_chart** or **syncfusion_flutter_charts** - For graph rendering
- Custom widgets for BMI character display
- Animated transitions for weight progress

## Project Structure

```
lib/
├── main.dart                    # App entry, Supabase init, theme setup
├── core/
│   ├── constants/              # App constants
│   │   ├── bmi_constants.dart # BMI ranges and categories
│   │   └── app_colors.dart    # Color scheme
│   ├── utils/                  # Utility functions
│   │   ├── bmi_calculator.dart # BMI calculation logic
│   │   └── date_formatter.dart # Date formatting utilities
│   └── theme/                  # App theming
│       └── app_theme.dart      # Material3 theme configuration
├── models/
│   ├── user_model.dart         # User profile model
│   ├── weight_record.dart      # Weight entry model
│   ├── body_metrics.dart       # Height, weight, BMI data
│   └── goal_model.dart         # Weight goal model
├── providers/
│   ├── auth_provider.dart      # Authentication state
│   ├── user_provider.dart      # User data provider
│   ├── weight_provider.dart    # Weight records provider
│   └── statistics_provider.dart # Data analysis provider
├── screens/
│   ├── splash_screen.dart      # App launch screen
│   ├── auth/
│   │   ├── login_screen.dart   # User login
│   │   └── register_screen.dart # User registration
│   ├── home_screen.dart        # Main dashboard
│   ├── record_weight_screen.dart # Weight entry form
│   ├── statistics_screen.dart  # Graphs and trends
│   ├── profile_screen.dart     # User profile & settings
│   └── goal_setting_screen.dart # Set target weight
├── widgets/
│   ├── charts/
│   │   ├── weight_line_chart.dart # Weight trend graph
│   │   ├── bmi_gauge.dart      # BMI indicator
│   │   └── progress_chart.dart # Goal progress visualization
│   ├── character/
│   │   ├── bmi_character.dart  # BMI-based character widget
│   │   └── character_animator.dart # Character animations
│   └── common/
│       ├── custom_button.dart   # Reusable button
│       └── input_field.dart     # Custom text input
└── services/
    ├── database_service.dart    # Supabase database operations
    ├── auth_service.dart        # Authentication logic
    └── analytics_service.dart   # Data analysis functions
```

## Database Schema (Supabase)

```sql
-- Users table (extends Supabase auth.users)
profiles:
  - id (uuid, FK to auth.users)
  - full_name (text)
  - date_of_birth (date)
  - gender (text)
  - height (decimal) -- in cm
  - target_weight (decimal) -- in kg
  - created_at (timestamp)
  - updated_at (timestamp)

-- Weight records
weight_records:
  - id (uuid)
  - user_id (uuid, FK to profiles)
  - weight (decimal) -- in kg
  - bmi (decimal) -- calculated
  - recorded_at (timestamp)
  - notes (text, optional)
  - created_at (timestamp)

-- Goals
goals:
  - id (uuid)
  - user_id (uuid, FK to profiles)
  - target_weight (decimal)
  - target_date (date)
  - achieved (boolean)
  - created_at (timestamp)
  - updated_at (timestamp)
```

## Code Patterns

### Widget Structure
- Use StatelessWidget with Riverpod ConsumerWidget for reactive UI
- Implement responsive design using MediaQuery and LayoutBuilder
- Create reusable components for consistent UI

### State Management
- Use StateNotifier for complex state logic
- Implement AsyncValue for handling loading/error states
- Keep providers focused and single-purpose

### Data Flow
1. User inputs weight → Save to Supabase → Update local state
2. Fetch records → Calculate statistics → Display visualizations
3. Set goal → Track progress → Show achievements

### Error Handling
- Graceful error handling with user-friendly messages
- Offline capability with local caching
- Retry mechanisms for network failures

## Testing Strategy

- Unit tests for:
  - BMI calculation logic
  - Date/time utilities
  - Data models
- Widget tests for:
  - Custom widgets
  - Screen layouts
  - User interactions
- Integration tests for:
  - Authentication flow
  - Data synchronization
  - Complete user journeys

## Performance Considerations

- Lazy load weight records with pagination
- Cache calculated statistics
- Optimize character animations for smooth performance
- Minimize Supabase queries with efficient data fetching