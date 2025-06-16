import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/weight_record.dart';
import '../models/goal.dart';
import '../providers/notification_settings_provider.dart';
import 'connectivity_service.dart';

/// 오프라인 작업을 나타내는 클래스
class OfflineOperation {
  final String id;
  final String operation; // 'insert', 'update', 'delete'
  final String tableName;
  final String recordId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  bool isProcessed;
  int retryCount;

  OfflineOperation({
    required this.id,
    required this.operation,
    required this.tableName,
    required this.recordId,
    required this.data,
    required this.createdAt,
    this.isProcessed = false,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'operation': operation,
    'tableName': tableName,
    'recordId': recordId,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
    'isProcessed': isProcessed,
    'retryCount': retryCount,
  };

  factory OfflineOperation.fromJson(Map<String, dynamic> json) => OfflineOperation(
    id: json['id'],
    operation: json['operation'],
    tableName: json['tableName'],
    recordId: json['recordId'],
    data: json['data'],
    createdAt: DateTime.parse(json['createdAt']),
    isProcessed: json['isProcessed'] ?? false,
    retryCount: json['retryCount'] ?? 0,
  );
}

/// 오프라인 큐를 관리하는 서비스
class OfflineQueueService {
  static final OfflineQueueService _instance = OfflineQueueService._internal();
  factory OfflineQueueService() => _instance;
  OfflineQueueService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final ConnectivityService _connectivityService = ConnectivityService();
  
  static const String _queueKey = 'offline_queue';
  static const int _maxRetryCount = 3;
  
  List<OfflineOperation> _queue = [];
  bool _isProcessing = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    await _loadQueue();
    
    // 연결 상태 변화 감지
    _connectivityService.connectionChange.listen((isConnected) {
      if (isConnected && !_isProcessing) {
        debugPrint('네트워크 연결됨, 오프라인 큐 처리 시작');
        processQueue();
      }
    });
    
    debugPrint('OfflineQueueService 초기화 완료 (큐 크기: ${_queue.length})');
  }

  /// 큐 로드
  Future<void> _loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getStringList(_queueKey) ?? [];
    
