import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../core/constants/app_accessibility.dart';
import '../core/constants/app_colors.dart';

/// 접근성이 향상된 버튼 위젯
class AccessibleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final bool isDestructive;
  final bool excludeSemantics;

  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.isDestructive = false,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // 기본 색상 설정
    final bgColor = backgroundColor ?? 
        (isDestructive ? AppColors.error : theme.colorScheme.primary);
    final fgColor = foregroundColor ?? Colors.white;
    
    // 컨트라스트 비율 확인
    final contrastRatio = _calculateContrastRatio(fgColor, bgColor);
    final meetsContrast = contrastRatio >= AppAccessibility.minContrastRatio;
    
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      hint: semanticHint,
      excludeSemantics: excludeSemantics,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: BoxConstraints(
              minHeight: AppAccessibility.minTouchTarget,
              minWidth: AppAccessibility.minTouchTarget,
            ),
            padding: padding ?? const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: onPressed != null ? bgColor : bgColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: !meetsContrast ? Border.all(
                color: isDarkMode ? Colors.white : Colors.black,
                width: 2,
              ) : null,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: fgColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
  
  // 컨트라스트 비율 계산
  double _calculateContrastRatio(Color foreground, Color background) {
    final l1 = foreground.computeLuminance();
    final l2 = background.computeLuminance();
    final lMax = l1 > l2 ? l1 : l2;
    final lMin = l1 > l2 ? l2 : l1;
    return (lMax + 0.05) / (lMin + 0.05);
  }
}

/// 접근성이 향상된 아이콘 버튼
class AccessibleIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String semanticLabel;
  final String? semanticHint;
  final double? iconSize;
  final Color? color;
  final bool isDestructive;

  const AccessibleIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.semanticLabel,
    this.semanticHint,
    this.iconSize,
    this.color,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? 
        (isDestructive ? AppColors.error : theme.iconTheme.color);
    
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      hint: semanticHint,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: AppAccessibility.minTouchTarget,
            height: AppAccessibility.minTouchTarget,
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: iconSize ?? 24,
              color: onPressed != null ? iconColor : iconColor?.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}