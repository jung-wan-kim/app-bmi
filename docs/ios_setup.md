# iOS 개발 환경 설정

## Development Team 설정

### 방법 1: Xcode에서 설정 (권장)

1. **Xcode에서 프로젝트 열기**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Runner 타겟 선택**
   - 좌측 네비게이터에서 Runner 프로젝트 클릭
   - TARGETS에서 Runner 선택

3. **Signing & Capabilities 탭**
   - Team 드롭다운에서 개발 팀 선택
   - "Automatically manage signing" 체크박스 선택
   - Bundle Identifier 확인: `com.bmitracker.app`

### 방법 2: 커맨드 라인에서 설정

1. **개발 팀 ID 확인**
   ```bash
   security find-identity -p codesigning -v | grep "Apple Development"
   ```

2. **xcconfig 파일 생성**
   ```bash
   echo "DEVELOPMENT_TEAM = YOUR_TEAM_ID" > ios/Flutter/DevelopmentTeam.local.xcconfig
   ```

3. **Flutter 실행**
   ```bash
   flutter run -d 00008101-000614643678001E
   ```

## 일반적인 문제 해결

### "Signing for Runner requires a development team" 오류

1. Xcode에서 Team을 선택하지 않은 경우
2. Apple Developer 계정이 Xcode에 로그인되어 있지 않은 경우
3. 무료 Apple ID를 사용하는 경우 일부 제한이 있을 수 있음

### 실제 기기 실행 시 "Could not launch" 오류

1. 기기에서 Settings > General > Device Management
2. 개발자 앱 신뢰 설정
3. 앱 재실행

## 프로비저닝 프로파일

- 자동 서명을 사용하면 Xcode가 자동으로 관리
- 수동 서명 시 Apple Developer Portal에서 생성 필요

## Bundle Identifier

현재 설정: `com.bmitracker.app`

변경이 필요한 경우:
1. Xcode에서 Bundle Identifier 수정
2. `ios/Runner.xcodeproj/project.pbxproj` 파일에서 PRODUCT_BUNDLE_IDENTIFIER 수정