# 프로젝트 킥오프 회의록

## 회의 정보
- **일시**: 2024년 6월 16일
- **참석자**: 모든 RP (PM, UI/UX, Flutter, Backend, Data, Character, QA, DevOps)
- **목적**: BMI Tracker 프로젝트 시작 및 요구사항 공유

## 주요 결정사항

### 1. 인증 방식
- **결정**: Apple 로그인과 Google 로그인만 지원
- **이유**: 
  - 사용자 편의성 극대화
  - 개인정보 수집 최소화
  - 빠른 온보딩 프로세스
- **담당**: Backend Engineer + Flutter Developer

### 2. MVP 범위
**Phase 1에 포함될 기능**:
1. 온보딩 화면 (애니메이션 포함)
2. Apple/Google OAuth 로그인
3. 사용자 프로필 설정 (키, 목표 체중)
4. 체중 기록 CRUD
5. BMI 자동 계산
6. 기본 그래프 (최근 7일)

**Phase 2 이후로 연기**:
- BMI 캐릭터 시스템
- 상세 통계 분석
- 푸시 알림

### 3. 기술 스택 확정
- **Frontend**: Flutter 3.24.5
- **State Management**: Riverpod 2.4.9
- **Backend**: Supabase
- **Auth**: Supabase Auth (Apple/Google OAuth)
- **Charts**: fl_chart
- **CI/CD**: GitHub Actions

### 4. 개발 원칙
1. **모바일 우선**: iOS/Android 동시 개발
2. **보안 우선**: OAuth만 사용, 비밀번호 저장 안 함
3. **심플한 UX**: 3탭 이내 모든 기능 접근
4. **실시간 동기화**: Supabase Realtime 활용

## 각 RP별 즉시 시작 작업

### PM_COORDINATOR
- [x] 요구사항 정의서 작성
- [ ] 주간 스프린트 계획 수립
- [ ] JIRA/Notion 프로젝트 보드 설정

### UI_UX_DESIGNER  
- [ ] 로그인 화면 와이어프레임
- [ ] 메인 대시보드 와이어프레임
- [ ] 디자인 시스템 초안 (색상, 타이포그래피)

### BACKEND_ENGINEER
- [ ] Supabase 프로젝트 생성
- [ ] Apple/Google OAuth 설정
- [ ] 데이터베이스 스키마 구현

### FLUTTER_DEVELOPER
- [ ] 프로젝트 초기 설정
- [ ] 폴더 구조 생성
- [ ] 기본 라우팅 설정

### DATA_ANALYST
- [ ] BMI 계산 로직 설계
- [ ] 통계 알고리즘 정의

### CHARACTER_DESIGNER
- [ ] BMI 캐릭터 컨셉 스케치
- [ ] 체형별 기본 디자인 가이드

### QA_TESTER
- [ ] 테스트 계획서 초안
- [ ] 테스트 시나리오 작성

### DEVOPS_ENGINEER
- [ ] GitHub Actions 워크플로우 설정
- [ ] 환경 변수 관리 체계 구축

## 다음 단계
1. 각 RP는 할당된 작업 즉시 시작
2. 일일 스탠드업: 매일 오전 10시
3. 첫 스프린트 리뷰: 1주 후

## 리스크 및 대응
- **Apple 심사**: 가이드라인 철저히 준수
- **개인정보보호**: 최소 데이터 수집, 명확한 정책
- **성능**: 초기부터 최적화 고려

## 커뮤니케이션
- **메인 채널**: Slack #bmi-tracker
- **문서**: GitHub Wiki / Notion
- **코드 리뷰**: PR 필수, 2명 이상 승인