import 'package:flutter_test/flutter_test.dart';
import 'package:app_bmi/core/utils/bmi_calculator.dart';

void main() {
  group('BMICalculator', () {
    group('calculateBMI', () {
      test('should calculate BMI correctly with valid inputs', () {
        // BMI = weight(kg) / (height(m) * height(m))
        expect(BMICalculator.calculateBMI(70, 170), closeTo(24.22, 0.01));
        expect(BMICalculator.calculateBMI(50, 160), closeTo(19.53, 0.01));
        expect(BMICalculator.calculateBMI(90, 180), closeTo(27.78, 0.01));
        expect(BMICalculator.calculateBMI(100, 200), closeTo(25.0, 0.01));
      });

      test('should return 0 for zero height', () {
        expect(BMICalculator.calculateBMI(70, 0), 0);
      });

      test('should return 0 for negative values', () {
        expect(BMICalculator.calculateBMI(-70, 170), 0);
        expect(BMICalculator.calculateBMI(70, -170), 0);
        expect(BMICalculator.calculateBMI(-70, -170), 0);
      });

      test('should handle edge cases', () {
        expect(BMICalculator.calculateBMI(0, 170), 0);
        expect(BMICalculator.calculateBMI(0.1, 170), closeTo(0.035, 0.001));
        expect(BMICalculator.calculateBMI(500, 170), closeTo(173.01, 0.01));
      });
    });

    group('getBMICategory', () {
      test('should return underweight for BMI < 18.5', () {
        expect(BMICalculator.getBMICategory(18.4), BMICategory.underweight);
        expect(BMICalculator.getBMICategory(16.0), BMICategory.underweight);
        expect(BMICalculator.getBMICategory(0), BMICategory.underweight);
      });

      test('should return normal for 18.5 <= BMI < 25', () {
        expect(BMICalculator.getBMICategory(18.5), BMICategory.normal);
        expect(BMICalculator.getBMICategory(22.0), BMICategory.normal);
        expect(BMICalculator.getBMICategory(24.9), BMICategory.normal);
      });

      test('should return overweight for 25 <= BMI < 30', () {
        expect(BMICalculator.getBMICategory(25.0), BMICategory.overweight);
        expect(BMICalculator.getBMICategory(27.5), BMICategory.overweight);
        expect(BMICalculator.getBMICategory(29.9), BMICategory.overweight);
      });

      test('should return obese for BMI >= 30', () {
        expect(BMICalculator.getBMICategory(30.0), BMICategory.obese);
        expect(BMICalculator.getBMICategory(35.0), BMICategory.obese);
        expect(BMICalculator.getBMICategory(50.0), BMICategory.obese);
      });
    });

    group('getCategoryName', () {
      test('should return correct Korean names for categories', () {
        expect(BMICalculator.getCategoryName(BMICategory.underweight), '저체중');
        expect(BMICalculator.getCategoryName(BMICategory.normal), '정상');
        expect(BMICalculator.getCategoryName(BMICategory.overweight), '과체중');
        expect(BMICalculator.getCategoryName(BMICategory.obese), '비만');
      });
    });

    group('getHealthAdvice', () {
      test('should return appropriate advice for each category', () {
        expect(
          BMICalculator.getHealthAdvice(BMICategory.underweight),
          '영양 섭취를 늘리고 근력 운동을 시작해보세요.',
        );
        expect(
          BMICalculator.getHealthAdvice(BMICategory.normal),
          '현재 건강한 체중을 유지하고 있습니다. 계속 유지해주세요!',
        );
        expect(
          BMICalculator.getHealthAdvice(BMICategory.overweight),
          '균형 잡힌 식단과 규칙적인 운동을 시작해보세요.',
        );
        expect(
          BMICalculator.getHealthAdvice(BMICategory.obese),
          '전문가와 상담하여 체중 관리 계획을 세워보세요.',
        );
      });
    });

    group('getIdealWeight', () {
      test('should calculate ideal weight range correctly', () {
        // For 170cm: ideal BMI 18.5-25 -> weight 53.5-72.3kg
        final range170 = BMICalculator.getIdealWeight(170);
        expect(range170['min'], closeTo(53.5, 0.1));
        expect(range170['max'], closeTo(72.3, 0.1));

        // For 160cm: ideal BMI 18.5-25 -> weight 47.4-64.0kg
        final range160 = BMICalculator.getIdealWeight(160);
        expect(range160['min'], closeTo(47.4, 0.1));
        expect(range160['max'], closeTo(64.0, 0.1));

        // For 180cm: ideal BMI 18.5-25 -> weight 59.9-81.0kg
        final range180 = BMICalculator.getIdealWeight(180);
        expect(range180['min'], closeTo(59.9, 0.1));
        expect(range180['max'], closeTo(81.0, 0.1));
      });

      test('should return zeros for invalid height', () {
        final range0 = BMICalculator.getIdealWeight(0);
        expect(range0['min'], 0);
        expect(range0['max'], 0);

        final rangeNegative = BMICalculator.getIdealWeight(-170);
        expect(rangeNegative['min'], 0);
        expect(rangeNegative['max'], 0);
      });
    });

    group('BMICategory extension', () {
      test('should have correct display names', () {
        expect(BMICategory.underweight.displayName, '저체중');
        expect(BMICategory.normal.displayName, '정상');
        expect(BMICategory.overweight.displayName, '과체중');
        expect(BMICategory.obese.displayName, '비만');
      });

      test('should have correct color codes', () {
        // These would be tested if color getter was implemented
        // expect(BMICategory.underweight.color, AppColors.bmiUnderweight);
        // expect(BMICategory.normal.color, AppColors.bmiNormal);
        // expect(BMICategory.overweight.color, AppColors.bmiOverweight);
        // expect(BMICategory.obese.color, AppColors.bmiObese);
      });
    });
  });
}