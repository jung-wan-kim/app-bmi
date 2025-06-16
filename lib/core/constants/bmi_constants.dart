class BMIConstants {
  // BMI 카테고리 임계값
  static const double underweightThreshold = 18.5;
  static const double normalThreshold = 25.0;
  static const double overweightThreshold = 30.0;
  
  // BMI 범위
  static const double minBMI = 10.0;
  static const double maxBMI = 50.0;
  
  // 정상 BMI 범위
  static const double normalMinBMI = 18.5;
  static const double normalMaxBMI = 24.9;
  
  // 이상적인 BMI
  static const double idealBMI = 22.0;
}

enum BMICategory {
  underweight,
  normal,
  overweight,
  obese,
}

extension BMICategoryExtension on BMICategory {
  String get displayName {
    switch (this) {
      case BMICategory.underweight:
        return '저체중';
      case BMICategory.normal:
        return '정상';
      case BMICategory.overweight:
        return '과체중';
      case BMICategory.obese:
        return '비만';
    }
  }

  String get description {
    switch (this) {
      case BMICategory.underweight:
        return '체중이 정상 범위보다 낮습니다';
      case BMICategory.normal:
        return '건강한 체중 범위입니다';
      case BMICategory.overweight:
        return '체중이 정상 범위보다 높습니다';
      case BMICategory.obese:
        return '건강 관리가 필요한 체중입니다';
    }
  }

  String get healthAdvice {
    switch (this) {
      case BMICategory.underweight:
        return '균형 잡힌 식사와 적절한 운동으로 건강한 체중을 유지하세요';
      case BMICategory.normal:
        return '현재 체중을 유지하며 건강한 생활 습관을 계속하세요';
      case BMICategory.overweight:
        return '식단 조절과 규칙적인 운동으로 건강한 체중을 목표로 하세요';
      case BMICategory.obese:
        return '전문가와 상담하여 체계적인 체중 관리를 시작하세요';
    }
  }
}