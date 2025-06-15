# Supabase 프로젝트 설정 가이드

## 1. 프로젝트 정보
- **Project URL**: https://rytrsmizujhkcegxabzv.supabase.co
- **Anon Key**: 제공됨 (main.dart에 설정 완료)

## 2. 데이터베이스 스키마
체중관리 앱을 위한 테이블 구조:

### 2.1 profiles 테이블
- auth.users를 확장하는 사용자 프로필
- 성별, 생년월일, 키, 목표 체중 저장

### 2.2 weight_records 테이블
- 사용자의 체중 기록
- BMI 자동 계산 함수 포함
- 날짜별 정렬을 위한 인덱스

### 2.3 goals 테이블
- 사용자의 목표 체중 및 달성 일자
- 달성 여부 추적

### 2.4 user_preferences 테이블
- 앱 설정 (알림, 단위, 테마, 언어)
- 온보딩 완료 여부

## 3. OAuth 설정 필요 사항

### 3.1 Apple Sign In
1. Supabase Dashboard > Authentication > Providers
2. Apple Provider 활성화
3. 필요한 정보:
   - Service ID
   - Team ID
   - Key ID
   - Private Key

### 3.2 Google Sign In
1. Google Cloud Console에서 OAuth 2.0 클라이언트 생성
2. Supabase Dashboard > Authentication > Providers
3. Google Provider 활성화
4. Client ID와 Client Secret 입력

## 4. Row Level Security (RLS)
모든 테이블에 RLS 적용:
- 사용자는 자신의 데이터만 접근 가능
- auth.uid()를 사용한 정책 구현

## 5. 자동화 기능
- 신규 사용자 가입 시 자동으로 profile 생성
- BMI 계산 함수 (calculate_bmi)
- updated_at 자동 업데이트 트리거

## 6. 다음 단계
1. Supabase Dashboard에서 SQL Editor 열기
2. migrations/001_app_forge_schema.sql 실행
3. Authentication > Providers에서 OAuth 설정
4. Storage 버킷 생성 (프로필 이미지용 - 추후)

## 7. 환경 변수 관리
- .env.example 파일 참조
- 실제 .env 파일은 .gitignore에 추가
- OAuth 키는 안전하게 관리