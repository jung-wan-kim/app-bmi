import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/bmi_calculator.dart';
import 'bmi_character_painter.dart';

class AdvancedBMICharacter extends StatefulWidget {
  final double bmi;
  final double size;
  final bool showLabel;
  final Gender gender;

  const AdvancedBMICharacter({
    super.key,
    required this.bmi,
    this.size = 200,
    this.showLabel = true,
    this.gender = Gender.male,
  });

  @override
  State<AdvancedBMICharacter> createState() => _AdvancedBMICharacterState();
}

class _AdvancedBMICharacterState extends State<AdvancedBMICharacter>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _blinkController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    
    // 호흡 애니메이션
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    // 눈 깜빡임 애니메이션
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));

    // 주기적으로 눈 깜빡이기
    _startBlinking();
  }

  void _startBlinking() {
    Future.delayed(Duration(seconds: 3 + DateTime.now().second % 3), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinking();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _blinkController.dispose();
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
        Container(
          width: widget.size,
          height: widget.size * 1.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 그림자
              Positioned(
                bottom: 0,
                child: Container(
                  width: widget.size * 0.6,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(widget.size * 0.3, 10),
                    ),
                  ),
                ),
              ),
              // 캐릭터 본체
              AnimatedBuilder(
                animation: Listenable.merge([_breathingAnimation, _blinkAnimation]),
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(widget.size, widget.size * 1.5),
                    painter: AdvancedBodyPainter(
                      bmi: widget.bmi,
                      gender: widget.gender,
                      primaryColor: color,
                      breathingValue: _breathingAnimation.value,
                      blinkValue: _blinkAnimation.value,
                    ),
                  );
                },
              ),
              // BMI 정보 오버레이
              Positioned(
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'BMI ${widget.bmi.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.showLabel) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
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

  IconData _getCategoryIcon(BMICategory category) {
    switch (category) {
      case BMICategory.underweight:
        return Icons.trending_down;
      case BMICategory.normal:
        return Icons.check_circle_outline;
      case BMICategory.overweight:
        return Icons.warning_amber_outlined;
      case BMICategory.obese:
        return Icons.error_outline;
    }
  }
}

// 더 정교한 사람 체형을 그리는 Painter
class AdvancedBodyPainter extends CustomPainter {
  final double bmi;
  final Gender gender;
  final Color primaryColor;
  final double breathingValue;
  final double blinkValue;

  AdvancedBodyPainter({
    required this.bmi,
    required this.gender,
    required this.primaryColor,
    required this.breathingValue,
    required this.blinkValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = primaryColor.withOpacity(0.3);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // BMI에 따른 체형 계수
    final bodyScale = _getBodyScale(bmi);
    final bellyScale = _getBellyScale(bmi);
    final limbScale = _getLimbScale(bmi);
    
    // 호흡에 따른 움직임
    final breathingOffset = breathingValue * 3;
    final chestExpansion = breathingValue * 0.02;

    // 피부색
    final skinColor = Colors.orange.shade100;
    
    // 머리
    _drawHead(canvas, paint, outlinePaint, centerX, centerY * 0.35, size, skinColor);
    
    // 목
    _drawNeck(canvas, paint, outlinePaint, centerX, centerY * 0.55, size, skinColor, bodyScale);
    
    // 몸통
    _drawTorso(canvas, paint, outlinePaint, centerX, centerY, size, 
               skinColor, bodyScale, bellyScale, chestExpansion, breathingOffset);
    
    // 팔
    _drawArms(canvas, paint, outlinePaint, centerX, centerY * 0.75, 
              size, skinColor, limbScale, breathingOffset);
    
    // 다리
    _drawLegs(canvas, paint, outlinePaint, centerX, centerY * 1.4, 
              size, skinColor, limbScale);
    
    // 얼굴
    _drawFace(canvas, centerX, centerY * 0.35, size);
    
    // 옷
    _drawClothes(canvas, centerX, centerY, size, bodyScale, bellyScale);
  }

  void _drawHead(Canvas canvas, Paint paint, Paint outlinePaint, 
                 double centerX, double centerY, Size size, Color skinColor) {
    // 머리 본체
    paint.color = skinColor;
    final headRadius = size.width * 0.15;
    
    // 얼굴 모양 (타원형)
    final facePath = Path();
    final faceRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: headRadius * 1.8,
      height: headRadius * 2.2,
    );
    facePath.addOval(faceRect);
    canvas.drawPath(facePath, paint);
    canvas.drawPath(facePath, outlinePaint);
    
    // 귀
    paint.color = skinColor.withOpacity(0.9);
    canvas.drawCircle(
      Offset(centerX - headRadius * 0.9, centerY),
      headRadius * 0.25,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX + headRadius * 0.9, centerY),
      headRadius * 0.25,
      paint,
    );
    
