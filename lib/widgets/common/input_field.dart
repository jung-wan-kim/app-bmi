import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import '../../core/constants/app_colors.dart';

class InputField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final Color? fillColor;
  final bool filled;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final String? semanticLabel;
  final String? errorText;

  const InputField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.border,
    this.focusedBorder,
    this.errorBorder,
    this.fillColor,
    this.filled = true,
    this.contentPadding,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.semanticLabel,
    this.errorText,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? 
        TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    _errorText = widget.errorText;
  }

  @override
  void didUpdateWidget(InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      setState(() {
        _errorText = widget.errorText;
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        width: 1,
      ),
    );
    
    final defaultFocusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.primaryColor,
        width: 2,
      ),
    );
    
    final defaultErrorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.colorScheme.error,
        width: 2,
      ),
    );

    final effectiveFillColor = widget.fillColor ?? 
        (isDark ? Colors.grey[900] : Colors.grey[50]);

    final field = TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText && _obscureText,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
      style: widget.style ?? theme.textTheme.bodyLarge,
      onChanged: (value) {
        if (widget.validator != null && _errorText != null) {
          final error = widget.validator!(value);
          if (error != _errorText) {
            setState(() {
              _errorText = error;
            });
          }
        }
        widget.onChanged?.call(value);
      },
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      validator: (value) {
        final error = widget.validator?.call(value);
        if (error != _errorText) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _errorText = error;
            });
          });
        }
        return error;
      },
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: widget.labelStyle ?? TextStyle(
          color: _focusNode.hasFocus 
              ? theme.primaryColor 
              : theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
          fontSize: 16,
        ),
        hintText: widget.hint,
        hintStyle: widget.hintStyle ?? TextStyle(
          color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
          fontSize: 16,
        ),
        errorText: _errorText,
        errorMaxLines: 2,
        prefixIcon: widget.prefixIcon,
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon:const Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: theme.iconTheme.color?.withValues(alpha: 0.7),
                ),
                onPressed: _toggleObscureText,
                tooltip: _obscureText ? '비밀번호 표시' : '비밀번호 숨기기',
              )
            : widget.suffixIcon,
        filled: widget.filled,
        fillColor: effectiveFillColor,
        contentPadding: widget.contentPadding ?? 
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: widget.border ?? defaultBorder,
        enabledBorder: widget.border ?? defaultBorder,
        focusedBorder: widget.focusedBorder ?? defaultFocusedBorder,
        errorBorder: widget.errorBorder ?? defaultErrorBorder,
        focusedErrorBorder: widget.errorBorder ?? defaultErrorBorder,
        disabledBorder: widget.border ?? defaultBorder,
      ),
    );

    return Semantics(
      textField: true,
      label: widget.semanticLabel ?? widget.label,
      enabled: widget.enabled,
      obscured: widget.obscureText && _obscureText,
      child: field,
    );
  }
}

class NumericInputField extends StatelessWidget {
  final String label;
  final String? hint;
  final double? initialValue;
  final void Function(double?) onChanged;
  final String? Function(String?)? validator;
  final double? min;
  final double? max;
  final int decimalPlaces;
  final String? suffix;
  final IconData? prefixIcon;
  final bool enabled;
  final String? semanticLabel;

  const NumericInputField({
    super.key,
    required this.label,
    required this.onChanged,
    this.hint,
    this.initialValue,
    this.validator,
    this.min,
    this.max,
    this.decimalPlaces = 1,
    this.suffix,
    this.prefixIcon,
    this.enabled = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return InputField(
      label: label,
      hint: hint,
      initialValue: initialValue?.toStringAsFixed(decimalPlaces),
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimalPlaces > 0,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'^\d*\.?\d{0,' + decimalPlaces.toString() + r'}'),
        ),
      ],
      validator: (value) {
        if (validator != null) {
          return validator!(value);
        }
        if (value == null || value.isEmpty) {
          return null;
        }
        final number = double.tryParse(value);
        if (number == null) {
          return '유효한 숫자를 입력해주세요';
        }
        if (min != null && number < min!) {
          return '최소값은 $min입니다';
        }
        if (max != null && number > max!) {
          return '최대값은 $max입니다';
        }
        return null;
      },
      onChanged: (value) {
        final number = double.tryParse(value);
        onChanged(number);
      },
      suffixText: suffix,
      prefixIcon: prefixIcon != null ?const Icon(prefixIcon) : null,
      enabled: enabled,
      semanticLabel: semanticLabel,
    );
  }
}