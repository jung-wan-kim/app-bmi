import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/bmi_constants.dart';
import '../../core/utils/bmi_calculator.dart';

class BMILinearChart extends StatefulWidget {
  final double bmi;
  final double? targetBmi;
  final double width;
  final double height;
  final bool showLabels;
  final bool animate;
  final Duration animationDuration;
  final VoidCallback? onTap;

  const BMILinearChart({
    super.key,
    required this.bmi,
    this.targetBmi,
    this.width = 300,
    this.height = 80,
    this.showLabels = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.onTap,
  });

  @override
  State<BMILinearChart> createState() => _BMILinearChartState();
}

class _BMILinearChartState extends State<BMILinearChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _indicatorAnimation = Tween<double>(
      begin: 0,
      end: _bmiToPosition(widget.bmi),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    if (widget.animate) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(BMILinearChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bmi != widget.bmi) {
      _indicatorAnimation = Tween<double>(
        begin: _bmiToPosition(oldWidget.bmi),
        end: _bmiToPosition(widget.bmi),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _bmiToPosition(double bmi) {
    // BMI 범위를 위치로 변환 (15-40 범위를 0-1로)
    final clampedBmi = bmi.clamp(15.0, 40.0);
    return (clampedBmi - 15) / 25;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BMI 값과 카테고리 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final animatedBmi = widget.animate
                          ? (widget.bmi * _animation.value)
                          : widget.bmi;
                      return RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyLarge,
                          children: [
                            TextSpan(
                              text: 'BMI ',
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                              ),
                            ),
                            TextSpan(
                              text: animatedBmi.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: _getBmiColor(widget.bmi),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (widget.showLabels)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getBmiColor(widget.bmi).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _getBmiColor(widget.bmi).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getCategoryText(BMICalculator.getBMICategory(widget.bmi)),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getBmiColor(widget.bmi),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // 직선 그래프
              Expanded(
                child: Stack(
                  children: [
                    // BMI 범위 배경
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(widget.width - 32, widget.height - 60),
                          painter: _BMILinearPainter(
                            animation: _animation.value,
                            isDark: isDark,
                          ),
                        );
                      },
                    ),
                    // 목표 BMI 마커
                    if (widget.targetBmi != null)
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          final targetPosition = _bmiToPosition(widget.targetBmi!);
                          return Positioned(
                            left: targetPosition * (widget.width - 32),
                            top: 5,
                            child: Opacity(
                              opacity: _animation.value,
                              child: Column(
                                children: [
                                  Container(
                                    width: 2,
                                    height: 15,
                                    color: AppColors.success,
                                  ),
                                  Icon(
                                    Icons.flag,
                                    size: 12,
                                    color: AppColors.success,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    // 현재 BMI 인디케이터
                    AnimatedBuilder(
                      animation: _indicatorAnimation,
                      builder: (context, child) {
                        return Positioned(
                          left: _indicatorAnimation.value * (widget.width - 32) - 2,
                          top: 0,
                          child: Column(
                            children: [
                              Container(
                                width: 4,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: _getBmiColor(widget.bmi),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getBmiColor(widget.bmi),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi < BMIConstants.underweightThreshold) {
      return AppColors.info;
    } else if (bmi < BMIConstants.normalThreshold) {
      return AppColors.success;
    } else if (bmi < BMIConstants.overweightThreshold) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String _getCategoryText(BMICategory category) {
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
}

class _BMILinearPainter extends CustomPainter {
  final double animation;
  final bool isDark;

  _BMILinearPainter({
    required this.animation,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const trackHeight = 8.0;
    final trackRect = Rect.fromLTWH(0, (size.height - trackHeight) / 2, size.width, trackHeight);

    // 배경 트랙
    final backgroundPaint = Paint()
      ..color = isDark ? Colors.grey[800]! : Colors.grey[200]!
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, const Radius.circular(4)),
      backgroundPaint,
    );

    if (animation > 0) {
      // BMI 범위 색상
      final ranges = [
        (0.0, 0.14, AppColors.info),    // 15-18.5 (저체중)
        (0.14, 0.40, AppColors.success), // 18.5-25 (정상)
        (0.40, 0.60, AppColors.warning), // 25-30 (과체중)
        (0.60, 1.0, AppColors.error),   // 30-40 (비만)
      ];

      for (final range in ranges) {
        final startRatio = range.$1;
        final endRatio = range.$2;
        final color = range.$3;

        final startX = startRatio * size.width;
        final endX = endRatio * size.width * animation;

        if (endX > startX) {
          final rangePaint = Paint()
            ..color = color.withOpacity(0.3)
            ..style = PaintingStyle.fill;

          final rangeRect = Rect.fromLTWH(
            startX,
            (size.height - trackHeight) / 2,
            endX - startX,
            trackHeight,
          );

          canvas.drawRRect(
            RRect.fromRectAndRadius(rangeRect, const Radius.circular(4)),
            rangePaint,
          );
        }
      }
    }

    // BMI 범위 레이블 (하단)
    if (animation > 0.5) {
      final labels = [
        (0.07, '15'),   // 저체중 중간
        (0.27, '18.5'), // 정상 시작
        (0.50, '25'),   // 과체중 시작
        (0.80, '30'),   // 비만 시작
        (0.93, '40'),   // 끝
      ];

      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );

      for (final label in labels) {
        final position = label.$1 * size.width;
        final text = label.$2;

        textPainter.text = TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(position - textPainter.width / 2, size.height - 12),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BMILinearPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}