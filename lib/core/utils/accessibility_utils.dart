import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../constants/app_accessibility.dart';

/// 접근성 관련 유틸리티 함수
class AccessibilityUtils {
  /// 두 색상 간의 대비 비율 계산
  static double calculateContrastRatio(Color foreground, Color background) {
    final l1 = foreground.computeLuminance();
    final l2 = background.computeLuminance();
    final lMax = l1 > l2 ? l1 : l2;
    final lMin = l1 > l2 ? l2 : l1;
    return (lMax + 0.05) / (lMin + 0.05);
  }
  
  /// WCAG 기준에 따른 최소 대비 비율 충족 여부 확인
  static bool meetsContrastGuidelines(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    final minRatio = isLargeText 
        ? AppAccessibility.minLargeTextContrastRatio 
        : AppAccessibility.minContrastRatio;
    return ratio >= minRatio;
  }
  
  /// 배경색에 대해 적절한 전경색 선택
  static Color getAccessibleTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    // 어두운 배경에는 밝은 텍스트, 밝은 배경에는 어두운 텍스트
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
  
  /// 색상의 접근성 버전 생성 (대비 향상)
  static Color makeAccessible(
    Color color,
    Color backgroundColor, {
    bool isLargeText = false,
  }) {
    if (meetsContrastGuidelines(color, backgroundColor, isLargeText: isLargeText)) {
      return color;
    }
    
    // 대비가 부족한 경우 색상 조정
    final hsl = HSLColor.fromColor(color);
    final bgLuminance = backgroundColor.computeLuminance();
    
    // 배경이 어두우면 색상을 밝게, 배경이 밝으면 색상을 어둡게
    if (bgLuminance > 0.5) {
      // 밝은 배경 - 색상을 어둡게
      return hsl.withLightness((hsl.lightness * 0.7).clamp(0.0, 0.5)).toColor();
    } else {
      // 어두운 배경 - 색상을 밝게
      return hsl.withLightness((hsl.lightness * 1.3).clamp(0.5, 1.0)).toColor();
    }
  }
  
  /// 텍스트가 큰 텍스트인지 확인
  static bool isLargeText(TextStyle? style) {
    if (style == null) return false;
    final fontSize = style.fontSize ?? 14;
    final isBold = (style.fontWeight?.index ?? 400) >= FontWeight.bold.index;
    
    // WCAG 기준: 18pt 이상 또는 14pt 이상의 굵은 텍스트
    return fontSize >= 18 || (fontSize >= 14 && isBold);
  }
  
  /// 터치 타겟 크기 확인
  static bool hasSufficientTouchTarget(Size size) {
    return size.width >= AppAccessibility.minTouchTarget && 
           size.height >= AppAccessibility.minTouchTarget;
  }
  
  /// 시맨틱 발표 메시지 생성
  static void announceForAccessibility(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
}