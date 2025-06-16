/// 성능 최적화 설정 및 유틸리티
class PerformanceConfig {
  // 캐싱 설정
  static const int maxCacheSize = 100; // 최대 캐시 항목 수
  static const Duration cacheExpiration = Duration(hours: 1);
  
  // 페이지네이션 설정
  static const int pageSize = 20; // 한 번에 로드할 항목 수
  static const int prefetchThreshold = 5; // 미리 가져올 항목 수
  
  // 이미지 최적화 설정
  static const int maxImageWidth = 800;
  static const int imageQuality = 85;
  
  // 애니메이션 설정
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const bool enableComplexAnimations = true;
  
  // 렌더링 최적화
  static const bool useRepaintBoundary = true;
  static const bool enableOffscreenLayers = true;
}

/// 메모이제이션 헬퍼
class Memoizer<T> {
  final Map<String, T> _cache = {};
  final Duration? expiration;
  final Map<String, DateTime> _timestamps = {};
  
  Memoizer({this.expiration});
  
  T? get(String key) {
    if (!_cache.containsKey(key)) return null;
    
    if (expiration != null) {
      final timestamp = _timestamps[key];
      if (timestamp != null && 
          DateTime.now().difference(timestamp) > expiration!) {
        _cache.remove(key);
        _timestamps.remove(key);
        return null;
      }
    }
    
    return _cache[key];
  }
  
  void set(String key, T value) {
    _cache[key] = value;
    if (expiration != null) {
      _timestamps[key] = DateTime.now();
    }
    
    // 캐시 크기 제한
    if (_cache.length > PerformanceConfig.maxCacheSize) {
      final oldestKey = _timestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _cache.remove(oldestKey);
      _timestamps.remove(oldestKey);
    }
  }
  
  void clear() {
    _cache.clear();
    _timestamps.clear();
  }
}