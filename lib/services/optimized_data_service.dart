import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/weight_record_model.dart';
import '../core/performance/performance_config.dart';

/// 최적화된 데이터 서비스
/// 캐싱, 페이지네이션, 배치 처리를 통한 성능 최적화
class OptimizedDataService {
  final _supabase = Supabase.instance.client;
  
  // 캐시 관리
  final _recordsCache = Memoizer<List<WeightRecord>>(
    expiration: PerformanceConfig.cacheExpiration,
  );
  final _statsCache = Memoizer<Map<String, dynamic>>(
    expiration: const Duration(minutes: 30),
  );
  
  // 페이지네이션 상태
  int _currentPage = 0;
  bool _hasMore = true;
  final List<WeightRecord> _allRecords = [];
  
  /// 페이지네이션된 체중 기록 가져오기
  Future<List<WeightRecord>> fetchWeightRecordsPaginated({
    required String userId,
    int page = 0,
    int pageSize = PerformanceConfig.pageSize,
    bool refresh = false,
  }) async {
    if (refresh) {
      _recordsCache.clear();
      _allRecords.clear();
      _currentPage = 0;
      _hasMore = true;
    }
    
    final cacheKey = 'records_${userId}_${page}_$pageSize';
    final cached = _recordsCache.get(cacheKey);
    if (cached != null && !refresh) {
      return cached;
    }
    
    try {
      final response = await _supabase
          .from('weight_records')
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);
      
      final records = (response as List)
          .map((json) => WeightRecord.fromJson(json))
          .toList();
      
      _recordsCache.set(cacheKey, records);
      _hasMore = records.length >= pageSize;
      
      return records;
    } catch (e) {
      debugPrint('Error fetching paginated records: $e');
      return [];
    }
  }
  
  /// 무한 스크롤을 위한 다음 페이지 로드
  Future<List<WeightRecord>> loadNextPage(String userId) async {
    if (!_hasMore) return [];
    
    final records = await fetchWeightRecordsPaginated(
      userId: userId,
      page: _currentPage,
    );
    
    if (records.isNotEmpty) {
      _allRecords.addAll(records);
      _currentPage++;
    }
    
    return records;
  }
  
  /// 최근 N개의 기록만 가져오기 (홈 화면용)
  Future<List<WeightRecord>> fetchRecentRecords({
    required String userId,
    int limit = 7,
  }) async {
    final cacheKey = 'recent_${userId}_$limit';
    final cached = _recordsCache.get(cacheKey);
    if (cached != null) return cached;
    
    try {
      final response = await _supabase
          .from('weight_records')
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: false)
          .limit(limit);
      
      final records = (response as List)
          .map((json) => WeightRecord.fromJson(json))
          .toList();
      
      _recordsCache.set(cacheKey, records);
      return records;
    } catch (e) {
      debugPrint('Error fetching recent records: $e');
      return [];
    }
  }
  
  /// 통계 데이터 캐싱과 함께 가져오기
  Future<Map<String, dynamic>> fetchStatistics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final cacheKey = 'stats_${userId}_${startDate.toIso8601String()}_${endDate.toIso8601String()}';
    final cached = _statsCache.get(cacheKey);
    if (cached != null) return cached;
    
    try {
      // 병렬 처리로 여러 통계 동시 계산
      final results = await Future.wait([
        _calculateAverageWeight(userId, startDate, endDate),
        _calculateWeightChange(userId, startDate, endDate),
        _calculateBMITrend(userId, startDate, endDate),
        _calculateStreaks(userId),
      ]);
      
      final stats = {
        'averageWeight': results[0],
        'weightChange': results[1],
        'bmiTrend': results[2],
        'streaks': results[3],
      };
      
      _statsCache.set(cacheKey, stats);
      return stats;
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
      return {};
    }
  }
  
  /// 배치 삽입 최적화
  Future<bool> batchInsertRecords(List<WeightRecord> records) async {
    if (records.isEmpty) return true;
    
    try {
      // 배치로 한 번에 삽입
      final batch = records.map((record) => record.toJson()).toList();
      await _supabase.from('weight_records').insert(batch);
      
      // 캐시 무효화
      _recordsCache.clear();
      _statsCache.clear();
      
      return true;
    } catch (e) {
      debugPrint('Error batch inserting records: $e');
      return false;
    }
  }
  
  /// 데이터 프리페칭
  Future<void> prefetchData(String userId) async {
    // 백그라운드에서 데이터 미리 로드
    compute(_backgroundPrefetch, {
      'userId': userId,
      'supabaseUrl': _supabase.supabaseUrl,
      'supabaseKey': _supabase.supabaseKey,
    });
  }
  
  // Private helper methods
  Future<double?> _calculateAverageWeight(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _supabase
        .from('weight_records')
        .select('weight')
        .eq('user_id', userId)
        .gte('recorded_at', startDate.toIso8601String())
        .lte('recorded_at', endDate.toIso8601String());
    
    final weights = (response as List).map((r) => r['weight'] as double).toList();
    if (weights.isEmpty) return null;
    
    return weights.reduce((a, b) => a + b) / weights.length;
  }
  
  Future<double?> _calculateWeightChange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final firstRecord = await _supabase
        .from('weight_records')
        .select('weight')
        .eq('user_id', userId)
        .gte('recorded_at', startDate.toIso8601String())
        .order('recorded_at')
        .limit(1)
        .single();
    
    final lastRecord = await _supabase
        .from('weight_records')
        .select('weight')
        .eq('user_id', userId)
        .lte('recorded_at', endDate.toIso8601String())
        .order('recorded_at', ascending: false)
        .limit(1)
        .single();
    
    if (firstRecord == null || lastRecord == null) return null;
    
    return (lastRecord['weight'] as double) - (firstRecord['weight'] as double);
  }
  
  Future<List<double>> _calculateBMITrend(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _supabase
        .from('weight_records')
        .select('bmi, recorded_at')
        .eq('user_id', userId)
        .gte('recorded_at', startDate.toIso8601String())
        .lte('recorded_at', endDate.toIso8601String())
        .order('recorded_at');
    
    return (response as List)
        .map((r) => r['bmi'] as double)
        .toList();
  }
  
  Future<Map<String, int>> _calculateStreaks(String userId) async {
    final response = await _supabase
        .from('weight_records')
        .select('recorded_at')
        .eq('user_id', userId)
        .order('recorded_at', ascending: false)
        .limit(365); // 최대 1년치
    
    final dates = (response as List)
        .map((r) => DateTime.parse(r['recorded_at']))
        .toList();
    
    int currentStreak = 0;
    int longestStreak = 0;
    DateTime? lastDate;
    
    for (final date in dates) {
      if (lastDate == null || 
          lastDate.difference(date).inDays == 1) {
        currentStreak++;
        longestStreak = currentStreak > longestStreak 
            ? currentStreak 
            : longestStreak;
      } else if (lastDate.difference(date).inDays > 1) {
        currentStreak = 1;
      }
      lastDate = date;
    }
    
    return {
      'current': currentStreak,
      'longest': longestStreak,
    };
  }
  
  /// 캐시 클리어
  void clearCache() {
    _recordsCache.clear();
    _statsCache.clear();
    _allRecords.clear();
    _currentPage = 0;
    _hasMore = true;
  }
}

/// 백그라운드 프리페치 함수
Future<void> _backgroundPrefetch(Map<String, dynamic> params) async {
  final client = SupabaseClient(
    params['supabaseUrl'],
    params['supabaseKey'],
  );
  
  // 최근 기록 프리페치
  await client
      .from('weight_records')
      .select()
      .eq('user_id', params['userId'])
      .order('recorded_at', ascending: false)
      .limit(30);
}