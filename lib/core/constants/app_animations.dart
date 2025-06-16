import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 애니메이션 상수
class AppAnimations {
  // Duration
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
  static const Duration extraLongDuration = Duration(milliseconds: 800);
  
  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve springCurve = Curves.fastOutSlowIn;
  
  // Page Transition
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOut;
  
  // Card Animation
  static const Duration cardAnimationDuration = Duration(milliseconds: 400);
  static const Curve cardAnimationCurve = Curves.easeOutBack;
  
  // Chart Animation
  static const Duration chartAnimationDuration = Duration(milliseconds: 1000);
  static const Curve chartAnimationCurve = Curves.easeInOutCubic;
  
  // List Item Animation
  static const Duration listItemDuration = Duration(milliseconds: 250);
  static const Duration listItemStaggerDelay = Duration(milliseconds: 50);
  
  // Scale Animation Values
  static const double scaleStart = 0.0;
  static const double scaleEnd = 1.0;
  static const double scalePressed = 0.95;
  
  // Fade Animation Values
  static const double fadeStart = 0.0;
  static const double fadeEnd = 1.0;
  
  // Slide Animation Values
  static const Offset slideStart = Offset(0.0, 0.5);
  static const Offset slideEnd = Offset.zero;
  static const Offset slideLeftStart = Offset(-1.0, 0.0);
  static const Offset slideRightStart = Offset(1.0, 0.0);
}