import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/weight_record.dart';
import '../core/utils/bmi_calculator.dart';
import '../services/offline_queue_service.dart';
import '../services/connectivity_service.dart';

final weightRecordsProvider = StateNotifierProvider<WeightRecordsNotifier, List<WeightRecord>>((ref) {
  return WeightRecordsNotifier();
});

class WeightRecordsNotifier extends StateNotifier<List<WeightRecord>> {
  WeightRecordsNotifier() : super([]) {
    _loadRecords();
  }

  static const String _storageKey = 'weight_records';
  
  final SupabaseClient _supabase = Supabase.instance.client;
  final OfflineQueueService _offlineQueue = OfflineQueueService();
  final ConnectivityService _connectivity = ConnectivityService();

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList('weight_records');
    
    if (jsonStringList != null) {
      state = jsonStringList
          .map((jsonString) => WeightRecord.fromJson(json.decode(jsonString)))
          .toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    } else {
      // 이전 버전 호환성 유지
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        state = jsonList.map((json) => WeightRecord.fromJson(json)).toList()
          ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
        
        // 새 형식으로 마이그레이션
        final newJsonList = state.map((record) => json.encode(record.toJson())).toList();
        await prefs.setStringList('weight_records', newJsonList);
        await prefs.remove(_storageKey);
      }
    }
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.map((record) => json.encode(record.toJson())).toList();
    await prefs.setStringList('weight_records', jsonList);
  }

  Future<void> addRecord({
    required double weight,
    required double height,
    DateTime? recordedAt,
    String? notes,
  }) async {
    final now = DateTime.now();
    final bmi = BMICalculator.calculateBMI(weight, height);
    
    final newRecord = WeightRecord(
      id: now.millisecondsSinceEpoch.toString(),
      weight: weight,
      bmi: bmi,
      recordedAt: recordedAt ?? now,
      notes: notes,
    );

    // 로컬에 저장
    state = [newRecord, ...state]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    
    await _saveRecords();
    
    // 네트워크 연결 상태에 따라 처리
    final user = _supabase.auth.currentUser;
    if (user != null) {
      if (_connectivity.isConnected) {
        // 온라인: 즉시 Supabase에 저장
        try {
          await _supabase.from('weight_records').insert({
            'user_id': user.id,
            'weight': newRecord.weight,
            'bmi': newRecord.bmi,
            'recorded_at': newRecord.recordedAt.toIso8601String(),
            'notes': newRecord.notes,
          });
        } catch (e) {
          // 실패 시 오프라인 큐에 추가
          await _offlineQueue.addWeightRecord(newRecord);
        }
      } else {
        // 오프라인: 큐에 추가
        await _offlineQueue.addWeightRecord(newRecord);
      }
    }
  }

  Future<void> deleteRecord(String id) async {
    // 로컬에서 삭제
    state = state.where((record) => record.id != id).toList();
    await _saveRecords();
    
    // 네트워크 연결 상태에 따라 처리
    final user = _supabase.auth.currentUser;
    if (user != null) {
      if (_connectivity.isConnected) {
        // 온라인: 즉시 Supabase에서 삭제
        try {
          await _supabase
              .from('weight_records')
              .delete()
              .eq('id', id)
              .eq('user_id', user.id);
        } catch (e) {
          // 실패 시 오프라인 큐에 추가
          await _offlineQueue.deleteWeightRecord(id);
        }
      } else {
        // 오프라인: 큐에 추가
        await _offlineQueue.deleteWeightRecord(id);
      }
    }
  }

  Future<void> updateRecord(String id, {
    double? weight,
    double? height,
    DateTime? recordedAt,
    String? notes,
  }) async {
    final index = state.indexWhere((record) => record.id == id);
    if (index != -1) {
      final oldRecord = state[index];
      final newWeight = weight ?? oldRecord.weight;
      final newBmi = height != null 
        ? BMICalculator.calculateBMI(newWeight, height)
        : oldRecord.bmi;
      
      final updatedRecord = WeightRecord(
        id: oldRecord.id,
        weight: newWeight,
        bmi: newBmi,
        recordedAt: recordedAt ?? oldRecord.recordedAt,
        notes: notes ?? oldRecord.notes,
      );
      
      // 로컬에 저장
      state = [...state]
        ..[index] = updatedRecord
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      
      await _saveRecords();
      
      // 네트워크 연결 상태에 따라 처리
      final user = _supabase.auth.currentUser;
      if (user != null) {
        if (_connectivity.isConnected) {
          // 온라인: 즉시 Supabase에 업데이트
          try {
            await _supabase
                .from('weight_records')
                .update({
                  'weight': updatedRecord.weight,
                  'bmi': updatedRecord.bmi,
                  'recorded_at': updatedRecord.recordedAt.toIso8601String(),
                  'notes': updatedRecord.notes,
                })
                .eq('id', id)
                .eq('user_id', user.id);
          } catch (e) {
            // 실패 시 오프라인 큐에 추가
            await _offlineQueue.updateWeightRecord(updatedRecord);
          }
        } else {
          // 오프라인: 큐에 추가
          await _offlineQueue.updateWeightRecord(updatedRecord);
        }
      }
    }
  }

  WeightRecord? getLatestRecord() {
    if (state.isEmpty) return null;
    return state.first;
  }

  List<WeightRecord> getRecordsInRange(DateTime start, DateTime end) {
    return state.where((record) => 
      record.recordedAt.isAfter(start) && 
      record.recordedAt.isBefore(end)
    ).toList();
  }

  // 실시간 동기화를 위한 메서드들

  /// 실시간 동기화로부터 새 기록 추가 (중복 확인 포함)
  void addRecordFromRealtime(WeightRecord record) {
    // 이미 같은 ID의 기록이 있는지 확인
    final existingIndex = state.indexWhere((r) => r.id == record.id);
    
    if (existingIndex == -1) {
      // 새 기록 추가
      state = [record, ...state]
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    } else {
      // 기존 기록 업데이트
      state = [...state]
        ..[existingIndex] = record
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    }
    
    // SharedPreferences에는 자동으로 저장됨 (RealtimeSyncService에서 처리)
  }

  /// 실시간 동기화로부터 기록 업데이트
  void updateRecordFromRealtime(WeightRecord record) {
    final index = state.indexWhere((r) => r.id == record.id);
    
    if (index != -1) {
      state = [...state]
        ..[index] = record
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    } else {
      // 기록이 없으면 새로 추가
      addRecordFromRealtime(record);
    }
  }

  /// 실시간 동기화로부터 기록 삭제
  void deleteRecordFromRealtime(String recordId) {
    state = state.where((record) => record.id != recordId).toList();
    // SharedPreferences에는 자동으로 반영됨 (RealtimeSyncService에서 처리)
  }

  /// 전체 기록 목록을 새로고침 (실시간 동기화 초기화 시 사용)
  Future<void> refreshFromStorage() async {
    await _loadRecords();
  }
}