    _queue = queueJson
        .map((json) => OfflineOperation.fromJson(jsonDecode(json)))
        .where((op) => !op.isProcessed)
        .toList();
  }

  /// 큐 저장
  Future<void> _saveQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = _queue
        .map((op) => jsonEncode(op.toJson()))
        .toList();
    
    await prefs.setStringList(_queueKey, queueJson);
  }

  /// 작업 추가
  Future<void> addOperation({
    required String operation,
    required String tableName,
    required String recordId,
    required Map<String, dynamic> data,
  }) async {
    final newOperation = OfflineOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      operation: operation,
      tableName: tableName,
      recordId: recordId,
      data: data,
      createdAt: DateTime.now(),
    );
    
    _queue.add(newOperation);
    await _saveQueue();
    
    debugPrint('오프라인 큐에 작업 추가: $operation $tableName ($recordId)');
    
    // 네트워크가 연결되어 있으면 즉시 처리
    if (_connectivityService.isConnected && !_isProcessing) {
      processQueue();
    }
  }

  /// 큐 처리
  Future<void> processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;
    
    _isProcessing = true;
    debugPrint('오프라인 큐 처리 시작 (작업 수: ${_queue.length})');
    
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('사용자가 로그인되어 있지 않아 큐 처리 중단');
      _isProcessing = false;
      return;
    }
    
    final processedOperations = <OfflineOperation>[];
    
    for (final operation in _queue.where((op) => !op.isProcessed && op.retryCount < _maxRetryCount)) {
      try {
        await _processOperation(operation, user.id);
        operation.isProcessed = true;
        processedOperations.add(operation);
        debugPrint('작업 처리 성공: ${operation.operation} ${operation.tableName}');
      } catch (e) {
        operation.retryCount++;
        debugPrint('작업 처리 실패 (재시도 ${operation.retryCount}/$_maxRetryCount): $e');
        
        if (operation.retryCount >= _maxRetryCount) {
          // 최대 재시도 횟수 초과 시 Supabase offline_queue 테이블에 저장
          await _saveToSupabase(operation, user.id, e.toString());
          processedOperations.add(operation);
        }
      }
    }
    
    // 처리된 작업 제거
    _queue.removeWhere((op) => processedOperations.contains(op));
    await _saveQueue();
    
    _isProcessing = false;
    debugPrint('오프라인 큐 처리 완료 (남은 작업: ${_queue.length})');
  }

  /// 개별 작업 처리
  Future<void> _processOperation(OfflineOperation operation, String userId) async {
    final data = Map<String, dynamic>.from(operation.data);
    data['user_id'] = userId;
    
    switch (operation.operation) {
      case 'insert':
        await _supabase
            .from(operation.tableName)
            .insert(data);
        break;
        
      case 'update':
        await _supabase
            .from(operation.tableName)
            .update(data)
            .eq('id', operation.recordId)
            .eq('user_id', userId);
        break;
        
      case 'delete':
        await _supabase
            .from(operation.tableName)
            .delete()
            .eq('id', operation.recordId)
            .eq('user_id', userId);
        break;
        
      default:
        throw Exception('알 수 없는 작업: ${operation.operation}');
    }
  }

  /// 실패한 작업을 Supabase에 저장
  Future<void> _saveToSupabase(OfflineOperation operation, String userId, String error) async {
    try {
      await _supabase.from('offline_queue').insert({
        'user_id': userId,
        'operation': operation.operation,
        'table_name': operation.tableName,
        'record_id': operation.recordId,
        'data': operation.data,
        'created_at': operation.createdAt.toIso8601String(),
        'error_message': error,
      });
      
      debugPrint('실패한 작업을 Supabase에 저장: ${operation.id}');
    } catch (e) {
      debugPrint('Supabase 저장 실패: $e');
    }
  }

  /// Weight Record 추가 (오프라인 지원)
  Future<void> addWeightRecord(WeightRecord record) async {
    if (!_connectivityService.isConnected) {
      await addOperation(
        operation: 'insert',
        tableName: 'weight_records',
        recordId: record.id,
        data: {
          'weight': record.weight,
          'bmi': record.bmi,
          'recorded_at': record.recordedAt.toIso8601String(),
          'notes': record.notes,
        },
      );
    }
  }

  /// Weight Record 업데이트 (오프라인 지원)
  Future<void> updateWeightRecord(WeightRecord record) async {
    if (!_connectivityService.isConnected) {
      await addOperation(
        operation: 'update',
        tableName: 'weight_records',
        recordId: record.id,
        data: {
          'weight': record.weight,
          'bmi': record.bmi,
          'recorded_at': record.recordedAt.toIso8601String(),
          'notes': record.notes,
        },
      );
    }
  }

  /// Weight Record 삭제 (오프라인 지원)
  Future<void> deleteWeightRecord(String recordId) async {
    if (!_connectivityService.isConnected) {
      await addOperation(
        operation: 'delete',
        tableName: 'weight_records',
        recordId: recordId,
        data: {},
      );
    }
  }

  /// Goal 추가/업데이트 (오프라인 지원)
  Future<void> upsertGoal(Goal goal) async {
    if (!_connectivityService.isConnected) {
      await addOperation(
        operation: 'insert',
        tableName: 'goals',
        recordId: goal.id,
        data: {
          'target_weight': goal.targetWeight,
          'target_date': goal.targetDate?.toIso8601String(),
          'is_achieved': goal.isAchieved,
          'achieved_at': goal.achievedAt?.toIso8601String(),
        },
      );
    }
  }

  /// Notification Settings 업데이트 (오프라인 지원)
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    if (!_connectivityService.isConnected) {
      await addOperation(
        operation: 'update',
        tableName: 'notification_settings',
        recordId: 'current', // 사용자당 하나의 설정만 있음
        data: {
          'is_enabled': settings.isEnabled,
          'reminder_time': '${settings.reminderTime.hour.toString().padLeft(2, '0')}:${settings.reminderTime.minute.toString().padLeft(2, '0')}:00',
          'selected_days': settings.selectedDays,
        },
      );
    }
  }

  /// 큐 크기 가져오기
  int get queueSize => _queue.length;

  /// 처리되지 않은 작업 수
  int get pendingOperationsCount => _queue.where((op) => !op.isProcessed).length;

  /// 큐 비우기 (디버그용)
  Future<void> clearQueue() async {
    _queue.clear();
    await _saveQueue();
    debugPrint('오프라인 큐 비움');
  }
}