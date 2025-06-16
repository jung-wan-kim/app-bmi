import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../core/constants/bmi_constants.dart';
import '../../core/utils/bmi_calculator.dart';
import 'character_animator.dart';

class BMICharacter extends StatefulWidget {
  final double bmi;
  final double? targetBmi;
  final double size;
  final bool showLabels;
  final bool animate;
  final Duration animationDuration;
  final CharacterStyle style;
  final VoidCallback? onTap;

  const BMICharacter({
    super.key,
    required this.bmi,
    this.targetBmi,
    this.size = 200,
    this.showLabels = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.style = CharacterStyle.cute,
    this.onTap,
  });

  @override
  State<BMICharacter> createState() => _BMICharacterState();
}

class _BMICharacterState extends State<BMICharacter>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _bounceController;
  late Animation<double> _morphAnimation;
  late Animation<double> _bounceAnimation;
  
  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOut,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _morphController.forward();
      _bounceController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BMICharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bmi != widget.bmi) {
      _morphController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final category = BMICalculator.getBMICategory(widget.bmi);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size * 1.2,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 캐릭터 본체
            AnimatedBuilder(
              animation: Listenable.merge([_morphAnimation, _bounceAnimation]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -10 * _bounceAnimation.value),
                  child: CustomPaint(
                    size: Size(widget.size * 0.8, widget.size * 0.8),
                    painter: _CharacterPainter(
                      bmi: widget.bmi,
                      morphProgress: _morphAnimation.value,
                      style: widget.style,
                      color: _getCategoryColor(category),
                      isDark: isDark,
                    ),
                  ),
                );
              },
            ),
            // 목표 BMI 실루엣
            if (widget.targetBmi != null)
              Opacity(
                opacity: 0.3,
                child: CustomPaint(
                  size: Size(widget.size * 0.8, widget.size * 0.8),
                  painter: _CharacterPainter(
                    bmi: widget.targetBmi!,
                    morphProgress: 1.0,
                    style: widget.style,
                    color: AppColors.success,
                    isDark: isDark,
                    isOutline: true,
                  ),
                ),
              ),
            // 라벨
            if (widget.showLabels)
              Positioned(
                bottom: 20,
                child: _buildLabels(context, category),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabels(BuildContext context, BMICategory category) {
    final theme = Theme.of(context);
    final categoryText = _getCategoryText(category);
    final categoryColor = _getCategoryColor(category);
    final emotion = _getCharacterEmotion(category);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: categoryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emotion,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BMI ${widget.bmi.toStringAsFixed(1)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                  Text(
                    categoryText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: categoryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(BMICategory category) {
    switch (category) {
      case BMICategory.underweight:
        return AppColors.info;
      case BMICategory.normal:
        return AppColors.success;
      case BMICategory.overweight:
        return AppColors.warning;
      case BMICategory.obese:
        return AppColors.error;
    }
  }

  String _getCategoryText(BMICategory category) {
    switch (category) {
      case BMICategory.underweight:
        return '저체중';
      case BMICategory.normal:
        return '정상 체중';
      case BMICategory.overweight:
        return '과체중';
      case BMICategory.obese:
        return '비만';
    }
  }

  String _getCharacterEmotion(BMICategory category) {
    switch (category) {
      case BMICategory.underweight:
        return '😔';
      case BMICategory.normal:
        return '😊';
      case BMICategory.overweight:
        return '😅';
      case BMICategory.obese:
        return '😰';
    }
  }
}

enum CharacterStyle {
  cute,
  realistic,
  minimal,
}

class _CharacterPainter extends CustomPainter {
  final double bmi;
  final double morphProgress;
  final CharacterStyle style;
  final Color color;
  final bool isDark;
  final bool isOutline;

  _CharacterPainter({
    required this.bmi,
    required this.morphProgress,
    required this.style,
    required this.color,
    required this.isDark,
    this.isOutline = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case CharacterStyle.cute:
        _drawCuteCharacter(canvas, size);
        break;
      case CharacterStyle.realistic:
        _drawRealisticCharacter(canvas, size);
        break;
      case CharacterStyle.minimal:
        _drawMinimalCharacter(canvas, size);
        break;
    }
  }

  void _drawCuteCharacter(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // BMI에 따른 몸통 크기 계산
    final bodyScale = _calculateBodyScale(bmi) * morphProgress + 
                      (1 - morphProgress);
    final bodyWidth = size.width * 0.5 * bodyScale;
    final bodyHeight = size.height * 0.6 * bodyScale;

    final paint = Paint()
      ..color = isOutline ? Colors.transparent : color
      ..style = isOutline ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = 2;

    if (isOutline) {
      paint.color = color;
    }

    // 몸통
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: bodyWidth,
        height: bodyHeight,
      ),
      Radius.circular(bodyWidth * 0.3),
    );
    canvas.drawRRect(bodyRect, paint);

    // 머리
    final headRadius = size.width * 0.2;
    final headCenter = Offset(
      center.dx,
      center.dy - bodyHeight / 2 - headRadius * 0.8,
    );
    canvas.drawCircle(headCenter, headRadius, paint);

    if (!isOutline) {
      // 눈
      final eyePaint = Paint()
        ..color = isDark ? Colors.white : Colors.black
        ..style = PaintingStyle.fill;
      
      final eyeRadius = headRadius * 0.15;
      final eyeY = headCenter.dy - headRadius * 0.1;
      
      canvas.drawCircle(
        Offset(headCenter.dx - headRadius * 0.35, eyeY),
        eyeRadius,
        eyePaint,
      );
      canvas.drawCircle(
        Offset(headCenter.dx + headRadius * 0.35, eyeY),
        eyeRadius,
        eyePaint,
      );

      // 표정
      final mouthPaint = Paint()
        ..color = isDark ? Colors.white : Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      final mouthPath = Path();
      final mouthY = headCenter.dy + headRadius * 0.3;
      
      if (bmi < BMIConstants.normalThreshold) {
        // 슬픈 표정
        mouthPath.moveTo(headCenter.dx - headRadius * 0.3, mouthY - 5);
        mouthPath.quadraticBezierTo(
          headCenter.dx, mouthY + 5,
          headCenter.dx + headRadius * 0.3, mouthY - 5,
        );
      } else if (bmi < BMIConstants.overweightThreshold) {
        // 웃는 표정
        mouthPath.moveTo(headCenter.dx - headRadius * 0.3, mouthY);
        mouthPath.quadraticBezierTo(
          headCenter.dx, mouthY + 10,
          headCenter.dx + headRadius * 0.3, mouthY,
        );
      } else {
        // 걱정스러운 표정
        mouthPath.moveTo(headCenter.dx - headRadius * 0.3, mouthY);
        mouthPath.lineTo(headCenter.dx + headRadius * 0.3, mouthY);
      }
      
      canvas.drawPath(mouthPath, mouthPaint);
    }

    // 팔
    final armPaint = Paint()
      ..color = isOutline ? color : color.withValues(alpha: 0.8)
      ..style = isOutline ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = 2;

    final armWidth = bodyWidth * 0.25;
    final armHeight = bodyHeight * 0.5;
    final armY = center.dy - bodyHeight * 0.2;

    // 왼팔
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - bodyWidth / 2 - armWidth / 2, armY),
          width: armWidth,
          height: armHeight,
        ),
        Radius.circular(armWidth / 2),
      ),
      armPaint,
    );

    // 오른팔
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + bodyWidth / 2 + armWidth / 2, armY),
          width: armWidth,
          height: armHeight,
        ),
        Radius.circular(armWidth / 2),
      ),
      armPaint,
    );

    // 다리
    final legWidth = bodyWidth * 0.3;
    final legHeight = size.height * 0.25;
    final legY = center.dy + bodyHeight / 2 + legHeight / 2;

    // 왼다리
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - bodyWidth * 0.25, legY),
          width: legWidth,
          height: legHeight,
        ),
        Radius.circular(legWidth / 2),
      ),
      armPaint,
    );

    // 오른다리
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + bodyWidth * 0.25, legY),
          width: legWidth,
          height: legHeight,
        ),
        Radius.circular(legWidth / 2),
      ),
      armPaint,
    );
  }

  void _drawRealisticCharacter(Canvas canvas, Size size) {
    // 실제 체형에 가까운 캐릭터 그리기
    final center = Offset(size.width / 2, size.height / 2);
    final bodyScale = _calculateBodyScale(bmi) * morphProgress + 
                      (1 - morphProgress);
    
    final paint = Paint()
      ..color = isOutline ? Colors.transparent : color.withValues(alpha: 0.8)
      ..style = isOutline ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = 2;

    if (isOutline) {
      paint.color = color;
    }

    // 더 복잡한 체형 표현
    final path = Path();
    final width = size.width * 0.4 * bodyScale;
    final height = size.height * 0.7;
    
    // 머리
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy - height * 0.35),
      width: width * 0.5,
      height: height * 0.15,
    ));
    
    // 어깨와 몸통
    path.moveTo(center.dx - width * 0.4, center.dy - height * 0.2);
    path.quadraticBezierTo(
      center.dx - width * 0.5, center.dy,
      center.dx - width * 0.4, center.dy + height * 0.2,
    );
    path.lineTo(center.dx + width * 0.4, center.dy + height * 0.2);
    path.quadraticBezierTo(
      center.dx + width * 0.5, center.dy,
      center.dx + width * 0.4, center.dy - height * 0.2,
    );
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawMinimalCharacter(Canvas canvas, Size size) {
    // 미니멀한 스타일의 캐릭터
    final center = Offset(size.width / 2, size.height / 2);
    final bodyScale = _calculateBodyScale(bmi) * morphProgress + 
                      (1 - morphProgress);
    
    final paint = Paint()
      ..color = isOutline ? Colors.transparent : color
      ..style = isOutline ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = 3;

    if (isOutline) {
      paint.color = color;
    }

    // 단순한 원형 몸통
    final radius = size.width * 0.3 * bodyScale;
    canvas.drawCircle(center, radius, paint);
    
    if (!isOutline) {
      // 간단한 얼굴 표현
      final facePaint = Paint()
        ..color = isDark ? Colors.white : Colors.black
        ..style = PaintingStyle.fill;
      
      // 눈
      canvas.drawCircle(
        Offset(center.dx - radius * 0.3, center.dy - radius * 0.2),
        3,
        facePaint,
      );
      canvas.drawCircle(
        Offset(center.dx + radius * 0.3, center.dy - radius * 0.2),
        3,
        facePaint,
      );
    }
  }

  double _calculateBodyScale(double bmi) {
    // BMI에 따른 몸 크기 비율 계산
    if (bmi < BMIConstants.underweightThreshold) {
      return 0.8 + (bmi - 15) * 0.02;
    } else if (bmi < BMIConstants.normalThreshold) {
      return 0.9 + (bmi - BMIConstants.underweightThreshold) * 0.02;
    } else if (bmi < BMIConstants.overweightThreshold) {
      return 1.0 + (bmi - BMIConstants.normalThreshold) * 0.03;
    } else {
      return 1.2 + (bmi - BMIConstants.overweightThreshold) * 0.02;
    }
  }

  @override
  bool shouldRepaint(_CharacterPainter oldDelegate) {
    return oldDelegate.bmi != bmi ||
           oldDelegate.morphProgress != morphProgress ||
           oldDelegate.color != color;
  }
}