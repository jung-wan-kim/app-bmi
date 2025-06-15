# BMI Tracker - 체중 관리 앱

<p align="center">
  <img src="assets/images/app_icon.png" width="200" alt="BMI Tracker Logo">
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.24.5-blue.svg" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.0+-blue.svg" alt="Dart"></a>
  <a href="https://supabase.com"><img src="https://img.shields.io/badge/Supabase-2.3.2-green.svg" alt="Supabase"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License"></a>
</p>

## 📱 소개

BMI Tracker는 사용자의 체중과 BMI를 관리하고 추적하는 Flutter 기반 모바일 애플리케이션입니다. 직관적인 UI와 귀여운 캐릭터로 건강한 체중 관리를 도와드립니다.

### 주요 기능

- 📊 **체중 및 BMI 추적**: 일간/주간/월간 차트로 변화 추이 확인
- 🎯 **목표 설정**: 목표 체중 설정 및 진행 상황 모니터링
- 🐻 **BMI 캐릭터**: BMI 수치에 따라 변하는 귀여운 캐릭터
- 🔐 **소셜 로그인**: Google/Apple 계정으로 간편 로그인
- 📱 **크로스 플랫폼**: iOS, Android, 웹 지원

## 🚀 시작하기

### 사전 요구사항

- Flutter 3.24.5 이상
- Dart 3.0 이상
- iOS 개발을 위한 Xcode (Mac)
- Android 개발을 위한 Android Studio

### 설치

1. **저장소 클론**
```bash
git clone https://github.com/jung-wan-kim/app-bmi.git
cd app-bmi
```

2. **환경 변수 설정**
```bash
cp .env.example .env
# .env 파일을 열어 필요한 값 입력
```

3. **의존성 설치**
```bash
flutter pub get
```

4. **iOS 설정 (Mac에서만)**
```bash
cd ios
pod install
cd ..
```

### 환경 설정

`.env` 파일에 다음 정보를 입력하세요:

```env
# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Google OAuth
GOOGLE_CLIENT_ID_IOS=your_ios_client_id
GOOGLE_CLIENT_ID_ANDROID=your_android_client_id

# Environment
ENVIRONMENT=development
```

자세한 설정 방법은 [환경 설정 가이드](docs/environment_setup.md)를 참조하세요.

## 🏃‍♂️ 실행

### 웹에서 실행
```bash
flutter run -d chrome
```

### iOS 시뮬레이터에서 실행
```bash
flutter run -d ios
```

### Android 에뮬레이터에서 실행
```bash
flutter run -d android
```

### 실제 기기에서 실행
```bash
flutter devices  # 연결된 기기 확인
flutter run -d [device_id]
```

## 📚 문서

- [CLAUDE.md](CLAUDE.md) - AI 코드 어시스턴트를 위한 프로젝트 가이드
- [환경 설정 가이드](docs/environment_setup.md)
- [Google OAuth 설정](docs/supabase_google_oauth_setup.md)
- [Apple Sign In 설정](docs/apple_signin_setup.md)
- [테스트 가이드](test_guide.md)
- [요구사항 문서](docs/requirements.md)

## 🏗️ 프로젝트 구조

```
lib/
├── config/          # 설정 파일
├── core/           # 핵심 유틸리티
│   ├── constants/  # 상수 정의
│   ├── router/     # 라우팅 설정
│   ├── theme/      # 테마 설정
│   └── utils/      # 유틸리티 함수
├── models/         # 데이터 모델
├── screens/        # 화면 위젯
│   ├── auth/       # 인증 관련 화면
│   └── onboarding/ # 온보딩 화면
├── services/       # 비즈니스 로직
└── main.dart       # 앱 진입점
```

## 🛠️ 기술 스택

- **Frontend**: Flutter 3.24.5
- **State Management**: Riverpod 2.4.9
- **Backend**: Supabase 2.3.2
- **Authentication**: Google Sign In, Sign in with Apple
- **Charts**: fl_chart 0.69.0
- **Animations**: Lottie 3.1.0
- **Navigation**: go_router 14.8.1

## 👥 개발 팀 (RP 구조)

프로젝트는 Role Playing 기반 협업 구조로 개발되었습니다:

- **PM_COORDINATOR**: 프로젝트 관리 및 조정
- **UI_UX_DESIGNER**: UI/UX 디자인
- **FLUTTER_DEVELOPER**: Flutter 앱 개발
- **BACKEND_ENGINEER**: 백엔드 및 데이터베이스
- **CHARACTER_DESIGNER**: BMI 캐릭터 디자인
- **DATA_ANALYST**: 데이터 분석 및 차트
- **QA_TESTER**: 품질 보증 및 테스트
- **DEVOPS_ENGINEER**: CI/CD 및 배포

자세한 내용은 [RP 아키텍처 문서](.rp/RP_ARCHITECTURE.md)를 참조하세요.

## 🧪 테스트

```bash
# 단위 테스트 실행
flutter test

# 테스트 커버리지 확인
flutter test --coverage
```

## 📦 빌드

### Android APK 빌드
```bash
flutter build apk --release
```

### iOS 빌드 (Mac에서만)
```bash
flutter build ios --release
```

### 웹 빌드
```bash
flutter build web --release
```

## 🤝 기여하기

프로젝트에 기여하고 싶으시다면:

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 📞 연락처

- GitHub: [@jung-wan-kim](https://github.com/jung-wan-kim)
- Project Link: [https://github.com/jung-wan-kim/app-bmi](https://github.com/jung-wan-kim/app-bmi)

## 🙏 감사의 말

- [Flutter](https://flutter.dev) - UI 프레임워크
- [Supabase](https://supabase.com) - 백엔드 서비스
- [Claude Code](https://claude.ai/code) - AI 코드 어시스턴트

---

<p align="center">Made with ❤️ by BMI Tracker Team</p>