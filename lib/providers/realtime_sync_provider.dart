import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../services/realtime_sync_service.dart';
import '../models/weight_record.dart';
import '../models/goal.dart';
import '../providers/notification_settings_provider.dart';
import 'weight_records_provider.dart';
import 'goal_provider.dart';

// 실시간 동기화 상태
class RealtimeSyncState {
  final bool isConnected;
  final bool isInitializing;
  final String? error;
  final DateTime? lastActivity;

  const RealtimeSyncState({
    this.isConnected = false,
    this.isInitializing = false,
    this.error,
    this.lastActivity,
  });

  RealtimeSyncState copyWith({
    bool? isConnected,
    bool? isInitializing,
    String? error,
    DateTime? lastActivity,
  }) {
    return RealtimeSyncState(
      isConnected: isConnected ?? this.isConnected,
      isInitializing: isInitializing ?? this.isInitializing,
      error: error,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}

// 실시간 동기화 StateNotifier
class RealtimeSyncNotifier extends StateNotifier<RealtimeSyncState> {
  RealtimeSyncNotifier(this.ref) : super(const RealtimeSyncState());

  final Ref ref;
  final RealtimeSyncService _realtimeService = RealtimeSyncService();

  /// 실시간 동기화 시작
  Future<void> startRealtimeSync() async {
    if (state.isConnected || state.isInitializing) {
      debugPrint('실시간 동기화가 이미 실행 중이거나 초기화 중입니다');
      return;
    }

    state = state.copyWith(isInitializing: true, error: null);

    try {
      await _realtimeService.startListening(
        // Weight Records 콜백
        onWeightRecordInserted: (record) {
          _handleWeightRecordInserted(record);
        },
        onWeightRecordUpdated: (record) {
          _handleWeightRecordUpdated(record);
        },
        onWeightRecordDeleted: (recordId) {
          _handleWeightRecordDeleted(recordId);
        },
        
        // Goals 콜백
        onGoalInserted: (goal) {
          _handleGoalInserted(goal);
        },
        onGoalUpdated: (goal) {
          _handleGoalUpdated(goal);
        },
        onGoalDeleted: (goalId) {
          _handleGoalDeleted(goalId);
        },
        
        // Notification Settings 콜백
        onNotificationSettingsUpdated: (settings) {
          _handleNotificationSettingsUpdated(settings);
        },
      );

      state = state.copyWith(
        isConnected: true,
        isInitializing: false,
        lastActivity: DateTime.now(),
      );

      debugPrint('실시간 동기화 시작됨');
    } catch (e) {
      state = state.copyWith(
        isConnected: false,
        isInitializing: false,
        error: '실시간 동기화 시작 실패: $e',
      );
      debugPrint('실시간 동기화 시작 실패: $e');
    }
  }

  /// 실시간 동기화 중지
  Future<void> stopRealtimeSync() async {
    if (!state.isConnected) return;

    try {
      await _realtimeService.stopListening();
      state = state.copyWith(
        isConnected: false,
        isInitializing: false,
        error: null,
      );
      debugPrint('실시간 동기화 중지됨');
    } catch (e) {
      debugPrint('실시간 동기화 중지 실패: $e');
    }
  }

  /// Weight Record 삽입 처리
  void _handleWeightRecordInserted(WeightRecord record) {
    try {
      // WeightRecordsProvider에 새 기록 추가
      ref.read(weightRecordsProvider.notifier).addRecordFromRealtime(record);
      
      state = state.copyWith(lastActivity: DateTime.now());
      debugPrint('실시간 체중 기록 추가: ${record.weight}kg');
    } catch (e) {
      debugPrint('체중 기록 실시간 추가 실패: $e');
    }
  }

  /// Weight Record 업데이트 처리
  void _handleWeightRecordUpdated(WeightRecord record) {
    try {
      // WeightRecordsProvider에서 기록 업데이트
      ref.read(weightRecordsProvider.notifier).updateRecordFromRealtime(record);
      
      state = state.copyWith(lastActivity: DateTime.now());
      debugPrint('실시간 체중 기록 업데이트: ${record.weight}kg');
    } catch (e) {
      debugPrint('체중 기록 실시간 업데이트 실패: $e');
    }
  }

  /// Weight Record 삭제 처리
  void _handleWeightRecordDeleted(String recordId) {
    try {
      // WeightRecordsProvider에서 기록 삭제
      ref.read(weightRecordsProvider.notifier).deleteRecordFromRealtime(recordId);
      
      state = state.copyWith(lastActivity: DateTime.now());
      debugPrint('실시간 체중 기록 삭제: $recordId');
    } catch (e) {
      debugPrint('체중 기록 실시간 삭제 실패: $e');
    }
  }

  /// Goal 삽입 처리
  void _handleGoalInserted(Goal goal) {
    try {
      // GoalProvider에 새 목표 설정
      ref.read(goalProvider.notifier).setGoalFromRealtime(goal);
      
      state = state.copyWith(lastActivity: DateTime.now());
      debugPrint('실시간 목표 추가: ${goal.targetWeight}kg');
    } catch (e) {
      debugPrint('목표 실시간 추가 실패: $e');
    }
  }

  /// Goal 업데이트 처리
  void _handleGoalUpdated(Goal goal) {
    try {
      // GoalProvider에서 목표 업데이트
      ref.read(goalProvider.notifier).setGoalFromRealtime(goal);
      
      state = state.copyWith(lastActivity: DateTime.now());
      debugPrint('실시간 목표 업데이트: ${goal.targetWeight}kg');
    } catch (e) {
      debugPrint('목표 실시간 업데이트 실패: $e');
    }
  }

  /// Goal 삭제 처리
  void _handleGoalDeleted(String goalId) {
    try {
      // GoalProvider에서 목표 삭제
      ref.read(goalProvider.notifier).clearGoalFromRealtime();
      
      state = state.copyWith(lastActivity: DateTime.now());
      debugPrint('실시간 목표 삭제: $goalId');
    } catch (e) {
      debugPrint('목표 실시간 삭제 실패: $e');
    }
  }

  /// Notification Settings 업데이트 처리
  void _handleNotificationSettingsUpdated(NotificationSettings settings) {
    try {
      // NotificationSettingsProvider에서 설정 업데이트
      ref.read(notificationSettingsProvider.notifier).updateFromRealtime(settings);
      
      state = state.copyWith(lastActivity: DateTime.now());
      debugPrint('실시간 알림 설정 업데이트');
    } catch (e) {
      debugPrint('알림 설정 실시간 업데이트 실패: $e');
    }
  }

  /// 에러 상태 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _realtimeService.dispose();
    super.dispose();
  }
}

// Riverpod Providers
final realtimeSyncProvider = StateNotifierProvider<RealtimeSyncNotifier, RealtimeSyncState>((ref) {
  return RealtimeSyncNotifier(ref);
});

// 편의를 위한 추가 Provider들
final isRealtimeConnectedProvider = Provider<bool>((ref) {
  return ref.watch(realtimeSyncProvider).isConnected;
});

final realtimeErrorProvider = Provider<String?>((ref) {
  return ref.watch(realtimeSyncProvider).error;
});

final realtimeLastActivityProvider = Provider<DateTime?>((ref) {
  return ref.watch(realtimeSyncProvider).lastActivity;
});