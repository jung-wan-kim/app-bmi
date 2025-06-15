import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weight_record.dart';
import '../core/utils/bmi_calculator.dart';

final weightRecordsProvider = StateNotifierProvider<WeightRecordsNotifier, List<WeightRecord>>((ref) {
  return WeightRecordsNotifier();
});

class WeightRecordsNotifier extends StateNotifier<List<WeightRecord>> {
  WeightRecordsNotifier() : super([]) {
    _loadRecords();
  }

  static const String _storageKey = 'weight_records';

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      state = jsonList.map((json) => WeightRecord.fromJson(json)).toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    }
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.map((record) => record.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
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

    state = [newRecord, ...state]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    
    await _saveRecords();
  }

  Future<void> deleteRecord(String id) async {
    state = state.where((record) => record.id != id).toList();
    await _saveRecords();
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
      
      state = [...state]
        ..[index] = updatedRecord
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      
      await _saveRecords();
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
}