# BMI Tracker 배포 가이드

## 1. 환경 설정

### 1.1 필수 환경 변수
```bash
# .env 파일
SUPABASE_URL=https://rytrsmizujhkcegxabzv.supabase.co
SUPABASE_ANON_KEY=<anon_key>

# GitHub Secrets (CI/CD용)
GOOGLE_WEB_CLIENT_ID=<google_web_client_id>
GOOGLE_IOS_CLIENT_ID=<google_ios_client_id>
APPLE_SERVICE_ID=<apple_service_id>
APPLE_TEAM_ID=<apple_team_id>
APPLE_KEY_ID=<apple_key_id>
APPLE_REDIRECT_URL=<apple_redirect_url>
```

### 1.2 빌드 환경
- Flutter: 3.24.5
- Dart: 3.0+
- Java: 17 (Android)
- Xcode: 14+ (iOS)
- CocoaPods: 1.12+ (iOS)

## 2. 로컬 개발

### 2.1 초기 설정
```bash
# 의존성 설치
make setup

# 환경 변수 설정
make env-example
# .env 파일 편집
```

### 2.2 개발 서버 실행
```bash
# 디버그 모드
make run

# 릴리즈 모드
make run-release
```

### 2.3 코드 품질 체크
```bash
# 전체 체크
make check-all

# 개별 체크
make analyze
make test
make format
```

## 3. 빌드 프로세스

### 3.1 Android
```bash
# APK 빌드
make build-apk

# App Bundle 빌드 (Play Store용)
make build-appbundle
```

### 3.2 iOS
```bash
# iOS 앱 빌드
make build-ios

# IPA 빌드 (App Store용)
make build-ipa
```

## 4. CI/CD 파이프라인

### 4.1 자동화된 워크플로우
- **PR Check**: 모든 PR에 대해 코드 품질 검사
- **Flutter CI/CD**: main/develop 브랜치 푸시 시 빌드 및 테스트
- **Release**: main 브랜치 푸시 시 자동 릴리즈 생성

### 4.2 수동 배포 프로세스
1. 버전 업데이트 (pubspec.yaml)
2. 변경사항 커밋
3. 태그 생성: `git tag v1.0.0`
4. 푸시: `git push origin main --tags`

## 5. 스토어 배포

### 5.1 Google Play Store
1. Google Play Console 접속
2. App Bundle (.aab) 업로드
3. 릴리즈 노트 작성
4. 단계적 출시 설정
5. 검토 및 게시

### 5.2 Apple App Store
1. App Store Connect 접속
2. Xcode 또는 Transporter로 IPA 업로드
3. 앱 정보 및 스크린샷 업데이트
4. 릴리즈 노트 작성
5. 심사 제출

## 6. 모니터링

### 6.1 크래시 리포트
- Firebase Crashlytics 대시보드 확인
- Sentry 에러 추적

### 6.2 성능 모니터링
- Firebase Performance Monitoring
- 앱 시작 시간, API 응답 시간 추적

### 6.3 사용자 분석
- Firebase Analytics
- 사용자 행동, 리텐션 분석

## 7. 롤백 절차

### 7.1 긴급 롤백
1. 이전 버전 태그 체크아웃
2. 핫픽스 브랜치 생성
3. 수정 후 긴급 배포

### 7.2 스토어 롤백
- Google Play: 이전 버전 재활성화
- App Store: 새 버전으로 수정 후 재제출

## 8. 보안 체크리스트

- [ ] API 키 하드코딩 여부 확인
- [ ] ProGuard/R8 규칙 설정 (Android)
- [ ] 인증서 핀닝 구현
- [ ] 민감한 데이터 암호화
- [ ] 보안 헤더 설정

## 9. 트러블슈팅

### 9.1 빌드 실패
```bash
# Flutter 캐시 정리
flutter clean
flutter pub cache repair

# iOS 문제
cd ios && pod deintegrate && pod install
```

### 9.2 서명 문제
- Android: keystore 파일 및 key.properties 확인
- iOS: 프로비저닝 프로파일 및 인증서 확인

## 10. 연락처

- DevOps 팀: devops@bmitracker.com
- 긴급 연락처: +82-10-XXXX-XXXX