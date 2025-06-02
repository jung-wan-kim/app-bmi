# 📱 TikTok Clone - Flutter

A TikTok clone app built with Flutter, featuring modern UI and video playback functionality.

## 🚀 Features

- ✨ Full-screen video feed with swipe navigation
- ❤️ Like, comment, and share functionality
- 📱 Bottom tab navigation (Home, Discover, Upload, Inbox, Me)
- 🎬 Video playback with pause/play on tap
- 🌈 TikTok-style upload button with gradient effect
- 👤 User profile with stats and content grid

## 🛠 Tech Stack

- **Flutter** 3.24.5
- **Dart** 3.0+
- **flutter_riverpod** - State Management
- **video_player** - Video Playback
- **supabase_flutter** - Backend Integration
- **cached_network_image** - Image Caching

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/jung-wan-kim/app-forge-flutter.git
cd app-forge-flutter

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📱 Supported Platforms

- iOS 11.0+
- Android 5.0+
- Web (experimental)

## 📂 Project Structure

```
lib/
├── main.dart              # App entry point
├── models/               # Data models
│   └── video_model.dart
├── screens/              # App screens
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── discover_screen.dart
│   ├── upload_screen.dart
│   ├── inbox_screen.dart
│   └── profile_screen.dart
└── widgets/              # Reusable widgets
    └── video_player_item.dart
```

## 🎨 Screenshots

(Add screenshots here)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

---

Built with ❤️ using Flutter