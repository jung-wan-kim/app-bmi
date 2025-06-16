import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/weight_record.dart';
import '../models/goal.dart';
import '../providers/notification_settings_provider.dart';

class RealtimeSyncService {
  static final RealtimeSyncService _instance = RealtimeSyncService._internal();
  factory RealtimeSyncService() => _instance;
  RealtimeSyncService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Realtime 채널들
  RealtimeChannel? _weightRecordsChannel;
  RealtimeChannel? _goalsChannel;
  RealtimeChannel? _notificationSettingsChannel;
  
  bool _isListening = false;
  String? _currentUserId;

  // 콜백 함수들
  Function(WeightRecord)? onWeightRecordInserted;
  Function(WeightRecord)? onWeightRecordUpdated;
  Function(String)? onWeightRecordDeleted;
  
  Function(Goal)? onGoalInserted;
  Function(Goal)? onGoalUpdated;
  Function(String)? onGoalDeleted;
  
  Function(NotificationSettings)? onNotificationSettingsUpdated;

  bool get isListening => _isListening;

  /// 실시간 동기화 시작
  Future<void> startListening({
    Function(WeightRecord)? onWeightRecordInserted,
    Function(WeightRecord)? onWeightRecordUpdated,
    Function(String)? onWeightRecordDeleted,
    Function(Goal)? onGoalInserted,
    Function(Goal)? onGoalUpdated,
    Function(String)? onGoalDeleted,
    Function(NotificationSettings)? onNotificationSettingsUpdated,
  }) async {
    if (_isListening) {
      debugPrint('이미 실시간 동기화가 활성화되어 있습니다');
      return;
    }

    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다');
    }

    _currentUserId = user.id;
    
    // 콜백 함수 설정
    this.onWeightRecordInserted = onWeightRecordInserted;
    this.onWeightRecordUpdated = onWeightRecordUpdated;
    this.onWeightRecordDeleted = onWeightRecordDeleted;
    this.onGoalInserted = onGoalInserted;
    this.onGoalUpdated = onGoalUpdated;
    this.onGoalDeleted = onGoalDeleted;
    this.onNotificationSettingsUpdated = onNotificationSettingsUpdated;

