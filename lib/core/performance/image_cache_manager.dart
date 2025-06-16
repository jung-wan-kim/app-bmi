import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 이미지 캐시 관리자
/// 네트워크 이미지 캐싱 및 메모리 최적화 담당
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();
  
  // 캐시 설정
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheExpiration = Duration(days: 30);
  
  /// 최적화된 네트워크 이미지 위젯
  static Widget cachedImage({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    Duration fadeInDuration = const Duration(milliseconds: 300),
  }) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      placeholder: placeholder != null 
          ? (context, url) => placeholder 
          : (context, url) => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
      errorWidget: errorWidget != null
          ? (context, url, error) => errorWidget
          : (context, url, error) => const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
      memCacheWidth: width != null ? (width * 2).toInt() : null,
      memCacheHeight: height != null ? (height * 2).toInt() : null,
    );
  }
  
  /// 프리캐싱을 위한 메서드
  static Future<void> precacheImages(
    BuildContext context, 
    List<String> urls,
  ) async {
    await Future.wait(
      urls.map(
        (url) => precacheImage(
          CachedNetworkImageProvider(url),
          context,
        ),
      ),
    );
  }
  
  /// 캐시 클리어
  static Future<void> clearCache() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
  
  /// 캐시 사이즈 제한 설정
  static void configureCacheSize({
    int? maximumSize,
    int? maximumSizeBytes,
  }) {
    PaintingBinding.instance.imageCache.maximumSize = maximumSize ?? 1000;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 
        maximumSizeBytes ?? maxCacheSize;
  }
}

/// 레이지 로딩을 지원하는 이미지 위젯
class LazyImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableLazyLoad;
  final double visibilityThreshold;
  
  const LazyImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableLazyLoad = true,
    this.visibilityThreshold = 0.1,
  });

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  bool _isVisible = false;
  
  @override
  Widget build(BuildContext context) {
    if (!widget.enableLazyLoad) {
      return _buildImage();
    }
    
    return VisibilityDetector(
      key: Key(widget.imageUrl),
      onVisibilityChanged: (info) {
        if (!_isVisible && info.visibleFraction >= widget.visibilityThreshold) {
          setState(() => _isVisible = true);
        }
      },
      child: _isVisible ? _buildImage() : _buildPlaceholder(),
    );
  }
  
  Widget _buildImage() {
    return ImageCacheManager.cachedImage(
      url: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: widget.placeholder,
      errorWidget: widget.errorWidget,
    );
  }
  
  Widget _buildPlaceholder() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: widget.placeholder ?? Container(
        color: Colors.grey[200],
      ),
    );
  }
}

/// VisibilityDetector 위젯 (간단한 구현)
class VisibilityDetector extends StatefulWidget {
  final Key key;
  final Widget child;
  final void Function(VisibilityInfo) onVisibilityChanged;
  
  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onVisibilityChanged(VisibilityInfo(visibleFraction: 1.0));
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class VisibilityInfo {
  final double visibleFraction;
  
  VisibilityInfo({required this.visibleFraction});
}