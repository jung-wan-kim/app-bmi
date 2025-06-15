import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal.dart';

final goalProvider = StateNotifierProvider<GoalNotifier, Goal?>((ref) {
  return GoalNotifier();
});

class GoalNotifier extends StateNotifier<Goal?> {
  GoalNotifier() : super(null) {
    _loadGoal();
  }

  static const String _storageKey = 'current_goal';

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString != null) {
      state = Goal.fromJson(json.decode(jsonString));
    }
  }

  Future<void> _saveGoal() async {
    final prefs = await SharedPreferences.getInstance();
    if (state != null) {
      await prefs.setString(_storageKey, json.encode(state!.toJson()));
    } else {
      await prefs.remove(_storageKey);
    }
  }

  Future<void> setGoal({
    required double targetWeight,
    DateTime? targetDate,
  }) async {
    state = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      targetWeight: targetWeight,
      targetDate: targetDate,
      createdAt: DateTime.now(),
    );
    
    await _saveGoal();
  }

  Future<void> updateGoal({
    double? targetWeight,
    DateTime? targetDate,
  }) async {
    if (state == null) return;
    
    state = state!.copyWith(
      targetWeight: targetWeight ?? state!.targetWeight,
      targetDate: targetDate,
    );
    
    await _saveGoal();
  }

  Future<void> markAsAchieved() async {
    if (state == null) return;
    
    state = state!.copyWith(isAchieved: true);
    await _saveGoal();
  }

  Future<void> deleteGoal() async {
    state = null;
    await _saveGoal();
  }

  // 목표 달성률 계산
  double calculateProgress(double currentWeight, double startWeight) {
    if (state == null) return 0.0;
    
    final totalWeightToLose = startWeight - state!.targetWeight;
    if (totalWeightToLose <= 0) return 0.0;
    
    final weightLost = startWeight - currentWeight;
    final progress = (weightLost / totalWeightToLose * 100).clamp(0.0, 100.0);
    
    return progress;
  }

  // 예상 달성일 계산
  DateTime? calculateEstimatedDate(List<double> recentWeights) {
    if (state == null || recentWeights.length < 2) return null;
    
    // 최근 체중 변화율 계산 (주당 평균)
    final currentWeight = recentWeights.first;
    final weekAgoWeight = recentWeights.last;
    final weeklyChange = weekAgoWeight - currentWeight;
    
    if (weeklyChange <= 0) return null;
    
    final remainingWeight = currentWeight - state!.targetWeight;
    final weeksNeeded = remainingWeight / weeklyChange;
    
    return DateTime.now().add(Duration(days: (weeksNeeded * 7).round()));
  }
}