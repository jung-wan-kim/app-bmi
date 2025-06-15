# Supabase Google OAuth 설정 가이드

## Supabase Dashboard 설정

1. **Supabase Dashboard 접속**
   - URL: https://supabase.com/dashboard
   - 프로젝트 선택: `rytrsmizujhkcegxabzv` (BMI Tracker)

2. **Authentication > Providers 이동**
   - 왼쪽 사이드바에서 `Authentication` 클릭
   - 상단 탭에서 `Providers` 선택

3. **Google Provider 설정**
   - Google 항목 찾아서 `Enable` 토글 ON
   - 다음 정보 입력:

### Google OAuth 클라이언트 정보

**Authorized Client IDs** (쉼표로 구분하여 모두 입력):
```
1044566673280-do2e4djvupar175pb91eujbi4jjjeo0e.apps.googleusercontent.com,
1044566673280-m9hipqat2gam4djgfo7aireb2kfv1iad.apps.googleusercontent.com
```

### Google Cloud Console 설정

1. **Google Cloud Console 접속**
   - https://console.cloud.google.com
   - 프로젝트 선택 또는 생성

2. **OAuth 동의 화면 설정**
   - APIs & Services > OAuth consent screen
   - 앱 이름: BMI Tracker
   - 사용자 지원 이메일 설정
   - 승인된 도메인: `supabase.co`

3. **리디렉션 URI 추가**
   - APIs & Services > Credentials
   - 각 OAuth 2.0 클라이언트 ID 클릭하여 수정
   - Authorized redirect URIs에 추가:
   ```
   https://rytrsmizujhkcegxabzv.supabase.co/auth/v1/callback
   ```

## 클라이언트 ID 정보

- **iOS 클라이언트 ID**: 
  ```
  1044566673280-do2e4djvupar175pb91eujbi4jjjeo0e.apps.googleusercontent.com
  ```

- **Android 클라이언트 ID**: 
  ```
  1044566673280-m9hipqat2gam4djgfo7aireb2kfv1iad.apps.googleusercontent.com
  ```
  - Package name: `com.bmitracker.app`
  - SHA-1: `08:0E:3A:A3:43:75:0C:4D:8C:FB:5E:11:12:92:EC:57:F8:3A:9C:5F`

## 테스트 방법

1. Flutter 앱 실행
2. 로그인 화면에서 "Sign in with Google" 버튼 클릭
3. Google 계정 선택
4. 권한 승인
5. 앱으로 리디렉션되어 로그인 완료

## 주의사항

- Supabase Dashboard에서 반드시 두 클라이언트 ID를 모두 등록해야 함
- Google Cloud Console에서 Supabase 콜백 URL을 정확히 설정해야 함
- 프로덕션 배포 시 OAuth 동의 화면 검증 필요