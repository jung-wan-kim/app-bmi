import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../core/constants/bmi_constants.dart';
import '../../core/utils/bmi_calculator.dart';

class BMIGauge extends StatefulWidget {
  final double bmi;
  final double? targetBmi;
  final double size;
  final bool showLabels;
  final bool animate;
  final Duration animationDuration;
  final VoidCallback? onTap;

  const BMIGauge({
    super.key,
    required this.bmi,
    this.targetBmi,
    this.size = 200,
    this.showLabels = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.onTap,
  });

  @override
  State<BMIGauge> createState() => _BMIGaugeState();
}

class _BMIGaugeState extends State<BMIGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _needleAnimation;

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

    _needleAnimation = Tween<double>(
      begin: 0,
      end: _bmiToAngle(widget.bmi),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    if (widget.animate) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(BMIGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bmi != widget.bmi) {
      _needleAnimation = Tween<double>(
        begin: _bmiToAngle(oldWidget.bmi),
        end: _bmiToAngle(widget.bmi),
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

  double _bmiToAngle(double bmi) {
    // BMI 범위를 각도로 변환 (15-40 범위를 -135도에서 135도로)
    final clampedBmi = bmi.clamp(15.0, 40.0);
    final ratio = (clampedBmi - 15) / 25;
    return -135 + (ratio * 270);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(widget.size / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 게이지 배경
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _GaugeBackgroundPainter(
                    animation: _animation.value,
                    isDark: isDark,
                  ),
                );
              },
            ),
            // BMI 바늘
            AnimatedBuilder(
              animation: _needleAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _needleAnimation.value * (math.pi / 180),
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _NeedlePainter(
                      color: _getBmiColor(widget.bmi),
                      isDark: isDark,
                    ),
                  ),
                );
              },
            ),
            // 목표 BMI 마커
            if (widget.targetBmi != null)
              Transform.rotate(
                angle: _bmiToAngle(widget.targetBmi!) * (math.pi / 180),
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _TargetMarkerPainter(
                    isDark: isDark,
                  ),
                ),
              ),
            // 중앙 정보
            _buildCenterInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterInfo(BuildContext context) {
    final theme = Theme.of(context);
    final category = BMICalculator.getBMICategory(widget.bmi);
    final categoryText = _getCategoryText(category);
    final categoryColor = _getBmiColor(widget.bmi);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final animatedBmi = widget.animate
                ? (widget.bmi * _animation.value)
                : widget.bmi;
            return Text(
              animatedBmi.toStringAsFixed(1),
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: categoryColor,
              ),
            );
          },
        ),
        Text(
          'BMI',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
          ),
        ),
        if (widget.showLabels) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              categoryText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: categoryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
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

class _GaugeBackgroundPainter extends CustomPainter {
  final double animation;
  final bool isDark;

  _GaugeBackgroundPainter({
    required this.animation,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // 게이지 트랙
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..color = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _degreesToRadians(135),
      _degreesToRadians(270),
      false,
      trackPaint,
    );

    // BMI 범위 색상
    if (animation > 0) {
      final colors = [
        AppColors.info,    // 저체중
        AppColors.success, // 정상
        AppColors.warning, // 과체중
        AppColors.error,   // 비만
      ];
      
      final ranges = [
        (0.0, 0.16),    // 15-18.5
        (0.16, 0.40),   // 18.5-25
        (0.40, 0.60),   // 25-30
        (0.60, 1.0),    // 30-40
      ];

      for (int i = 0; i < colors.length; i++) {
        final startRatio = ranges[i].$1;
        final endRatio = ranges[i].$2;
        final startAngle = 135 + (startRatio * 270);
        final sweepAngle = (endRatio - startRatio) * 270 * animation;

        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.06
          ..strokeCap = StrokeCap.round
          ..color = colors[i].withOpacity(0.3);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          _degreesToRadians(startAngle),
          _degreesToRadians(sweepAngle),
          false,
          paint,
        );
      }
    }

    // 눈금
    for (int i = 0; i <= 10; i++) {
      final angle = 135 + (i * 27); // 270도를 10등분
      final startRadius = radius - size.width * 0.05;
      final endRadius = radius + size.width * 0.05;

      final start = Offset(
        center.dx + startRadius * math.cos(_degreesToRadians(angle)),
        center.dy + startRadius * math.sin(_degreesToRadians(angle)),
      );
      final end = Offset(
        center.dx + endRadius * math.cos(_degreesToRadians(angle)),
        center.dy + endRadius * math.sin(_degreesToRadians(angle)),
      );

      final tickPaint = Paint()
        ..color = isDark ? Colors.grey[700]! : Colors.grey[300]!
        ..strokeWidth = i % 5 == 0 ? 2 : 1;

      canvas.drawLine(start, end, tickPaint);
    }
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  @override
  bool shouldRepaint(_GaugeBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class _NeedlePainter extends CustomPainter {
  final Color color;
  final bool isDark;

  _NeedlePainter({
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final needleLength = size.width * 0.35;

    // 바늘
    final needlePath = Path()
      ..moveTo(center.dx - 2, center.dy)
      ..lineTo(center.dx, center.dy - needleLength)
      ..lineTo(center.dx + 2, center.dy)
      ..close();

    final needlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(needlePath, needlePaint);

    // 중심점
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerPaint);

    // 중심점 하이라이트
    final highlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 3, highlightPaint);
  }

  @override
  bool shouldRepaint(_NeedlePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _TargetMarkerPainter extends CustomPainter {
  final bool isDark;

  _TargetMarkerPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final markerRadius = size.width * 0.4;
    
    final markerPos = Offset(
      center.dx,
      center.dy - markerRadius,
    );

    // 목표 마커
    final markerPaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.fill;

    final markerPath = Path()
      ..moveTo(markerPos.dx - 6, markerPos.dy)
      ..lineTo(markerPos.dx, markerPos.dy - 10)
      ..lineTo(markerPos.dx + 6, markerPos.dy)
      ..close();

    canvas.drawPath(markerPath, markerPaint);
  }

  @override
  bool shouldRepaint(_TargetMarkerPainter oldDelegate) => false;
}