import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/bmi_calculator.dart';
import 'bmi_character_painter.dart';

class BMICharacter extends StatefulWidget {
  final double bmi;
  final double size;
  final bool showLabel;
  final Gender gender;

  const BMICharacter({
    super.key,
    required this.bmi,
    this.size = 120,
    this.showLabel = true,
    this.gender = Gender.male,
  });

  @override
  State<BMICharacter> createState() => _BMICharacterState();
}

class _BMICharacterState extends State<BMICharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = BMICalculator.getBMICategory(widget.bmi);
    final color = _getCategoryColor(category);
    final label = BMICalculator.getCategoryName(category);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_bounceAnimation.value),
              child: Container(
                width: widget.size * 1.5,
                height: widget.size * 2,
                child: CustomPaint(
                  painter: BMICharacterPainter(
                    bmi: widget.bmi,
                    gender: widget.gender,
                    primaryColor: color,
                    animationValue: _controller.value,
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // BMI 수치 표시
                      Positioned(
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'BMI ${widget.bmi.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showLabel) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getCategoryColor(BMICategory category) {
    switch (category) {
      case BMICategory.underweight:
        return AppColors.bmiUnderweight;
      case BMICategory.normal:
        return AppColors.bmiNormal;
      case BMICategory.overweight:
        return AppColors.bmiOverweight;
      case BMICategory.obese:
        return AppColors.bmiObese;
    }
  }

}

// BMI 진행 상황을 보여주는 위젯
class BMIProgressIndicator extends StatelessWidget {
  final double currentBMI;
  final double targetBMI;

  const BMIProgressIndicator({
    super.key,
    required this.currentBMI,
    this.targetBMI = 22.0, // 정상 BMI 중간값
  });

  @override
  Widget build(BuildContext context) {
    final minBMI = 15.0;
    final maxBMI = 35.0;
    final range = maxBMI - minBMI;
    
    final currentPosition = ((currentBMI - minBMI) / range).clamp(0.0, 1.0);
    final targetPosition = ((targetBMI - minBMI) / range).clamp(0.0, 1.0);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // BMI 범위 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '저체중',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.bmiUnderweight,
                ),
              ),
              Text(
                '정상',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.bmiNormal,
                ),
              ),
              Text(
                '과체중',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.bmiOverweight,
                ),
              ),
              Text(
                '비만',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.bmiObese,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 진행 바
          Stack(
            children: [
              // 배경 그라데이션
              Container(
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.bmiUnderweight,
                      AppColors.bmiNormal,
                      AppColors.bmiOverweight,
                      AppColors.bmiObese,
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),
              // 목표 위치 표시
              Positioned(
                left: targetPosition * (MediaQuery.of(context).size.width - 80),
                child: Container(
                  width: 2,
                  height: 20,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              // 현재 위치 표시
              Positioned(
                left: currentPosition * (MediaQuery.of(context).size.width - 80) - 10,
                top: -5,
                child: Container(
                  width: 20,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getBMIColor(currentBMI),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 현재 BMI 표시
          Text(
            'BMI ${currentBMI.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getBMIColor(currentBMI),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBMIColor(double bmi) {
    final category = BMICalculator.getBMICategory(bmi);
    switch (category) {
      case BMICategory.underweight:
        return AppColors.bmiUnderweight;
      case BMICategory.normal:
        return AppColors.bmiNormal;
      case BMICategory.overweight:
        return AppColors.bmiOverweight;
      case BMICategory.obese:
        return AppColors.bmiObese;
    }
  }
}