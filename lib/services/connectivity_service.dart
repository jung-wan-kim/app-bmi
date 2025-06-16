import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 네트워크 연결 상태를 관리하는 서비스
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionChangeController = StreamController<bool>.broadcast();
  
  bool _isConnected = true;
  Timer? _periodicCheckTimer;
  
  /// 현재 연결 상태
  bool get isConnected => _isConnected;
  
  /// 연결 상태 변화 스트림
  Stream<bool> get connectionChange => _connectionChangeController.stream;

  /// 서비스 초기화
  Future<void> initialize() async {
    // 초기 연결 상태 확인
    await checkConnection();
    
    // 연결 상태 변화 리스닝
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) async {
      await _handleConnectivityChange(result);
    });
    
    // 주기적으로 실제 인터넷 연결 확인 (5초마다)
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await checkConnection();
    });
    
    debugPrint('ConnectivityService 초기화 완료');
  }

  /// 연결 상태 변화 처리
  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    debugPrint('네트워크 상태 변경: $result');
    
    if (result == ConnectivityResult.none) {
      _updateConnectionStatus(false);
    } else {
      // 실제 인터넷 연결 확인
      await checkConnection();
    }
  }

  /// 실제 인터넷 연결 확인
  Future<bool> checkConnection() async {
    try {
      // Google DNS에 연결 시도
      final result = await InternetAddress.lookup('google.com');
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _updateConnectionStatus(isConnected);
      return isConnected;
    } on SocketException catch (_) {
      _updateConnectionStatus(false);
      return false;
    } catch (e) {
      debugPrint('연결 확인 중 오류: $e');
      _updateConnectionStatus(false);
      return false;
    }
  }

  /// 연결 상태 업데이트
  void _updateConnectionStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectionChangeController.add(isConnected);
      debugPrint('인터넷 연결 상태: ${isConnected ? "연결됨" : "연결 안 됨"}');
    }
  }

  /// 서비스 정리
  void dispose() {
    _periodicCheckTimer?.cancel();
    _connectionChangeController.close();
  }
}

/// 네트워크 연결 상태 enum
enum NetworkStatus {
  connected,
  disconnected,
  checking,
}

/// 네트워크 상태 정보
class NetworkInfo {
  final NetworkStatus status;
  final DateTime lastChecked;
  final String? errorMessage;

  const NetworkInfo({
    required this.status,
    required this.lastChecked,
    this.errorMessage,
  });

  bool get isConnected => status == NetworkStatus.connected;

  NetworkInfo copyWith({
    NetworkStatus? status,
    DateTime? lastChecked,
    String? errorMessage,
  }) {
    return NetworkInfo(
      status: status ?? this.status,
      lastChecked: lastChecked ?? this.lastChecked,
      errorMessage: errorMessage,
    );
  }
}