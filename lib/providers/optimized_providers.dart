import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/optimized_data_service.dart';
import '../models/weight_record_model.dart';

/// 최적화된 데이터 서비스 프로바이더
final optimizedDataServiceProvider = Provider((ref) => OptimizedDataService());

/// 페이지네이션된 체중 기록 프로바이더
final paginatedWeightRecordsProvider = StateNotifierProvider<
    PaginatedWeightRecordsNotifier, AsyncValue<List<WeightRecord>>>((ref) {
  return PaginatedWeightRecordsNotifier(ref);
});

class PaginatedWeightRecordsNotifier extends StateNotifier<AsyncValue<List<WeightRecord>>> {
  final Ref ref;
  final List<WeightRecord> _allRecords = [];
  int _currentPage = 0;
  bool _hasMore = true;
  
  PaginatedWeightRecordsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadInitialData();
  }
  
  Future<void> loadInitialData() async {
    state = const AsyncValue.loading();
    
    try {
      final userId = ref.read(currentUserIdProvider); // 현재 사용자 ID 가져오기
      if (userId == null) {
        state = AsyncValue.error('User not logged in', StackTrace.current);
        return;
      }
      
      final service = ref.read(optimizedDataServiceProvider);
      final records = await service.fetchWeightRecordsPaginated(
        userId: userId,
        page: 0,
        refresh: true,
      );
      
      _allRecords.clear();
      _allRecords.addAll(records);
      _currentPage = 1;
      _hasMore = records.length >= 20;
      
      state = AsyncValue.data(_allRecords);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return;
      
      final service = ref.read(optimizedDataServiceProvider);
      final newRecords = await service.fetchWeightRecordsPaginated(
        userId: userId,
        page: _currentPage,
      );
      
      if (newRecords.isNotEmpty) {
        _allRecords.addAll(newRecords);
        _currentPage++;
        _hasMore = newRecords.length >= 20;
        state = AsyncValue.data(_allRecords);
      } else {
        _hasMore = false;
      }
    } catch (e, stack) {
      // 로드 더 실패 시 기존 데이터는 유지
      state = AsyncValue.data(_allRecords);
    }
  }
  
  Future<void> refresh() async {
    await loadInitialData();
  }
}

/// 최근 기록 캐싱 프로바이더 (홈 화면용)
final recentWeightRecordsProvider = FutureProvider.autoDispose
    .family<List<WeightRecord>, int>((ref, limit) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  
  final service = ref.watch(optimizedDataServiceProvider);
  return service.fetchRecentRecords(userId: userId, limit: limit);
});

/// 통계 데이터 캐싱 프로바이더
final cachedStatisticsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, DateRange>((ref, dateRange) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return {};
  
  final service = ref.watch(optimizedDataServiceProvider);
  return service.fetchStatistics(
    userId: userId,
    startDate: dateRange.start,
    endDate: dateRange.end,
  );
});

/// 데이터 프리페칭 프로바이더
final dataPrefetchProvider = Provider((ref) {
  return DataPrefetcher(ref);
});

class DataPrefetcher {
  final Ref ref;
  
  DataPrefetcher(this.ref);
  
  Future<void> prefetchHomeScreenData() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    
    // 병렬로 필요한 데이터 프리페치
    await Future.wait([
      ref.read(recentWeightRecordsProvider(7).future),
      ref.read(cachedStatisticsProvider(
        DateRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        ),
      ).future),
    ]);
  }
  
  Future<void> prefetchStatisticsScreenData() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    
    // 통계 화면에 필요한 데이터 프리페치
    final now = DateTime.now();
    await Future.wait([
      // 주간 데이터
      ref.read(cachedStatisticsProvider(
        DateRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        ),
      ).future),
      // 월간 데이터
      ref.read(cachedStatisticsProvider(
        DateRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        ),
      ).future),
      // 연간 데이터
      ref.read(cachedStatisticsProvider(
        DateRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        ),
      ).future),
    ]);
  }
}

// Helper classes
class DateRange {
  final DateTime start;
  final DateTime end;
  
  const DateRange({required this.start, required this.end});
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;
  
  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

// Mock provider - 실제 구현에서는 auth provider에서 가져와야 함
final currentUserIdProvider = Provider<String?>((ref) {
  // TODO: 실제 인증 상태에서 사용자 ID 가져오기
  return 'mock-user-id';
});