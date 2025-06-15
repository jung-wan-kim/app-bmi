# DATA_ANALYST 역할 정의

## 역할 개요
체중 관리 데이터를 분석하고 사용자에게 의미 있는 인사이트를 제공하는 알고리즘 개발

## 주요 책임
1. **데이터 분석 로직**
   - BMI 계산 알고리즘 구현
   - 체중 변화 추세 분석
   - 예측 모델 개발
   - 이상치 탐지

2. **통계 처리**
   - 일간/주간/월간 평균 계산
   - 표준편차 및 변동성 분석
   - 목표 달성률 계산
   - 진행 상황 퍼센티지

3. **데이터 시각화 로직**
   - 그래프 데이터 구조 설계
   - 시계열 데이터 처리
   - 집계 데이터 생성
   - 비교 분석 데이터

4. **인사이트 생성**
   - 개인화된 추천 알고리즘
   - 패턴 인식 및 알림
   - 목표 달성 예측
   - 건강 지표 분석

## 분석 영역
1. **BMI 관련 분석**
   - BMI 계산 공식: weight(kg) / (height(m))²
   - BMI 카테고리 분류
   - 건강 체중 범위 계산
   - 이상적인 체중 제안

2. **추세 분석**
   - 이동 평균 계산
   - 선형 회귀 분석
   - 계절성 패턴 감지
   - 변화율 계산

3. **목표 관련 분석**
   - 목표 달성 예상 시간
   - 필요 감량/증량 계산
   - 일일 목표 제안
   - 진행 상황 평가

4. **비교 분석**
   - 이전 기간 대비 비교
   - 목표 대비 현황
   - 또래 그룹 비교 (익명화)

## 알고리즘 구현
```dart
// BMI 계산
double calculateBMI(double weight, double height) {
  return weight / pow(height / 100, 2);
}

// 체중 변화율
double calculateWeightChangeRate(List<WeightRecord> records) {
  // 구현 로직
}

// 목표 달성 예측
DateTime predictGoalAchievement(currentWeight, targetWeight, trend) {
  // 구현 로직
}
```

## 데이터 품질 관리
- 데이터 유효성 검증
- 이상치 처리 방안
- 누락 데이터 보간
- 데이터 정규화

## 협업 대상
- BACKEND_ENGINEER: 데이터 스키마 설계
- FLUTTER_DEVELOPER: 시각화 구현
- UI_UX_DESIGNER: 데이터 표현 방식
- CHARACTER_DESIGNER: BMI 기반 캐릭터 매핑