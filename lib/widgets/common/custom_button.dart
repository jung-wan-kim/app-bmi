import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 56.0,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 16.0,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.padding,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final effectiveBackgroundColor = backgroundColor ?? 
        (isOutlined ? Colors.transparent : theme.primaryColor);
    final effectiveTextColor = textColor ?? 
        (isOutlined 
            ? theme.primaryColor 
            : (isDark ? Colors.black : Colors.white));
    
    final buttonChild = isLoading
        ?const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[const Icon(
                  icon,
                  color: effectiveTextColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(width ?? double.infinity, height),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
              side: BorderSide(
                color: onPressed == null 
                    ? theme.disabledColor 
                    : theme.primaryColor,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(width ?? double.infinity, height),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
              backgroundColor: effectiveBackgroundColor,
              foregroundColor: effectiveTextColor,
              disabledBackgroundColor: theme.disabledColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: buttonChild,
          );

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: semanticLabel ?? text,
      child:const SizedBox(
        width: width,
        height: height,
        child: button,
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final String? tooltip;
  final String? semanticLabel;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 48.0,
    this.iconSize = 24.0,
    this.tooltip,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.iconTheme.color;
    
    final button = Material(
      color: backgroundColor ?? Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: iconSize,
            color: onPressed == null 
                ? theme.disabledColor 
                : effectiveColor,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Semantics(
        button: true,
        enabled: onPressed != null,
        label: semanticLabel ?? tooltip,
        child: Tooltip(
          message: tooltip!,
          child: button,
        ),
      );
    }

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      child: button,
    );
  }
}