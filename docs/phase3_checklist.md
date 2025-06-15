# Phase 3: 핵심 기능 구현 체크리스트

## 🎯 목표
데모 모드에서 완전히 작동하는 체중 관리 앱 구현

## ✅ 작업 목록

### 1. 체중 입력 기능 (task-137)
- [ ] WeightInputScreen UI 완성
  - [ ] 숫자 키패드 UI
  - [ ] 체중 입력 필드
  - [ ] 날짜 선택기
  - [ ] 메모 입력 필드
- [ ] 데이터 저장 로직
  - [ ] 데모 모드: SharedPreferences 저장
  - [ ] 실제 모드: Supabase 저장
- [ ] 입력 유효성 검사
  - [ ] 체중 범위 확인 (20kg ~ 300kg)
  - [ ] 날짜 중복 확인

### 2. 체중 기록 히스토리 (task-138)
- [ ] 체중 기록 리스트 UI
  - [ ] 날짜별 정렬
  - [ ] 체중 변화 표시 (증가/감소)
  - [ ] BMI 표시
- [ ] 기록 관리 기능
  - [ ] 스와이프하여 삭제
  - [ ] 기록 수정
- [ ] 빈 상태 UI

### 3. 통계 차트 구현 (task-139)
- [ ] 차트 기간 선택
  - [ ] 일간 (7일)
  - [ ] 주간 (4주)
  - [ ] 월간 (6개월)
- [ ] fl_chart 그래프
  - [ ] 라인 차트
  - [ ] 목표 체중 라인
  - [ ] 터치 인터랙션
- [ ] 통계 요약
  - [ ] 평균 체중
  - [ ] 총 변화량
  - [ ] 목표까지 남은 체중

### 4. BMI 캐릭터 시스템 (task-140)
- [ ] BMI 단계별 캐릭터
  - [ ] 저체중 (BMI < 18.5)
  - [ ] 정상 (18.5 ≤ BMI < 25)
  - [ ] 과체중 (25 ≤ BMI < 30)
  - [ ] 비만 (30 ≤ BMI < 35)
  - [ ] 고도비만 (BMI ≥ 35)
- [ ] 캐릭터 애니메이션
  - [ ] 기본 대기 동작
  - [ ] 체중 감소 시 축하
  - [ ] 체중 증가 시 격려

### 5. 목표 설정 기능 (task-141)
- [ ] 목표 설정 UI
  - [ ] 목표 체중 입력
  - [ ] 목표 날짜 선택
  - [ ] 주간 목표 설정
- [ ] 진행 상황 추적
  - [ ] 진행률 표시
  - [ ] 예상 달성 날짜
  - [ ] 권장 일일 변화량

### 6. 알림 기능 (task-142)
- [ ] 알림 설정 UI
  - [ ] 알림 시간 선택
  - [ ] 알림 켜기/끄기
  - [ ] 알림 메시지 커스터마이징
- [ ] 로컬 알림 구현
  - [ ] flutter_local_notifications 설정
  - [ ] iOS/Android 권한 요청
  - [ ] 알림 스케줄링

### 7. 설정 화면 (task-143)
- [ ] 프로필 관리
  - [ ] 이름 변경
  - [ ] 키 변경
  - [ ] 성별 변경
  - [ ] 생년월일 변경
- [ ] 앱 설정
  - [ ] 단위 변경 (kg ↔ lb, cm ↔ ft)
  - [ ] 언어 설정 (한국어/영어)
  - [ ] 테마 설정 (라이트/다크/시스템)
- [ ] 데이터 관리
  - [ ] 데이터 내보내기
  - [ ] 데이터 초기화
  - [ ] 계정 연동 (데모 → 실제)

## 🔧 기술적 구현 사항

### 데이터 모델
```dart
class WeightRecord {
  final String id;
  final double weight;
  final double bmi;
  final DateTime recordedAt;
  final String? notes;
}

class Goal {
  final double targetWeight;
  final DateTime? targetDate;
  final double weeklyTarget;
}
```

### 상태 관리 (Riverpod)
- WeightRecordsProvider
- GoalsProvider
- SettingsProvider
- CharacterProvider

### 로컬 저장소 구조
```json
{
  "weight_records": [...],
  "goals": {...},
  "settings": {...},
  "last_sync": "2025-01-15T10:00:00Z"
}
```

## 📋 완료 기준
- [ ] 모든 기능이 데모 모드에서 정상 작동
- [ ] 데이터가 앱 재시작 후에도 유지
- [ ] UI/UX가 직관적이고 반응적
- [ ] 에러 처리 및 유효성 검사 완료
- [ ] 코드 리뷰 및 리팩토링 완료

## 🚀 다음 단계
Phase 3 완료 후 Phase 4 (데이터 동기화) 진행