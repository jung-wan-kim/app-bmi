# 환경 변수 설정 가이드

## .env 파일 생성

프로젝트 루트에 `.env` 파일을 생성하고 다음 내용을 입력하세요:

```bash
# .env.example을 복사하여 .env 파일 생성
cp .env.example .env
```

## 필수 환경 변수

### 1. Supabase 설정
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### 2. Google OAuth 설정
```env
GOOGLE_CLIENT_ID_IOS=your-ios-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_ID_ANDROID=your-android-client-id.apps.googleusercontent.com
```

### 3. 환경 설정
```env
ENVIRONMENT=development  # development, staging, production
```

## 환경 변수 획득 방법

### Supabase
1. [Supabase Dashboard](https://supabase.com/dashboard) 접속
2. 프로젝트 선택
3. Settings > API
4. Project URL과 anon key 복사

### Google OAuth
1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. APIs & Services > Credentials
3. OAuth 2.0 Client IDs 생성
   - iOS용: iOS 애플리케이션 타입
   - Android용: Android 애플리케이션 타입 (SHA-1 필요)

## Flutter에서 환경 변수 사용

Flutter는 기본적으로 .env 파일을 읽지 않으므로, 다음과 같이 사용합니다:

### 1. 컴파일 시점 환경 변수 (추천)
```bash
flutter run \
  --dart-define=GOOGLE_CLIENT_ID_IOS=your-ios-client-id \
  --dart-define=GOOGLE_CLIENT_ID_ANDROID=your-android-client-id
```

### 2. 코드에서 사용
```dart
const String googleClientIdIOS = String.fromEnvironment(
  'GOOGLE_CLIENT_ID_IOS',
  defaultValue: 'default-value',
);
```

## 보안 주의사항

1. **절대로 .env 파일을 Git에 커밋하지 마세요**
   - `.gitignore`에 `.env`가 포함되어 있는지 확인

2. **프로덕션 환경**
   - 실제 서비스에서는 환경 변수를 서버나 CI/CD에서 주입
   - GitHub Secrets, Vercel Environment Variables 등 사용

3. **키 로테이션**
   - 정기적으로 API 키 갱신
   - 노출된 경우 즉시 재발급

## 플랫폼별 추가 설정

### iOS
`ios/Runner/Info.plist`에 Google Sign In URL Scheme 추가:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### Android
`android/app/src/main/AndroidManifest.xml`은 추가 설정 불필요
(Google Sign In 패키지가 자동으로 처리)

## 문제 해결

### "Invalid OAuth client" 오류
- Client ID가 올바른지 확인
- Bundle ID/Package name이 일치하는지 확인
- Supabase Dashboard에 Client ID가 등록되어 있는지 확인

### 로그인 팝업이 나타나지 않음
- 웹: localhost가 아닌 127.0.0.1 사용
- iOS: 실제 기기에서 테스트
- URL Scheme이 올바르게 설정되어 있는지 확인