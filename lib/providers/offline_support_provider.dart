import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../services/connectivity_service.dart';
import '../services/offline_queue_service.dart';

/// 오프라인 지원 상태
class OfflineSupportState {
  final NetworkInfo networkInfo;
  final int queueSize;
  final bool isProcessingQueue;
  final String? lastError;

  const OfflineSupportState({
    required this.networkInfo,
    this.queueSize = 0,
    this.isProcessingQueue = false,
    this.lastError,
  });

  OfflineSupportState copyWith({
    NetworkInfo? networkInfo,
    int? queueSize,
    bool? isProcessingQueue,
    String? lastError,
  }) {
    return OfflineSupportState(
      networkInfo: networkInfo ?? this.networkInfo,
      queueSize: queueSize ?? this.queueSize,
      isProcessingQueue: isProcessingQueue ?? this.isProcessingQueue,
      lastError: lastError,
    );
  }
}

/// 오프라인 지원 StateNotifier
class OfflineSupportNotifier extends StateNotifier<OfflineSupportState> {
  OfflineSupportNotifier() : super(
    OfflineSupportState(
      networkInfo: NetworkInfo(
        status: NetworkStatus.checking,
        lastChecked: DateTime.now(),
      ),
    ),
  ) {
    _initialize();
  }

  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineQueueService _offlineQueueService = OfflineQueueService();

  /// 초기화
  Future<void> _initialize() async {
    try {
      // 연결 서비스 초기화
      await _connectivityService.initialize();
      
      // 오프라인 큐 서비스 초기화
      await _offlineQueueService.initialize();
      
      // 초기 상태 업데이트
      await _updateNetworkStatus();
      _updateQueueSize();
      
      // 연결 상태 변화 리스닝
      _connectivityService.connectionChange.listen((isConnected) {
        _handleConnectionChange(isConnected);
      });
      
      debugPrint('OfflineSupportProvider 초기화 완료');
    } catch (e) {
      state = state.copyWith(
        lastError: '오프라인 지원 초기화 실패: $e',
      );
      debugPrint('오프라인 지원 초기화 실패: $e');
    }
  }

  /// 네트워크 상태 업데이트
  Future<void> _updateNetworkStatus() async {
    final isConnected = await _connectivityService.checkConnection();
    
    state = state.copyWith(
      networkInfo: NetworkInfo(
        status: isConnected ? NetworkStatus.connected : NetworkStatus.disconnected,
        lastChecked: DateTime.now(),
      ),
    );
  }

  /// 큐 크기 업데이트
  void _updateQueueSize() {
    state = state.copyWith(
      queueSize: _offlineQueueService.pendingOperationsCount,
    );
  }

  /// 연결 상태 변화 처리
  void _handleConnectionChange(bool isConnected) {
    state = state.copyWith(
      networkInfo: NetworkInfo(
        status: isConnected ? NetworkStatus.connected : NetworkStatus.disconnected,
        lastChecked: DateTime.now(),
      ),
    );
    
    if (isConnected) {
      // 연결 복구 시 큐 처리
      _processOfflineQueue();
    }
  }

  /// 오프라인 큐 처리
  Future<void> _processOfflineQueue() async {
    if (state.isProcessingQueue) return;
    
    state = state.copyWith(
      isProcessingQueue: true,
      lastError: null,
    );
    
    try {
      await _offlineQueueService.processQueue();
      _updateQueueSize();
      
      debugPrint('오프라인 큐 처리 완료');
    } catch (e) {
      state = state.copyWith(
        lastError: '큐 처리 실패: $e',
      );
      debugPrint('오프라인 큐 처리 실패: $e');
    } finally {
      state = state.copyWith(
        isProcessingQueue: false,
      );
    }
  }

  /// 수동으로 큐 처리 시작
  Future<void> processQueueManually() async {
    if (!state.networkInfo.isConnected) {
      state = state.copyWith(
        lastError: '네트워크 연결이 없습니다',
      );
      return;
    }
    
    await _processOfflineQueue();
  }

  /// 네트워크 상태 다시 확인
  Future<void> checkNetworkStatus() async {
    state = state.copyWith(
      networkInfo: state.networkInfo.copyWith(
        status: NetworkStatus.checking,
      ),
    );
    
    await _updateNetworkStatus();
  }

  /// 큐 상태 새로고침
  void refreshQueueStatus() {
    _updateQueueSize();
  }

  /// 오프라인 큐 비우기 (디버그용)
  Future<void> clearOfflineQueue() async {
    await _offlineQueueService.clearQueue();
    _updateQueueSize();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}

/// 오프라인 지원 Provider
final offlineSupportProvider = StateNotifierProvider<OfflineSupportNotifier, OfflineSupportState>((ref) {
  return OfflineSupportNotifier();
});

/// 편의를 위한 추가 Provider들
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(offlineSupportProvider).networkInfo.isConnected;
});

final offlineQueueSizeProvider = Provider<int>((ref) {
  return ref.watch(offlineSupportProvider).queueSize;
});

final isProcessingQueueProvider = Provider<bool>((ref) {
  return ref.watch(offlineSupportProvider).isProcessingQueue;
});

final networkStatusProvider = Provider<NetworkStatus>((ref) {
  return ref.watch(offlineSupportProvider).networkInfo.status;
});