    try {
      // Weight Records 실시간 리스닝
      await _startWeightRecordsListening();
      
      // Goals 실시간 리스닝
      await _startGoalsListening();
      
      // Notification Settings 실시간 리스닝
      await _startNotificationSettingsListening();

      _isListening = true;
      debugPrint('실시간 동기화 시작됨 (사용자 ID: $_currentUserId)');
      
    } catch (e) {
      debugPrint('실시간 동기화 시작 실패: $e');
      await stopListening();
      rethrow;
    }
  }

  /// Weight Records 실시간 리스닝 시작
  Future<void> _startWeightRecordsListening() async {
    _weightRecordsChannel = _supabase
        .channel('weight_records_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'weight_records',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) => _handleWeightRecordInsert(payload),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'weight_records',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) => _handleWeightRecordUpdate(payload),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'weight_records',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) => _handleWeightRecordDelete(payload),
        );

    await _weightRecordsChannel!.subscribe();
  }

  /// Goals 실시간 리스닝 시작
  Future<void> _startGoalsListening() async {
    _goalsChannel = _supabase
        .channel('goals_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'goals',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) => _handleGoalInsert(payload),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'goals',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) => _handleGoalUpdate(payload),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'goals',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) => _handleGoalDelete(payload),
        );

    await _goalsChannel!.subscribe();
  }

  /// Notification Settings 실시간 리스닝 시작
  Future<void> _startNotificationSettingsListening() async {
    _notificationSettingsChannel = _supabase
        .channel('notification_settings_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notification_settings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) => _handleNotificationSettingsUpdate(payload),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notification_settings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) => _handleNotificationSettingsUpdate(payload),
        );

    await _notificationSettingsChannel!.subscribe();
  }

  /// Weight Record 삽입 처리
  void _handleWeightRecordInsert(PostgresChangePayload payload) {
    try {
      final data = payload.newRecord;
      final weightRecord = WeightRecord(
        id: data['id'].toString(),
        weight: data['weight'].toDouble(),
        bmi: data['bmi'].toDouble(),
        recordedAt: DateTime.parse(data['recorded_at']),
        notes: data['notes'],
      );
      
      _saveWeightRecordLocally(weightRecord);
      onWeightRecordInserted?.call(weightRecord);
      
      debugPrint('새 체중 기록 실시간 동기화: ${weightRecord.weight}kg');
    } catch (e) {
      debugPrint('체중 기록 삽입 처리 실패: $e');
    }
  }

  /// Weight Record 업데이트 처리
  void _handleWeightRecordUpdate(PostgresChangePayload payload) {
    try {
      final data = payload.newRecord;
      final weightRecord = WeightRecord(
        id: data['id'].toString(),
        weight: data['weight'].toDouble(),
        bmi: data['bmi'].toDouble(),
        recordedAt: DateTime.parse(data['recorded_at']),
        notes: data['notes'],
      );
      
      _updateWeightRecordLocally(weightRecord);
      onWeightRecordUpdated?.call(weightRecord);
      
      debugPrint('체중 기록 업데이트 실시간 동기화: ${weightRecord.weight}kg');
    } catch (e) {
      debugPrint('체중 기록 업데이트 처리 실패: $e');
    }
  }

  /// Weight Record 삭제 처리
  void _handleWeightRecordDelete(PostgresChangePayload payload) {
    try {
      final data = payload.oldRecord;
      final recordId = data['id'].toString();
      
      _deleteWeightRecordLocally(recordId);
      onWeightRecordDeleted?.call(recordId);
      
      debugPrint('체중 기록 삭제 실시간 동기화: $recordId');
    } catch (e) {
      debugPrint('체중 기록 삭제 처리 실패: $e');
    }
  }

  /// Goal 삽입 처리
  void _handleGoalInsert(PostgresChangePayload payload) {
    try {
      final data = payload.newRecord;
      final goal = Goal(
        id: data['id'].toString(),
        targetWeight: data['target_weight'].toDouble(),
        targetDate: data['target_date'] != null 
            ? DateTime.parse(data['target_date'])
            : null,
        isAchieved: data['is_achieved'] ?? false,
        achievedAt: data['achieved_at'] != null
            ? DateTime.parse(data['achieved_at'])
            : null,
        createdAt: DateTime.parse(data['created_at']),
      );
      
      _saveGoalLocally(goal);
      onGoalInserted?.call(goal);
      
      debugPrint('새 목표 실시간 동기화: ${goal.targetWeight}kg');
    } catch (e) {
      debugPrint('목표 삽입 처리 실패: $e');
    }
  }

  /// Goal 업데이트 처리
  void _handleGoalUpdate(PostgresChangePayload payload) {
    try {
      final data = payload.newRecord;
      final goal = Goal(
        id: data['id'].toString(),
        targetWeight: data['target_weight'].toDouble(),
        targetDate: data['target_date'] != null 
            ? DateTime.parse(data['target_date'])
            : null,
        isAchieved: data['is_achieved'] ?? false,
        achievedAt: data['achieved_at'] != null
            ? DateTime.parse(data['achieved_at'])
            : null,
        createdAt: DateTime.parse(data['created_at']),
      );
      
      _saveGoalLocally(goal);
      onGoalUpdated?.call(goal);
      
      debugPrint('목표 업데이트 실시간 동기화: ${goal.targetWeight}kg');
    } catch (e) {
      debugPrint('목표 업데이트 처리 실패: $e');
    }
  }

  /// Goal 삭제 처리
  void _handleGoalDelete(PostgresChangePayload payload) {
    try {
      final data = payload.oldRecord;
      final goalId = data['id'].toString();
      
      _deleteGoalLocally();
      onGoalDeleted?.call(goalId);
      
      debugPrint('목표 삭제 실시간 동기화: $goalId');
    } catch (e) {
      debugPrint('목표 삭제 처리 실패: $e');
    }
  }

  /// Notification Settings 업데이트 처리
  void _handleNotificationSettingsUpdate(PostgresChangePayload payload) {
    try {
      final data = payload.newRecord;
      
      // TIME 형식 파싱
      final timeString = data['reminder_time'] as String;
      final timeParts = timeString.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      final settings = NotificationSettings(
        isEnabled: data['is_enabled'] ?? false,
        reminderTime: NotificationTime(hour: hour, minute: minute),
        selectedDays: List<bool>.from(data['selected_days'] ?? [true, true, true, true, true, true, true]),
      );
      
      _saveNotificationSettingsLocally(settings);
      onNotificationSettingsUpdated?.call(settings);
      
      debugPrint('알림 설정 실시간 동기화');
    } catch (e) {
      debugPrint('알림 설정 업데이트 처리 실패: $e');
    }
  }

  /// 로컬에 체중 기록 저장
  Future<void> _saveWeightRecordLocally(WeightRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingRecordsJson = prefs.getStringList('weight_records') ?? [];
      
      final existingRecords = existingRecordsJson
          .map((json) => WeightRecord.fromJson(jsonDecode(json)))
          .toList();
      
      // 같은 ID의 기록이 있으면 제거
      existingRecords.removeWhere((r) => r.id == record.id);
      
      // 새 기록 추가
      existingRecords.add(record);
      
      // 날짜 순으로 정렬
      existingRecords.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      
      // 저장
      final updatedRecordsJson = existingRecords
          .map((r) => jsonEncode(r.toJson()))
          .toList();
      
      await prefs.setStringList('weight_records', updatedRecordsJson);
    } catch (e) {
      debugPrint('체중 기록 로컬 저장 실패: $e');
    }
  }

  /// 로컬 체중 기록 업데이트
  Future<void> _updateWeightRecordLocally(WeightRecord record) async {
    await _saveWeightRecordLocally(record); // 같은 로직 사용
  }

  /// 로컬 체중 기록 삭제
  Future<void> _deleteWeightRecordLocally(String recordId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingRecordsJson = prefs.getStringList('weight_records') ?? [];
      
      final existingRecords = existingRecordsJson
          .map((json) => WeightRecord.fromJson(jsonDecode(json)))
          .toList();
      
      // 해당 ID의 기록 제거
      existingRecords.removeWhere((r) => r.id == recordId);
      
      // 저장
      final updatedRecordsJson = existingRecords
          .map((r) => jsonEncode(r.toJson()))
          .toList();
      
      await prefs.setStringList('weight_records', updatedRecordsJson);
    } catch (e) {
      debugPrint('체중 기록 로컬 삭제 실패: $e');
    }
  }

  /// 로컬에 목표 저장
  Future<void> _saveGoalLocally(Goal goal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_goal', jsonEncode(goal.toJson()));
    } catch (e) {
      debugPrint('목표 로컬 저장 실패: $e');
    }
  }

  /// 로컬 목표 삭제
  Future<void> _deleteGoalLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_goal');
    } catch (e) {
      debugPrint('목표 로컬 삭제 실패: $e');
    }
  }

  /// 로컬에 알림 설정 저장
  Future<void> _saveNotificationSettingsLocally(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notification_settings', jsonEncode(settings.toJson()));
    } catch (e) {
      debugPrint('알림 설정 로컬 저장 실패: $e');
    }
  }

  /// 실시간 동기화 중지
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      // 모든 채널 구독 취소
      await _weightRecordsChannel?.unsubscribe();
      await _goalsChannel?.unsubscribe();
      await _notificationSettingsChannel?.unsubscribe();
      
      _weightRecordsChannel = null;
      _goalsChannel = null;
      _notificationSettingsChannel = null;
      
      _isListening = false;
      _currentUserId = null;
      
      // 콜백 함수 초기화
      onWeightRecordInserted = null;
      onWeightRecordUpdated = null;
      onWeightRecordDeleted = null;
      onGoalInserted = null;
      onGoalUpdated = null;
      onGoalDeleted = null;
      onNotificationSettingsUpdated = null;
      
      debugPrint('실시간 동기화 중지됨');
    } catch (e) {
      debugPrint('실시간 동기화 중지 실패: $e');
    }
  }

  /// 서비스 정리
  Future<void> dispose() async {
    await stopListening();
  }
}