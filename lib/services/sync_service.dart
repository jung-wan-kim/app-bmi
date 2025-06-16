import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/weight_record.dart';
import '../models/goal.dart';
import '../providers/notification_settings_provider.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isInitialized = false;
  bool _isSyncing = false;

  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;

  /// 동기화 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // 사용자 인증 상태 확인
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다');
    }

    _isInitialized = true;
    debugPrint('SyncService 초기화 완료');
  }

  /// 전체 데이터 동기화 (다운로드 + 업로드)
  Future<SyncResult> syncAll() async {
    if (!_isInitialized) await initialize();
    if (_isSyncing) return SyncResult.alreadySyncing();

    _isSyncing = true;
    final result = SyncResult();

    try {
      // 1. 서버에서 데이터 다운로드
      await _downloadFromServer(result);
      
      // 2. 로컬 데이터를 서버로 업로드
      await _uploadToServer(result);
      
      // 3. 동기화 상태 업데이트
      await _updateSyncStatus('completed', null);
      
      result.success = true;
      debugPrint('전체 동기화 완료: ${result.toString()}');
      
    } catch (e) {
      result.success = false;
      result.error = e.toString();
      await _updateSyncStatus('failed', e.toString());
      debugPrint('동기화 실패: $e');
    } finally {
      _isSyncing = false;
    }

    return result;
  }

  /// 서버에서 데이터 다운로드
  Future<void> _downloadFromServer(SyncResult result) async {
    final user = _supabase.auth.currentUser!;
    
    try {
      // Weight records 다운로드
      final weightRecordsResponse = await _supabase
          .from('weight_records')
          .select()
          .eq('user_id', user.id)
          .order('recorded_at', ascending: false);

      if (weightRecordsResponse.isNotEmpty) {
        await _saveWeightRecordsLocally(weightRecordsResponse);
        result.downloadedWeightRecords = weightRecordsResponse.length;
      }

      // Goals 다운로드
      final goalsResponse = await _supabase
          .from('goals')
          .select()
          .eq('user_id', user.id)
          .eq('is_achieved', false)
          .order('created_at', ascending: false)
          .limit(1);

      if (goalsResponse.isNotEmpty) {
        await _saveGoalLocally(goalsResponse.first);
        result.downloadedGoals = 1;
      }

      // Notification settings 다운로드
      final notificationResponse = await _supabase
          .from('notification_settings')
          .select()
          .eq('user_id', user.id)
          .limit(1);

      if (notificationResponse.isNotEmpty) {
        await _saveNotificationSettingsLocally(notificationResponse.first);
        result.downloadedNotificationSettings = 1;
      }

    } catch (e) {
      debugPrint('서버에서 다운로드 실패: $e');
      rethrow;
    }
  }

  /// 로컬 데이터를 서버로 업로드
  Future<void> _uploadToServer(SyncResult result) async {
    final user = _supabase.auth.currentUser!;
    
    try {
      // Weight records 업로드
      final localWeightRecords = await _getLocalWeightRecords();
      if (localWeightRecords.isNotEmpty) {
        for (final record in localWeightRecords) {
          final data = {
            'user_id': user.id,
            'weight': record.weight,
            'bmi': record.bmi,
            'recorded_at': record.recordedAt.toIso8601String(),
            'notes': record.notes,
          };

          // 이미 존재하는지 확인
          final existing = await _supabase
              .from('weight_records')
              .select('id')
              .eq('user_id', user.id)
              .eq('recorded_at', record.recordedAt.toIso8601String())
              .limit(1);

          if (existing.isEmpty) {
            await _supabase.from('weight_records').insert(data);
            result.uploadedWeightRecords++;
          }
        }
      }

      // Goal 업로드
      final localGoal = await _getLocalGoal();
      if (localGoal != null) {
        final goalData = {
          'user_id': user.id,
          'target_weight': localGoal.targetWeight,
          'target_date': localGoal.targetDate?.toIso8601String(),
          'is_achieved': localGoal.isAchieved,
          'achieved_at': localGoal.achievedAt?.toIso8601String(),
        };

        // 기존 미달성 목표가 있는지 확인
        final existingGoals = await _supabase
            .from('goals')
            .select('id')
            .eq('user_id', user.id)
            .eq('is_achieved', false);

        if (existingGoals.isEmpty) {
          await _supabase.from('goals').insert(goalData);
          result.uploadedGoals++;
        } else {
          // 기존 목표 업데이트
          await _supabase
              .from('goals')
              .update(goalData)
              .eq('user_id', user.id)
              .eq('is_achieved', false);
          result.uploadedGoals++;
        }
      }

      // Notification settings 업로드
      final localNotificationSettings = await _getLocalNotificationSettings();
      if (localNotificationSettings != null) {
        final notificationData = {
          'user_id': user.id,
          'is_enabled': localNotificationSettings.isEnabled,
          'reminder_time': '${localNotificationSettings.reminderTime.hour.toString().padLeft(2, '0')}:${localNotificationSettings.reminderTime.minute.toString().padLeft(2, '0')}:00',
          'selected_days': localNotificationSettings.selectedDays,
        };

        // 기존 설정이 있는지 확인
        final existingSettings = await _supabase
            .from('notification_settings')
            .select('id')
            .eq('user_id', user.id)
            .limit(1);

        if (existingSettings.isEmpty) {
          await _supabase.from('notification_settings').insert(notificationData);
          result.uploadedNotificationSettings++;
        } else {
          await _supabase
              .from('notification_settings')
              .update(notificationData)
              .eq('user_id', user.id);
          result.uploadedNotificationSettings++;
        }
      }

    } catch (e) {
      debugPrint('서버로 업로드 실패: $e');
      rethrow;
    }
  }

  /// 로컬 SharedPreferences에서 체중 기록 가져오기
  Future<List<WeightRecord>> _getLocalWeightRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getStringList('weight_records') ?? [];
    
    return recordsJson
        .map((json) => WeightRecord.fromJson(jsonDecode(json)))
        .toList();
  }

  /// 로컬 SharedPreferences에서 목표 가져오기
  Future<Goal?> _getLocalGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final goalJson = prefs.getString('current_goal');
    
    if (goalJson != null) {
      return Goal.fromJson(jsonDecode(goalJson));
    }
    return null;
  }

  /// 로컬 SharedPreferences에서 알림 설정 가져오기
  Future<NotificationSettings?> _getLocalNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('notification_settings');
    
    if (settingsJson != null) {
      return NotificationSettings.fromJson(jsonDecode(settingsJson));
    }
    return null;
  }

  /// 체중 기록을 로컬에 저장
  Future<void> _saveWeightRecordsLocally(List<dynamic> serverRecords) async {
    final prefs = await SharedPreferences.getInstance();
    final localRecords = <WeightRecord>[];
    
    for (final record in serverRecords) {
      final weightRecord = WeightRecord(
        id: record['id'].toString(),
        weight: record['weight'].toDouble(),
        bmi: record['bmi'].toDouble(),
        recordedAt: DateTime.parse(record['recorded_at']),
        notes: record['notes'],
      );
      localRecords.add(weightRecord);
    }
    
    // SharedPreferences에 저장
    final recordsJson = localRecords
        .map((record) => jsonEncode(record.toJson()))
        .toList();
    
    await prefs.setStringList('weight_records', recordsJson);
  }

  /// 목표를 로컬에 저장
  Future<void> _saveGoalLocally(Map<String, dynamic> serverGoal) async {
    final prefs = await SharedPreferences.getInstance();
    final goal = Goal(
      id: serverGoal['id'].toString(),
      targetWeight: serverGoal['target_weight'].toDouble(),
      targetDate: serverGoal['target_date'] != null 
          ? DateTime.parse(serverGoal['target_date'])
          : null,
      isAchieved: serverGoal['is_achieved'] ?? false,
      achievedAt: serverGoal['achieved_at'] != null
          ? DateTime.parse(serverGoal['achieved_at'])
          : null,
    );
    
    await prefs.setString('current_goal', jsonEncode(goal.toJson()));
  }

  /// 알림 설정을 로컬에 저장
  Future<void> _saveNotificationSettingsLocally(Map<String, dynamic> serverSettings) async {
    final prefs = await SharedPreferences.getInstance();
    
    // TIME 형식 파싱 (HH:MM:SS)
    final timeString = serverSettings['reminder_time'] as String;
    final timeParts = timeString.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    final settings = NotificationSettings(
      isEnabled: serverSettings['is_enabled'] ?? false,
      reminderTime: NotificationTime(hour: hour, minute: minute),
      selectedDays: List<bool>.from(serverSettings['selected_days'] ?? [true, true, true, true, true, true, true]),
    );
    
    await prefs.setString('notification_settings', jsonEncode(settings.toJson()));
  }

  /// 동기화 상태 업데이트
  Future<void> _updateSyncStatus(String status, String? errorMessage) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = {
        'user_id': user.id,
        'table_name': 'all_tables',
        'last_sync_at': DateTime.now().toIso8601String(),
        'sync_status': status,
        'error_message': errorMessage,
      };

      // 기존 상태가 있는지 확인
      final existing = await _supabase
          .from('sync_status')
          .select('id')
          .eq('user_id', user.id)
          .eq('table_name', 'all_tables')
          .limit(1);

      if (existing.isEmpty) {
        await _supabase.from('sync_status').insert(data);
      } else {
        await _supabase
            .from('sync_status')
            .update(data)
            .eq('user_id', user.id)
            .eq('table_name', 'all_tables');
      }
    } catch (e) {
      debugPrint('동기화 상태 업데이트 실패: $e');
    }
  }

  /// 마지막 동기화 시간 가져오기
  Future<DateTime?> getLastSyncTime() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('sync_status')
          .select('last_sync_at')
          .eq('user_id', user.id)
          .eq('table_name', 'all_tables')
          .limit(1);

      if (response.isNotEmpty) {
        return DateTime.parse(response.first['last_sync_at']);
      }
    } catch (e) {
      debugPrint('마지막 동기화 시간 조회 실패: $e');
    }
    
    return null;
  }
}

/// 동기화 결과를 담는 클래스
class SyncResult {
  bool success = false;
  String? error;
  int downloadedWeightRecords = 0;
  int downloadedGoals = 0;
  int downloadedNotificationSettings = 0;
  int uploadedWeightRecords = 0;
  int uploadedGoals = 0;
  int uploadedNotificationSettings = 0;

  SyncResult();
  
  SyncResult.alreadySyncing() {
    success = false;
    error = '이미 동기화가 진행 중입니다';
  }

  @override
  String toString() {
    if (!success) {
      return 'SyncResult(실패: $error)';
    }
    
    return 'SyncResult(성공 - 다운로드: 체중기록 $downloadedWeightRecords개, 목표 $downloadedGoals개, 알림설정 $downloadedNotificationSettings개 | 업로드: 체중기록 $uploadedWeightRecords개, 목표 $uploadedGoals개, 알림설정 $uploadedNotificationSettings개)';
  }
}