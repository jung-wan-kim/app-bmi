import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';

// 동기화 상태를 나타내는 클래스
class SyncState {
  final bool isLoading;
  final bool isInitialized;
  final SyncResult? lastResult;
  final DateTime? lastSyncTime;
  final String? error;

  const SyncState({
    this.isLoading = false,
    this.isInitialized = false,
    this.lastResult,
    this.lastSyncTime,
    this.error,
  });

  SyncState copyWith({
    bool? isLoading,
    bool? isInitialized,
    SyncResult? lastResult,
    DateTime? lastSyncTime,
    String? error,
  }) {
    return SyncState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      lastResult: lastResult ?? this.lastResult,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      error: error,
    );
  }
}

// 동기화 서비스를 관리하는 StateNotifier
class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier() : super(const SyncState());

  final SyncService _syncService = SyncService();

  /// 동기화 서비스 초기화
  Future<void> initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _syncService.initialize();
      final lastSyncTime = await _syncService.getLastSyncTime();
      
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        lastSyncTime: lastSyncTime,
      );
      
      debugPrint('SyncProvider 초기화 완료');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '동기화 서비스 초기화 실패: $e',
      );
      debugPrint('SyncProvider 초기화 실패: $e');
    }
  }

  /// 전체 데이터 동기화 실행
  Future<void> syncAll() async {
    if (!state.isInitialized) {
      await initialize();
    }

    if (state.isLoading) {
      debugPrint('이미 동기화가 진행 중입니다');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _syncService.syncAll();
      final lastSyncTime = await _syncService.getLastSyncTime();
      
      state = state.copyWith(
        isLoading: false,
        lastResult: result,
        lastSyncTime: lastSyncTime,
        error: result.success ? null : result.error,
      );

      debugPrint('동기화 완료: ${result.toString()}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '동기화 실패: $e',
      );
      debugPrint('동기화 실패: $e');
    }
  }

  /// 동기화 상태 새로고침
  Future<void> refreshStatus() async {
    if (!state.isInitialized) return;

    try {
      final lastSyncTime = await _syncService.getLastSyncTime();
      state = state.copyWith(lastSyncTime: lastSyncTime);
    } catch (e) {
      debugPrint('동기화 상태 새로고침 실패: $e');
    }
  }

  /// 에러 상태 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Riverpod Provider
final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier();
});

// 동기화 상태 전용 Provider들
final isSyncingProvider = Provider<bool>((ref) {
  return ref.watch(syncProvider).isLoading;
});

final lastSyncTimeProvider = Provider<DateTime?>((ref) {
  return ref.watch(syncProvider).lastSyncTime;
});

final syncErrorProvider = Provider<String?>((ref) {
  return ref.watch(syncProvider).error;
});

final lastSyncResultProvider = Provider<SyncResult?>((ref) {
  return ref.watch(syncProvider).lastResult;
});