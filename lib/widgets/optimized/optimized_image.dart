import 'package:flutter/material.dart';
import '../../core/performance/image_cache_manager.dart';

/// 성능 최적화된 이미지 위젯
/// 자동으로 적절한 해상도를 선택하고 메모리를 효율적으로 관리
class OptimizedImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final BlendMode? colorBlendMode;
  final AlignmentGeometry alignment;
  final String? semanticLabel;
  
  const OptimizedImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.semanticLabel,
  });
  
  /// 애셋 이미지용 생성자
  factory OptimizedImage.asset(
    String name, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    BlendMode? colorBlendMode,
    AlignmentGeometry alignment = Alignment.center,
    String? semanticLabel,
  }) {
    return OptimizedImage(
      key: key,
      imagePath: name,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      alignment: alignment,
      semanticLabel: semanticLabel,
    );
  }
  
  /// 네트워크 이미지용 생성자
  factory OptimizedImage.network(
    String url, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Widget? placeholder,
    Widget? errorWidget,
    String? semanticLabel,
  }) {
    return _NetworkOptimizedImage(
      key: key,
      url: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      semanticLabel: semanticLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 화면 픽셀 밀도에 따라 적절한 크기 계산
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = width != null ? (width! * devicePixelRatio).round() : null;
    final cacheHeight = height != null ? (height! * devicePixelRatio).round() : null;
    
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        alignment: alignment,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(
              Icons.broken_image,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }
}

/// 네트워크 이미지 최적화 위젯
class _NetworkOptimizedImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? semanticLabel;
  
  const _NetworkOptimizedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: LazyImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder ?? Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: errorWidget ?? Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(
            Icons.broken_image,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

/// 아이콘 최적화 위젯
class OptimizedIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;
  
  const OptimizedIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final double iconSize = size ?? iconTheme.size ?? 24.0;
    
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        width: iconSize,
        height: iconSize,
        child: Center(
          child: Icon(
            icon,
            size: iconSize,
            color: color ?? iconTheme.color,
            textDirection: textDirection,
          ),
        ),
      ),
    );
  }
}