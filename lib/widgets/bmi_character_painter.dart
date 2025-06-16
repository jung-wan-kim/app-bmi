import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/constants/app_colors.dart';
import '../core/utils/bmi_calculator.dart';

enum Gender { male, female }

class BMICharacterPainter extends CustomPainter {
  final double bmi;
  final Gender gender;
  final Color primaryColor;
  final double animationValue;

  BMICharacterPainter({
    required this.bmi,
    required this.gender,
    required this.primaryColor,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = primaryColor.withOpacity(0.3);

    // 중심점
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // BMI에 따른 체형 계수 계산
    final bodyWidthFactor = _getBodyWidthFactor(bmi);
    final bellyFactor = _getBellyFactor(bmi);
    
    // 애니메이션 적용
    final breathingOffset = math.sin(animationValue * 2 * math.pi) * 2;

    // 머리
    _drawHead(canvas, paint, outlinePaint, centerX, centerY - size.height * 0.35, size);

    // 몸통
    _drawBody(canvas, paint, outlinePaint, centerX, centerY, size, 
              bodyWidthFactor, bellyFactor, breathingOffset);

    // 팔
    _drawArms(canvas, paint, outlinePaint, centerX, centerY - size.height * 0.1, 
              size, bodyWidthFactor);

    // 다리
    _drawLegs(canvas, paint, outlinePaint, centerX, centerY + size.height * 0.2, 
              size, bodyWidthFactor);

    // 얼굴 표정
    _drawFace(canvas, centerX, centerY - size.height * 0.35, size);
  }

  void _drawHead(Canvas canvas, Paint paint, Paint outlinePaint, 
                 double centerX, double centerY, Size size) {
    paint.color = primaryColor.withOpacity(0.9);
    
    final headRadius = size.width * 0.12;
    canvas.drawCircle(Offset(centerX, centerY), headRadius, paint);
    canvas.drawCircle(Offset(centerX, centerY), headRadius, outlinePaint);

    // 머리카락 (성별에 따라 다르게)
    if (gender == Gender.female) {
      // 여성: 긴 머리
      final hairPath = Path();
      hairPath.moveTo(centerX - headRadius, centerY);
      hairPath.quadraticBezierTo(
        centerX - headRadius * 1.2, centerY + headRadius * 0.5,
        centerX - headRadius * 0.8, centerY + headRadius * 1.5,
      );
      hairPath.lineTo(centerX + headRadius * 0.8, centerY + headRadius * 1.5);
      hairPath.quadraticBezierTo(
        centerX + headRadius * 1.2, centerY + headRadius * 0.5,
        centerX + headRadius, centerY,
      );
      hairPath.close();
      
      paint.color = Colors.brown.shade800;
      canvas.drawPath(hairPath, paint);
    } else {
      // 남성: 짧은 머리
      final hairPath = Path();
      hairPath.addArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: headRadius),
        -math.pi * 0.8,
        math.pi * 0.6,
      );
      paint.color = Colors.brown.shade800;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = headRadius * 0.3;
      canvas.drawPath(hairPath, paint);
      paint.style = PaintingStyle.fill;
    }
  }

  void _drawBody(Canvas canvas, Paint paint, Paint outlinePaint, 
                 double centerX, double centerY, Size size,
                 double widthFactor, double bellyFactor, double breathingOffset) {
    paint.color = primaryColor.withOpacity(0.8);
    
    final bodyPath = Path();
    final shoulderY = centerY - size.height * 0.2;
    final shoulderWidth = size.width * 0.2 * widthFactor;
    final waistY = centerY;
    final waistWidth = size.width * 0.15 * widthFactor;
    final hipY = centerY + size.height * 0.2;
    final hipWidth = gender == Gender.female 
        ? size.width * 0.18 * widthFactor 
        : size.width * 0.16 * widthFactor;

    // 왼쪽 윤곽
    bodyPath.moveTo(centerX - shoulderWidth, shoulderY);
    
    // 배 부분 (BMI에 따라 볼록하게)
    if (bellyFactor > 0) {
      bodyPath.quadraticBezierTo(
        centerX - waistWidth - (bellyFactor * size.width * 0.1) - breathingOffset,
        waistY,
        centerX - hipWidth,
        hipY,
      );
    } else {
      // 날씬한 체형
      bodyPath.quadraticBezierTo(
        centerX - waistWidth * 0.9,
        waistY,
        centerX - hipWidth,
        hipY,
      );
    }

    // 아래쪽
    bodyPath.lineTo(centerX + hipWidth, hipY);

    // 오른쪽 윤곽
    if (bellyFactor > 0) {
      bodyPath.quadraticBezierTo(
        centerX + waistWidth + (bellyFactor * size.width * 0.1) + breathingOffset,
        waistY,
        centerX + shoulderWidth,
        shoulderY,
      );
    } else {
      bodyPath.quadraticBezierTo(
        centerX + waistWidth * 0.9,
        waistY,
        centerX + shoulderWidth,
        shoulderY,
      );
    }

    bodyPath.close();
    
    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(bodyPath, outlinePaint);

    // 가슴 부분 (성별에 따라)
    if (gender == Gender.female) {
      paint.color = primaryColor.withOpacity(0.7);
      final chestY = shoulderY + size.height * 0.08;
      canvas.drawCircle(
        Offset(centerX - shoulderWidth * 0.4, chestY),
        size.width * 0.06 * widthFactor,
        paint,
      );
      canvas.drawCircle(
        Offset(centerX + shoulderWidth * 0.4, chestY),
        size.width * 0.06 * widthFactor,
        paint,
      );
    }
  }

  void _drawArms(Canvas canvas, Paint paint, Paint outlinePaint,
                 double centerX, double shoulderY, Size size, double widthFactor) {
    paint.color = primaryColor.withOpacity(0.85);
    
    final armWidth = size.width * 0.06 * widthFactor;
    final armLength = size.height * 0.25;
    final shoulderWidth = size.width * 0.2 * widthFactor;

    // 왼팔
    final leftArmPath = Path();
    leftArmPath.moveTo(centerX - shoulderWidth, shoulderY);
    leftArmPath.lineTo(centerX - shoulderWidth - armWidth, shoulderY + armLength);
    leftArmPath.lineTo(centerX - shoulderWidth + armWidth * 0.5, shoulderY + armLength);
    leftArmPath.lineTo(centerX - shoulderWidth + armWidth * 0.5, shoulderY + armWidth);
    leftArmPath.close();

    // 오른팔
    final rightArmPath = Path();
    rightArmPath.moveTo(centerX + shoulderWidth, shoulderY);
    rightArmPath.lineTo(centerX + shoulderWidth + armWidth, shoulderY + armLength);
    rightArmPath.lineTo(centerX + shoulderWidth - armWidth * 0.5, shoulderY + armLength);
    rightArmPath.lineTo(centerX + shoulderWidth - armWidth * 0.5, shoulderY + armWidth);
    rightArmPath.close();

    canvas.drawPath(leftArmPath, paint);
    canvas.drawPath(rightArmPath, paint);
    canvas.drawPath(leftArmPath, outlinePaint);
    canvas.drawPath(rightArmPath, outlinePaint);

    // 손
    paint.color = Colors.orange.shade200;
    canvas.drawCircle(
      Offset(centerX - shoulderWidth - armWidth * 0.5, shoulderY + armLength),
      armWidth * 0.8,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX + shoulderWidth + armWidth * 0.5, shoulderY + armLength),
      armWidth * 0.8,
      paint,
    );
  }

  void _drawLegs(Canvas canvas, Paint paint, Paint outlinePaint,
                 double centerX, double hipY, Size size, double widthFactor) {
    paint.color = primaryColor.withOpacity(0.85);
    
    final legWidth = size.width * 0.08 * widthFactor;
    final legLength = size.height * 0.25;
    final legSpacing = size.width * 0.08;

    // 왼쪽 다리
    final leftLegPath = Path();
    leftLegPath.moveTo(centerX - legSpacing - legWidth / 2, hipY);
    leftLegPath.lineTo(centerX - legSpacing - legWidth / 2, hipY + legLength);
    leftLegPath.lineTo(centerX - legSpacing + legWidth / 2, hipY + legLength);
    leftLegPath.lineTo(centerX - legSpacing + legWidth / 2, hipY);
    leftLegPath.close();

    // 오른쪽 다리
    final rightLegPath = Path();
    rightLegPath.moveTo(centerX + legSpacing - legWidth / 2, hipY);
    rightLegPath.lineTo(centerX + legSpacing - legWidth / 2, hipY + legLength);
    rightLegPath.lineTo(centerX + legSpacing + legWidth / 2, hipY + legLength);
    rightLegPath.lineTo(centerX + legSpacing + legWidth / 2, hipY);
    rightLegPath.close();

    canvas.drawPath(leftLegPath, paint);
    canvas.drawPath(rightLegPath, paint);
    canvas.drawPath(leftLegPath, outlinePaint);
    canvas.drawPath(rightLegPath, outlinePaint);

    // 신발
    paint.color = Colors.grey.shade700;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - legSpacing, hipY + legLength + legWidth * 0.3),
          width: legWidth * 1.2,
          height: legWidth * 0.6,
        ),
        Radius.circular(legWidth * 0.3),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX + legSpacing, hipY + legLength + legWidth * 0.3),
          width: legWidth * 1.2,
          height: legWidth * 0.6,
        ),
        Radius.circular(legWidth * 0.3),
      ),
      paint,
    );
  }

  void _drawFace(Canvas canvas, double centerX, double centerY, Size size) {
    final facePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // 눈
    canvas.drawCircle(
      Offset(centerX - size.width * 0.04, centerY),
      size.width * 0.015,
      facePaint,
    );
    canvas.drawCircle(
      Offset(centerX + size.width * 0.04, centerY),
      size.width * 0.015,
      facePaint,
    );

    // 표정 (BMI에 따라 다르게)
    final category = BMICalculator.getBMICategory(bmi);
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final mouthPath = Path();
    switch (category) {
      case BMICategory.underweight:
        // 걱정스러운 표정
        mouthPath.moveTo(centerX - size.width * 0.04, centerY + size.width * 0.08);
        mouthPath.quadraticBezierTo(
          centerX, centerY + size.width * 0.06,
          centerX + size.width * 0.04, centerY + size.width * 0.08,
        );
        break;
      case BMICategory.normal:
        // 행복한 표정
        mouthPath.moveTo(centerX - size.width * 0.04, centerY + size.width * 0.06);
        mouthPath.quadraticBezierTo(
          centerX, centerY + size.width * 0.1,
          centerX + size.width * 0.04, centerY + size.width * 0.06,
        );
        break;
      case BMICategory.overweight:
      case BMICategory.obese:
        // 평범한 표정
        mouthPath.moveTo(centerX - size.width * 0.03, centerY + size.width * 0.08);
        mouthPath.lineTo(centerX + size.width * 0.03, centerY + size.width * 0.08);
        break;
    }
    canvas.drawPath(mouthPath, mouthPaint);
  }

  double _getBodyWidthFactor(double bmi) {
    if (bmi < 18.5) return 0.85;
    if (bmi < 25) return 1.0;
    if (bmi < 30) return 1.2;
    return 1.4;
  }

  double _getBellyFactor(double bmi) {
    if (bmi < 18.5) return -0.1;
    if (bmi < 25) return 0.0;
    if (bmi < 30) return 0.3;
    return 0.6;
  }

  @override
  bool shouldRepaint(BMICharacterPainter oldDelegate) {
    return oldDelegate.bmi != bmi || 
           oldDelegate.gender != gender ||
           oldDelegate.animationValue != animationValue;
  }
}