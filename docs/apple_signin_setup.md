# Apple Sign In 설정 가이드

## 사전 요구사항
- Apple Developer 계정 (유료, 연간 $99)
- Xcode 설치
- Bundle ID: `com.bmitracker.app`

## 1. Apple Developer Console 설정

### 1.1 App ID 생성/수정
1. **Apple Developer Console 접속**
   - https://developer.apple.com/account
   - Certificates, Identifiers & Profiles 선택

2. **Identifiers 섹션**
   - Identifiers 클릭
   - 기존 App ID 선택 또는 새로 생성 (+버튼)
   - Bundle ID: `com.bmitracker.app`

3. **Sign In with Apple 활성화**
   - Capabilities에서 "Sign In with Apple" 체크
   - Save 클릭

### 1.2 Service ID 생성 (웹 지원용)
1. **Identifiers > Services IDs**
   - + 버튼 클릭하여 새 Service ID 생성
   - Description: `BMI Tracker Web`
   - Identifier: `com.bmitracker.app.web`

2. **Sign In with Apple 설정**
   - "Sign In with Apple" 체크
   - Configure 버튼 클릭

3. **도메인 및 리디렉션 URL 설정**
   - Primary App ID: `com.bmitracker.app` 선택
   - Domains and Subdomains:
     ```
     rytrsmizujhkcegxabzv.supabase.co
     ```
   - Return URLs:
     ```
     https://rytrsmizujhkcegxabzv.supabase.co/auth/v1/callback
     ```
   - Save 클릭

### 1.3 Key 생성
1. **Keys 섹션**
   - + 버튼 클릭
   - Key Name: `BMI Tracker Auth Key`
   - "Sign In with Apple" 체크

2. **Configure**
   - Primary App ID: `com.bmitracker.app` 선택
   - Save

3. **Key 다운로드**
   - Continue > Register
   - Download 클릭 (`.p8` 파일)
   - **중요**: 이 파일은 한 번만 다운로드 가능하므로 안전하게 보관

4. **Key 정보 기록**
   - Key ID: `XXXXXXXXXX` (10자리)
   - Team ID: `XXXXXXXXXX` (10자리)

## 2. Xcode 프로젝트 설정

### 2.1 Capability 추가
1. **Xcode에서 프로젝트 열기**
   ```bash
   cd /Users/jung-wankim/Project/app-bmi/ios
   open Runner.xcworkspace
   ```

2. **Signing & Capabilities**
   - Runner 타겟 선택
   - Signing & Capabilities 탭
   - + Capability 버튼 클릭
   - "Sign In with Apple" 추가

### 2.2 Info.plist 수정
`ios/Runner/Info.plist`에 이미 기본 설정이 되어 있지만, 추가 설정이 필요한 경우:

```xml
<key>CFBundleURLTypes</key>
<array>
    <!-- 기존 Google Sign In 설정 -->
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.1044566673280-do2e4djvupar175pb91eujbi4jjjeo0e</string>
        </array>
    </dict>
    <!-- Apple Sign In은 별도 URL Scheme 불필요 -->
</array>
```

## 3. Supabase Dashboard 설정

### 3.1 Apple Provider 활성화
1. **Supabase Dashboard 접속**
   - https://supabase.com/dashboard
   - 프로젝트: `rytrsmizujhkcegxabzv`

2. **Authentication > Providers > Apple**
   - Enable 토글 ON

3. **설정 정보 입력**
   - **Secret Key**: 다운로드한 `.p8` 파일의 내용 전체 복사
     ```
     -----BEGIN PRIVATE KEY-----
     [키 내용]
     -----END PRIVATE KEY-----
     ```
   - **Key ID**: Apple Developer Console에서 확인한 10자리 Key ID
   - **Team ID**: Apple Developer Console에서 확인한 10자리 Team ID
   - **Bundle ID**: `com.bmitracker.app`
   - **Service ID** (웹용): `com.bmitracker.app.web`

4. **Save** 클릭

## 4. Flutter 코드 확인

`lib/services/auth_service.dart`의 Apple Sign In 구현이 이미 완료되어 있음:

```dart
Future<AuthResponse?> signInWithApple() async {
  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    
    final idToken = credential.identityToken;
    if (idToken == null) {
      throw 'Unable to get identity token from Apple Sign In';
    }
    
    return await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
    );
  } catch (e) {
    print('Error signing in with Apple: $e');
    return null;
  }
}
```

## 5. 테스트 방법

### iOS 실제 기기 테스트
1. **실제 iPhone/iPad 필요** (시뮬레이터에서는 Apple Sign In 테스트 불가)
2. 기기를 Mac에 연결
3. Xcode에서 기기 선택 후 실행
4. 로그인 화면에서 "Sign in with Apple" 버튼 탭
5. Face ID/Touch ID 또는 암호로 인증
6. 이메일 공유 옵션 선택
7. 로그인 완료

### 주의사항
- Apple Sign In은 iOS 13.0 이상에서만 지원
- 시뮬레이터에서는 테스트 불가 (실제 기기 필요)
- 첫 로그인 시에만 이메일과 이름 정보 제공
- 사용자가 이메일 숨기기를 선택하면 `@privaterelay.appleid.com` 형식의 프록시 이메일 제공

## 6. 프로덕션 체크리스트

- [ ] Apple Developer 계정 활성화
- [ ] App ID에 Sign In with Apple capability 추가
- [ ] Service ID 생성 (웹 지원 시)
- [ ] Auth Key 생성 및 안전하게 보관
- [ ] Supabase Dashboard에 설정 정보 입력
- [ ] Xcode 프로젝트에 capability 추가
- [ ] 실제 기기에서 테스트 완료
- [ ] App Store 심사 제출 시 Sign In with Apple 사용 명시

## 7. 트러블슈팅

### "Sign In with Apple" 버튼이 보이지 않음
- iOS 버전 확인 (13.0 이상)
- Xcode capability 추가 확인
- Bundle ID 일치 확인

### 로그인 실패
- Supabase Dashboard의 Apple 설정 확인
- Key ID, Team ID, Bundle ID 정확성 확인
- Service ID가 웹에서 사용 중인지 확인

### 이메일 정보를 받지 못함
- 첫 로그인이 아닌 경우 정상 (Apple은 첫 로그인 시에만 제공)
- Supabase의 user 테이블에서 기존 정보 확인