    // 머리카락
    _drawHair(canvas, paint, centerX, centerY - headRadius * 0.8, headRadius);
  }

  void _drawHair(Canvas canvas, Paint paint, double centerX, double centerY, double headRadius) {
    paint.color = Colors.brown.shade800;
    
    if (gender == Gender.female) {
      // 여성: 긴 머리
      final hairPath = Path();
      hairPath.moveTo(centerX - headRadius, centerY);
      
      // 앞머리
      hairPath.quadraticBezierTo(
        centerX - headRadius * 0.5, centerY - headRadius * 0.3,
        centerX, centerY - headRadius * 0.2,
      );
      hairPath.quadraticBezierTo(
        centerX + headRadius * 0.5, centerY - headRadius * 0.3,
        centerX + headRadius, centerY,
      );
      
      // 옆머리
      hairPath.lineTo(centerX + headRadius * 0.9, centerY + headRadius * 2);
      hairPath.quadraticBezierTo(
        centerX + headRadius * 0.7, centerY + headRadius * 2.5,
        centerX, centerY + headRadius * 2.5,
      );
      hairPath.quadraticBezierTo(
        centerX - headRadius * 0.7, centerY + headRadius * 2.5,
        centerX - headRadius * 0.9, centerY + headRadius * 2,
      );
      hairPath.close();
      
      canvas.drawPath(hairPath, paint);
    } else {
      // 남성: 짧은 머리
      final hairPath = Path();
      final hairRect = Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: headRadius * 2,
        height: headRadius * 1.5,
      );
      hairPath.addArc(hairRect, -3.14, 3.14);
      
      paint.style = PaintingStyle.fill;
      canvas.drawPath(hairPath, paint);
    }
  }

  void _drawNeck(Canvas canvas, Paint paint, Paint outlinePaint,
                 double centerX, double centerY, Size size, Color skinColor, double bodyScale) {
    paint.color = skinColor;
    final neckWidth = size.width * 0.08 * bodyScale;
    final neckHeight = size.height * 0.06;
    
    final neckRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: neckWidth,
      height: neckHeight,
    );
    
    canvas.drawRect(neckRect, paint);
  }

  void _drawTorso(Canvas canvas, Paint paint, Paint outlinePaint,
                  double centerX, double centerY, Size size,
                  Color skinColor, double bodyScale, double bellyScale,
                  double chestExpansion, double breathingOffset) {
    paint.color = skinColor;
    
    final shoulderY = centerY - size.height * 0.15;
    final chestY = centerY - size.height * 0.05;
    final waistY = centerY + size.height * 0.05;
    final hipY = centerY + size.height * 0.2;
    
    final shoulderWidth = size.width * 0.25 * bodyScale;
    final chestWidth = size.width * 0.22 * bodyScale * (1 + chestExpansion);
    final waistWidth = size.width * 0.18 * bodyScale;
    final hipWidth = gender == Gender.female
        ? size.width * 0.24 * bodyScale
        : size.width * 0.20 * bodyScale;
    
    // 몸통 윤곽
    final torsoPath = Path();
    
    // 왼쪽 어깨에서 시작
    torsoPath.moveTo(centerX - shoulderWidth, shoulderY);
    
    // 왼쪽 가슴
    torsoPath.quadraticBezierTo(
      centerX - chestWidth, chestY,
      centerX - waistWidth - (bellyScale * size.width * 0.05), waistY,
    );
    
    // 왼쪽 엉덩이
    torsoPath.quadraticBezierTo(
      centerX - hipWidth, hipY - size.height * 0.05,
      centerX - hipWidth, hipY,
    );
    
    // 아래쪽
    torsoPath.lineTo(centerX + hipWidth, hipY);
    
    // 오른쪽 엉덩이
    torsoPath.quadraticBezierTo(
      centerX + hipWidth, hipY - size.height * 0.05,
      centerX + waistWidth + (bellyScale * size.width * 0.05), waistY,
    );
    
    // 오른쪽 가슴
    torsoPath.quadraticBezierTo(
      centerX + chestWidth, chestY,
      centerX + shoulderWidth, shoulderY,
    );
    
    torsoPath.close();
    
    canvas.drawPath(torsoPath, paint);
    canvas.drawPath(torsoPath, outlinePaint);
    
    // 가슴 디테일 (여성)
    if (gender == Gender.female) {
      paint.color = skinColor.withOpacity(0.8);
      final bustY = chestY + size.height * 0.03;
      
      // 왼쪽
      canvas.drawCircle(
        Offset(centerX - chestWidth * 0.4, bustY),
        size.width * 0.07 * bodyScale,
        paint,
      );
      
      // 오른쪽
      canvas.drawCircle(
        Offset(centerX + chestWidth * 0.4, bustY),
        size.width * 0.07 * bodyScale,
        paint,
      );
    }
  }

  void _drawArms(Canvas canvas, Paint paint, Paint outlinePaint,
                 double centerX, double shoulderY, Size size,
                 Color skinColor, double limbScale, double breathingOffset) {
    paint.color = skinColor;
    
    final shoulderWidth = size.width * 0.25;
    final armLength = size.height * 0.35;
    final upperArmWidth = size.width * 0.06 * limbScale;
    final forearmWidth = size.width * 0.05 * limbScale;
    
    // 양팔 그리기
    for (final side in [-1, 1]) {
      final shoulderX = centerX + (shoulderWidth * side);
      final elbowX = shoulderX + (size.width * 0.12 * side);
      final elbowY = shoulderY + armLength * 0.5;
      final handX = elbowX + (size.width * 0.08 * side);
      final handY = elbowY + armLength * 0.5 - breathingOffset;
      
      // 상완
      final upperArmPath = Path();
      upperArmPath.moveTo(shoulderX, shoulderY);
      upperArmPath.quadraticBezierTo(
        shoulderX + (upperArmWidth * side), shoulderY + armLength * 0.25,
        elbowX, elbowY,
      );
      upperArmPath.lineTo(elbowX - (upperArmWidth * 0.8 * side), elbowY);
      upperArmPath.quadraticBezierTo(
        shoulderX - (upperArmWidth * 0.5 * side), shoulderY + armLength * 0.25,
        shoulderX - (upperArmWidth * 0.3 * side), shoulderY,
      );
      upperArmPath.close();
      
      canvas.drawPath(upperArmPath, paint);
      
      // 하완
      final forearmPath = Path();
      forearmPath.moveTo(elbowX, elbowY);
      forearmPath.quadraticBezierTo(
        elbowX + (forearmWidth * side), elbowY + armLength * 0.25,
        handX, handY,
      );
      forearmPath.lineTo(handX - (forearmWidth * 0.8 * side), handY);
      forearmPath.quadraticBezierTo(
        elbowX - (forearmWidth * 0.8 * side), elbowY + armLength * 0.25,
        elbowX - (forearmWidth * 0.8 * side), elbowY,
      );
      forearmPath.close();
      
      canvas.drawPath(forearmPath, paint);
      
      // 손
      canvas.drawCircle(
        Offset(handX, handY),
        forearmWidth * 1.2,
        paint,
      );
    }
  }

  void _drawLegs(Canvas canvas, Paint paint, Paint outlinePaint,
                 double centerX, double hipY, Size size,
                 Color skinColor, double limbScale) {
    paint.color = skinColor;
    
    final legSpacing = size.width * 0.12;
    final thighWidth = size.width * 0.08 * limbScale;
    final calfWidth = size.width * 0.06 * limbScale;
    final legLength = size.height * 0.35;
    
    // 양다리 그리기
    for (final side in [-1, 1]) {
      final hipX = centerX + (legSpacing * side);
      final kneeX = hipX;
      final kneeY = hipY + legLength * 0.5;
      final ankleX = kneeX;
      final ankleY = kneeY + legLength * 0.5;
      
      // 허벅지
      final thighPath = Path();
      thighPath.moveTo(hipX - thighWidth / 2, hipY);
      thighPath.lineTo(hipX - thighWidth / 2, kneeY);
      thighPath.lineTo(hipX + thighWidth / 2, kneeY);
      thighPath.lineTo(hipX + thighWidth / 2, hipY);
      thighPath.close();
      
      canvas.drawPath(thighPath, paint);
      
      // 종아리
      final calfPath = Path();
      calfPath.moveTo(kneeX - calfWidth / 2, kneeY);
      calfPath.lineTo(ankleX - calfWidth / 2, ankleY);
      calfPath.lineTo(ankleX + calfWidth / 2, ankleY);
      calfPath.lineTo(kneeX + calfWidth / 2, kneeY);
      calfPath.close();
      
      canvas.drawPath(calfPath, paint);
      
      // 발
      paint.color = Colors.brown.shade700;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(ankleX, ankleY + calfWidth * 0.8),
            width: calfWidth * 1.5,
            height: calfWidth * 0.8,
          ),
          Radius.circular(calfWidth * 0.4),
        ),
        paint,
      );
      paint.color = skinColor;
    }
  }

  void _drawFace(Canvas canvas, double centerX, double centerY, Size size) {
    final facePaint = Paint()..style = PaintingStyle.fill;
    
    // 눈
    facePaint.color = Colors.white;
    for (final side in [-1, 1]) {
      final eyeX = centerX + (size.width * 0.06 * side);
      final eyeY = centerY - size.height * 0.02;
      
      // 눈 흰자
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(eyeX, eyeY),
          width: size.width * 0.04,
          height: size.width * 0.03 * blinkValue,
        ),
        facePaint,
      );
      
      // 눈동자
      if (blinkValue > 0.5) {
        facePaint.color = Colors.brown.shade700;
        canvas.drawCircle(
          Offset(eyeX, eyeY),
          size.width * 0.015,
          facePaint,
        );
        
        facePaint.color = Colors.black;
        canvas.drawCircle(
          Offset(eyeX, eyeY),
          size.width * 0.008,
          facePaint,
        );
      }
    }
    
    // 눈썹
    final eyebrowPaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    for (final side in [-1, 1]) {
      final eyebrowPath = Path();
      eyebrowPath.moveTo(
        centerX + (size.width * 0.04 * side),
        centerY - size.height * 0.06,
      );
      eyebrowPath.quadraticBezierTo(
        centerX + (size.width * 0.06 * side),
        centerY - size.height * 0.07,
        centerX + (size.width * 0.08 * side),
        centerY - size.height * 0.06,
      );
      canvas.drawPath(eyebrowPath, eyebrowPaint);
    }
    
    // 코
    facePaint.color = Colors.brown.shade300.withOpacity(0.3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY + size.height * 0.02),
        width: size.width * 0.03,
        height: size.height * 0.02,
      ),
      facePaint,
    );
    
    // 입
    final mouthPaint = Paint()
      ..color = Colors.red.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    final category = BMICalculator.getBMICategory(bmi);
    final mouthPath = Path();
    
    switch (category) {
      case BMICategory.underweight:
        // 걱정스러운 표정
        mouthPath.moveTo(centerX - size.width * 0.05, centerY + size.height * 0.08);
        mouthPath.quadraticBezierTo(
          centerX, centerY + size.height * 0.06,
          centerX + size.width * 0.05, centerY + size.height * 0.08,
        );
        break;
      case BMICategory.normal:
        // 미소
        mouthPath.moveTo(centerX - size.width * 0.05, centerY + size.height * 0.06);
        mouthPath.quadraticBezierTo(
          centerX, centerY + size.height * 0.1,
          centerX + size.width * 0.05, centerY + size.height * 0.06,
        );
        break;
      case BMICategory.overweight:
      case BMICategory.obese:
        // 평범한 표정
        mouthPath.moveTo(centerX - size.width * 0.04, centerY + size.height * 0.08);
        mouthPath.lineTo(centerX + size.width * 0.04, centerY + size.height * 0.08);
        break;
    }
    
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawClothes(Canvas canvas, double centerX, double centerY, 
                    Size size, double bodyScale, double bellyScale) {
    final clothesPaint = Paint()..style = PaintingStyle.fill;
    
    if (gender == Gender.female) {
      // 여성: 원피스
      clothesPaint.color = Colors.pink.shade300;
      
      final dressPath = Path();
      final dressTop = centerY - size.height * 0.05;
      final dressBottom = centerY + size.height * 0.25;
      final topWidth = size.width * 0.2 * bodyScale;
      final bottomWidth = size.width * 0.3 * bodyScale;
      
      dressPath.moveTo(centerX - topWidth, dressTop);
      dressPath.quadraticBezierTo(
        centerX - topWidth - (bellyScale * size.width * 0.05),
        centerY + size.height * 0.1,
        centerX - bottomWidth,
        dressBottom,
      );
      dressPath.lineTo(centerX + bottomWidth, dressBottom);
      dressPath.quadraticBezierTo(
        centerX + topWidth + (bellyScale * size.width * 0.05),
        centerY + size.height * 0.1,
        centerX + topWidth,
        dressTop,
      );
      dressPath.close();
      
      canvas.drawPath(dressPath, clothesPaint);
    } else {
      // 남성: 티셔츠
      clothesPaint.color = Colors.blue.shade400;
      
      final shirtPath = Path();
      final shirtTop = centerY - size.height * 0.1;
      final shirtBottom = centerY + size.height * 0.15;
      final topWidth = size.width * 0.22 * bodyScale;
      final bottomWidth = size.width * 0.2 * bodyScale;
      
      shirtPath.moveTo(centerX - topWidth, shirtTop);
      shirtPath.lineTo(centerX - bottomWidth - (bellyScale * size.width * 0.05), shirtBottom);
      shirtPath.lineTo(centerX + bottomWidth + (bellyScale * size.width * 0.05), shirtBottom);
      shirtPath.lineTo(centerX + topWidth, shirtTop);
      shirtPath.close();
      
      canvas.drawPath(shirtPath, clothesPaint);
      
      // 바지
      clothesPaint.color = Colors.grey.shade700;
      
      final pantsPath = Path();
      final pantsTop = centerY + size.height * 0.15;
      final pantsBottom = centerY + size.height * 0.5;
      final pantsWidth = size.width * 0.2 * bodyScale;
      
      pantsPath.moveTo(centerX - pantsWidth, pantsTop);
      pantsPath.lineTo(centerX - size.width * 0.12, pantsBottom);
      pantsPath.lineTo(centerX - size.width * 0.08, pantsBottom);
      pantsPath.lineTo(centerX, pantsTop + size.height * 0.1);
      pantsPath.lineTo(centerX + size.width * 0.08, pantsBottom);
      pantsPath.lineTo(centerX + size.width * 0.12, pantsBottom);
      pantsPath.lineTo(centerX + pantsWidth, pantsTop);
      pantsPath.close();
      
      canvas.drawPath(pantsPath, clothesPaint);
    }
  }

  double _getBodyScale(double bmi) {
    if (bmi < 18.5) return 0.85;
    if (bmi < 25) return 1.0;
    if (bmi < 30) return 1.15;
    return 1.3;
  }

  double _getBellyScale(double bmi) {
    if (bmi < 18.5) return -0.2;
    if (bmi < 25) return 0.0;
    if (bmi < 30) return 0.5;
    return 1.0;
  }

  double _getLimbScale(double bmi) {
    if (bmi < 18.5) return 0.8;
    if (bmi < 25) return 1.0;
    if (bmi < 30) return 1.2;
    return 1.4;
  }

  @override
  bool shouldRepaint(AdvancedBodyPainter oldDelegate) {
    return oldDelegate.bmi != bmi ||
           oldDelegate.gender != gender ||
           oldDelegate.breathingValue != breathingValue ||
           oldDelegate.blinkValue != blinkValue;
  }
}