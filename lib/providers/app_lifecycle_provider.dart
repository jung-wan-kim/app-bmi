import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'realtime_sync_provider.dart';
import 'sync_provider.dart';
import 'offline_support_provider.dart';

/// 앱 생명주기를 관리하는 Provider
class AppLifecycleNotifier extends StateNotifier<bool> {
  AppLifecycleNotifier(this.ref) : super(false) {
    _initialize();
  }

  final Ref ref;

  /// 앱 초기화
  Future<void> _initialize() async {
    try {
      // 오프라인 지원 초기화
      ref.read(offlineSupportProvider.notifier);
      debugPrint('오프라인 지원 초기화');
      
      // 사용자 인증 상태 확인
      await _checkAuthenticationAndStartRealtimeSync();
      
      // Supabase 인증 상태 변화 리스닝
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        _handleAuthStateChange(data.event, data.session);
      });

      state = true;
      debugPrint('앱 초기화 완료');
    } catch (e) {
      debugPrint('앱 초기화 실패: $e');
    }
  }

  /// 인증 상태 확인 및 실시간 동기화 시작
  Future<void> _checkAuthenticationAndStartRealtimeSync() async {
    final user = Supabase.instance.client.auth.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final isDemoMode = prefs.getBool('isDemoMode') ?? false;

    if (user != null && !isDemoMode) {
      debugPrint('사용자 로그인 상태, 실시간 동기화 시작');
      
      // 실시간 동기화 시작
      await ref.read(realtimeSyncProvider.notifier).startRealtimeSync();
      
      // 초기 동기화 수행 (백그라운드에서)
      _performInitialSync();
    } else {
      debugPrint('사용자가 로그인하지 않았거나 데모 모드입니다');
    }
  }

  /// 인증 상태 변화 처리
  void _handleAuthStateChange(AuthChangeEvent event, Session? session) {
    switch (event) {
      case AuthChangeEvent.signedIn:
        debugPrint('사용자 로그인, 실시간 동기화 시작');
        _startRealtimeSyncAfterLogin();
        break;
        
      case AuthChangeEvent.signedOut:
        debugPrint('사용자 로그아웃, 실시간 동기화 중지');
        _stopRealtimeSyncAfterLogout();
        break;
        
      case AuthChangeEvent.tokenRefreshed:
        debugPrint('토큰 갱신됨');
        break;
        
      default:
        break;
    }
  }

  /// 로그인 후 실시간 동기화 시작
  Future<void> _startRealtimeSyncAfterLogin() async {
    try {
      // 데모 모드 확인
      final prefs = await SharedPreferences.getInstance();
      final isDemoMode = prefs.getBool('isDemoMode') ?? false;
      
      if (!isDemoMode) {
        await ref.read(realtimeSyncProvider.notifier).startRealtimeSync();
        
        // 로그인 후 전체 동기화 수행
        _performInitialSync();
      }
    } catch (e) {
      debugPrint('로그인 후 실시간 동기화 시작 실패: $e');
    }
  }

  /// 로그아웃 후 실시간 동기화 중지
  Future<void> _stopRealtimeSyncAfterLogout() async {
    try {
      await ref.read(realtimeSyncProvider.notifier).stopRealtimeSync();
    } catch (e) {
      debugPrint('로그아웃 후 실시간 동기화 중지 실패: $e');
    }
  }

  /// 초기 동기화 수행 (백그라운드)
  void _performInitialSync() {
    // 백그라운드에서 초기 동기화 수행
    Future.microtask(() async {
      try {
        final syncNotifier = ref.read(syncProvider.notifier);
        await syncNotifier.syncAll();
        debugPrint('초기 동기화 완료');
      } catch (e) {
        debugPrint('초기 동기화 실패: $e');
      }
    });
  }

  /// 수동으로 실시간 동기화 재시작
  Future<void> restartRealtimeSync() async {
    try {
      await ref.read(realtimeSyncProvider.notifier).stopRealtimeSync();
      await Future.delayed(const Duration(seconds: 1));
      await _checkAuthenticationAndStartRealtimeSync();
    } catch (e) {
      debugPrint('실시간 동기화 재시작 실패: $e');
    }
  }
}

/// 앱 생명주기 Provider
final appLifecycleProvider = StateNotifierProvider<AppLifecycleNotifier, bool>((ref) {
  return AppLifecycleNotifier(ref);
});

/// 앱 초기화 상태를 확인하는 Provider
final isAppInitializedProvider = Provider<bool>((ref) {
  return ref.watch(appLifecycleProvider);
});