# 📱 TikTok Clone - Multi-Platform App

Flutter, React Native(Expo), 그리고 네이티브 플랫폼을 지원하는 TikTok 클론 앱 프로젝트입니다.

## 🎯 프로젝트 개요

이 프로젝트는 TikTok 클론 앱을 다양한 플랫폼에서 구현한 멀티 플랫폼 프로젝트입니다:
- **Flutter**: Cross-platform 네이티브 성능
- **React Native (Expo)**: JavaScript 기반 크로스 플랫폼
- **Native iOS/Android**: 플랫폼별 최적화

## 🚀 주요 기능

- ✨ 전체 화면 비디오 피드 (스와이프 네비게이션)
- ❤️ 좋아요, 댓글, 공유 기능
- 🎨 커스텀 SVG 아이콘 (Figma 디자인 기반)
- 📱 하단 탭 네비게이션 (Home, Discover, Upload, Inbox, Me)
- 🎬 비디오 재생/일시정지 (탭 제스처)
- 🌈 TikTok 스타일 업로드 버튼 (그라데이션 효과)

## 🛠 기술 스택

### Flutter 버전
- **Flutter** 3.0+
- **Dart** 
- **flutter_riverpod** - 상태 관리
- **video_player** - 비디오 재생
- **Supabase Flutter** - 백엔드 연동

### React Native (Expo) 버전
- **Expo** SDK 51
- **React Native** 0.76.5
- **React Navigation** - 네비게이션
- **Expo AV** - 비디오 플레이어
- **React Native SVG** - 벡터 그래픽
- **Supabase** - 백엔드 (Database, Auth, Storage)
- **Expo Secure Store** - 안전한 데이터 저장

## 📦 설치 및 실행

### Flutter 버전
```bash
# 의존성 설치
flutter pub get

# iOS 실행
flutter run -d ios

# Android 실행
flutter run -d android

# 웹 실행
flutter run -d chrome
```

### React Native (Expo) 버전
```bash
# 의존성 설치
npm install

# Expo 개발 서버 시작
npm start

# iOS 시뮬레이터에서 실행
npm run ios

# Android 에뮬레이터에서 실행
npm run android

# 웹 브라우저에서 실행
npm run web
```

## 📱 프로젝트 구조

### Flutter 구조
```
├── lib/
│   ├── main.dart           # 앱 진입점
│   ├── screens/            # 화면 위젯
│   │   ├── main_screen.dart
│   │   ├── home_screen.dart
│   │   ├── discover_screen.dart
│   │   ├── upload_screen.dart
│   │   ├── inbox_screen.dart
│   │   └── profile_screen.dart
│   ├── widgets/            # 재사용 위젯
│   │   └── video_player_item.dart
│   └── models/             # 데이터 모델
│       └── video_model.dart
├── pubspec.yaml            # Flutter 의존성
└── assets/                 # 정적 리소스
```

### React Native (Expo) 구조
```
├── App.js                  # 메인 앱 컴포넌트
├── src/
│   ├── screens/           # 화면 컴포넌트
│   │   ├── HomeScreen.js
│   │   ├── DiscoverScreen.js
│   │   ├── UploadScreen.js
│   │   ├── InboxScreen.js
│   │   └── ProfileScreen.js
│   ├── components/        # 재사용 컴포넌트
│   │   ├── VideoPlayer.js
│   │   ├── ActionButton.js
│   │   └── icons/        # SVG 아이콘
│   └── config/           # 설정 파일
│       └── supabase.js
├── assets/               # 정적 리소스
├── app.json             # Expo 설정
└── package.json         # 프로젝트 의존성
```

## 🔧 환경 설정

Supabase 연동을 위해 `src/config/supabase.js` 파일에 환경 변수가 설정되어 있습니다.

## 🎨 디자인

모든 UI 컴포넌트는 Figma 채널 aopzqj84를 기반으로 구현되었으며, 다음 특징을 포함합니다:
- 커스텀 SVG 아이콘
- TikTok 스타일 그라데이션 업로드 버튼
- 다크 테마 UI
- 네이티브 제스처 지원

## 🤝 기여하기

이슈와 풀 리퀘스트는 언제나 환영합니다!

## 📄 라이선스

MIT License

---

**Built with ❤️ using Expo**