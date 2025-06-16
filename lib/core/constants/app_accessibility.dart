import 'package:flutter/material.dart';

/// 접근성 관련 상수
class AppAccessibility {
  // 최소 터치 타겟 크기 (WCAG 권장)
  static const double minTouchTarget = 48.0;
  
  // 최소 텍스트 크기
  static const double minTextSize = 14.0;
  
  // 컨트라스트 비율 (WCAG AA 기준)
  static const double minContrastRatio = 4.5;
  static const double minLargeTextContrastRatio = 3.0;
  
  // 시맨틱 라벨
  static const semanticLabels = {
    'weightInput': '체중 입력',
    'dateSelect': '날짜 선택',
    'timeSelect': '시간 선택',
    'saveWeight': '체중 저장',
    'deleteWeight': '체중 기록 삭제',
    'bmiCharacter': 'BMI 캐릭터',
    'chartView': '체중 변화 차트',
    'goalProgress': '목표 진행률',
    'themeToggle': '테마 전환',
    'languageToggle': '언어 전환',
    'backupData': '데이터 백업',
    'restoreData': '데이터 복원',
  };
  
  // 힌트 텍스트
  static const hints = {
    'weightInputHint': '체중을 숫자로 입력하세요. 예: 70.5',
    'dateSelectHint': '탭하여 날짜를 선택하세요',
    'timeSelectHint': '탭하여 시간을 선택하세요',
    'chartHint': '차트를 좌우로 스와이프하여 기간을 변경할 수 있습니다',
  };
  
  // 접근성 메시지
  static String getWeightChangeAnnouncement(double oldWeight, double newWeight) {
    final difference = newWeight - oldWeight;
    if (difference > 0) {
      return '체중이 ${difference.abs().toStringAsFixed(1)}kg 증가했습니다';
    } else if (difference < 0) {
      return '체중이 ${difference.abs().toStringAsFixed(1)}kg 감소했습니다';
    } else {
      return '체중 변화가 없습니다';
    }
  }
  
  static String getBMIAnnouncement(double bmi, String category) {
    return 'BMI ${bmi.toStringAsFixed(1)}, $category 범위입니다';
  }
  
  static String getGoalProgressAnnouncement(double progress) {
    return '목표 달성률 ${progress.toInt()}%';
  }
}