import 'dart:math';
import '../constants/app_constants.dart';

/// BMI 계산 및 관련 유틸리티
class BMICalculator {
  /// BMI 계산
  /// weight: 체중 (kg)
  /// height: 키 (cm)
  static double calculateBMI(double weight, double height) {
    if (height <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / pow(heightInMeters, 2);
  }
  
  /// BMI 카테고리 반환
  static BMICategory getBMICategory(double bmi) {
    if (bmi < AppConstants.bmiUnderweight) {
      return BMICategory.underweight;
    } else if (bmi <= AppConstants.bmiNormal) {
      return BMICategory.normal;
    } else if (bmi <= AppConstants.bmiOverweight) {
      return BMICategory.overweight;
    } else {
      return BMICategory.obese;
    }
  }
  
  /// BMI 카테고리 한글 이름
  static String getCategoryName(BMICategory category) {
    switch (category) {
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
  
  /// BMI 카테고리 설명
  static String getCategoryDescription(BMICategory category) {
    switch (category) {
      case BMICategory.underweight:
        return '체중이 낮은 편입니다. 균형 잡힌 식단으로 건강한 체중을 목표로 하세요.';
      case BMICategory.normal:
        return '건강한 체중을 유지하고 있습니다. 꾸준한 관리로 건강을 지키세요!';
      case BMICategory.overweight:
        return '체중이 약간 높은 편입니다. 규칙적인 운동과 식단 관리를 시작해보세요.';
      case BMICategory.obese:
        return '건강을 위해 체중 감량이 필요합니다. 전문가와 상담을 고려해보세요.';
    }
  }
  
  /// 정상 체중 범위 계산
  static (double, double) getNormalWeightRange(double height) {
    if (height <= 0) return (0, 0);
    final heightInMeters = height / 100;
    final minWeight = AppConstants.bmiUnderweight * pow(heightInMeters, 2);
    final maxWeight = AppConstants.bmiNormal * pow(heightInMeters, 2);
    return (minWeight, maxWeight);
  }
  
  /// 목표 체중까지 필요한 체중 변화량
  static double getWeightDifference(double currentWeight, double targetWeight) {
    return targetWeight - currentWeight;
  }
  
  /// 체중 변화 퍼센트 계산
  static double getWeightChangePercentage(double startWeight, double currentWeight) {
    if (startWeight <= 0) return 0;
    return ((currentWeight - startWeight) / startWeight) * 100;
  }
}

/// BMI 카테고리
enum BMICategory {
  underweight,
  normal,
  overweight,
  obese,
}