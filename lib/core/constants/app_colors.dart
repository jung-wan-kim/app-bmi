import 'package:flutter/material.dart';

/// 앱의 색상 테마 정의
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);
  
  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Light Theme Colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  
  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textDisabledDark = Color(0xFF6B7280);
  static const Color borderDark = Color(0xFF374151);
  
  // BMI Colors
  static const Color bmiUnderweight = Color(0xFF3B82F6); // Blue
  static const Color bmiNormal = Color(0xFF10B981); // Green
  static const Color bmiOverweight = Color(0xFFF59E0B); // Amber
  static const Color bmiObese = Color(0xFFEF4444); // Red
  
  // Chart Colors
  static const List<Color> chartGradient = [
    Color(0xFF4F46E5),
    Color(0xFF818CF8),
  ];
  
  // Shadow
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowColorDark = Color(0x33FFFFFF);
}