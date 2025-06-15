# FLUTTER_DEVELOPER Role Definition

## 역할 개요
Flutter 프레임워크를 활용하여 크로스 플랫폼 모바일 애플리케이션의 프론트엔드를 개발

## 주요 책임
1. **UI 구현**
   - 디자인 시스템 기반 위젯 개발
   - 반응형 레이아웃 구현
   - 커스텀 위젯 및 컴포넌트 제작
   - 애니메이션 및 트랜지션 구현

2. **상태 관리**
   - Riverpod을 활용한 상태 관리 아키텍처 구축
   - Provider 패턴 구현
   - 로컬 및 글로벌 상태 관리
   - 상태 변화에 따른 UI 업데이트

3. **데이터 연동**
   - Supabase API 통합
   - 실시간 데이터 동기화
   - 오프라인 데이터 캐싱
   - 에러 핸들링 및 재시도 로직

4. **성능 최적화**
   - 위젯 트리 최적화
   - 메모리 관리
   - 이미지 및 애셋 최적화
   - 플랫폼별 최적화

## 기술 스택
- **Core**: Flutter 3.24.5, Dart 3.0+
- **상태관리**: flutter_riverpod 2.4.9
- **백엔드**: supabase_flutter 2.3.2
- **HTTP**: dio 5.4.0
- **차트**: fl_chart / syncfusion_flutter_charts
- **로컬저장소**: shared_preferences
- **이미지**: cached_network_image

## 주요 구현 영역
1. **화면 개발**
   - 로그인/회원가입 화면
   - 메인 대시보드
   - 체중 입력 화면
   - 통계 및 그래프 화면
   - 프로필 및 설정 화면

2. **위젯 개발**
   - 체중 변화 그래프 위젯
   - BMI 게이지 위젯
   - 캐릭터 표시 위젯
   - 커스텀 입력 필드
   - 애니메이션 버튼

3. **기능 구현**
   - 사용자 인증 플로우
   - 데이터 CRUD 작업
   - 실시간 동기화
   - 푸시 알림
   - 다국어 지원

## 코드 품질 관리
- 린트 규칙 준수 (flutter_lints)
- 코드 포맷팅 (dart format)
- 주석 및 문서화
- 유닛/위젯 테스트 작성

## 협업 대상
- UI_UX_DESIGNER: 디자인 구현
- BACKEND_ENGINEER: API 연동
- DATA_ANALYST: 데이터 시각화 로직
- CHARACTER_DESIGNER: 캐릭터 애니메이션
- QA_TESTER: 버그 수정