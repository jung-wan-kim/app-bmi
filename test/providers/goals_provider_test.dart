import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_bmi/models/goal.dart';

// Mock provider for testing
final mockGoalsProvider = StateNotifierProvider<MockGoalsNotifier, List<Goal>>((ref) {
  return MockGoalsNotifier();
});

class MockGoalsNotifier extends StateNotifier<List<Goal>> {
  MockGoalsNotifier() : super([]);
  int _idCounter = 0;

  Future<void> addGoal({
    required double targetWeight,
    DateTime? targetDate,
  }) async {
    final newGoal = Goal(
      id: 'goal-${_idCounter++}',
      targetWeight: targetWeight,
      targetDate: targetDate,
      createdAt: DateTime.now(),
    );

    state = [newGoal, ...state];
  }

  Future<void> deleteGoal(String id) async {
    state = state.where((goal) => goal.id != id).toList();
  }

  Future<void> updateGoal(String id, {
    double? targetWeight,
    DateTime? targetDate,
  }) async {
    final index = state.indexWhere((goal) => goal.id == id);
    if (index != -1) {
      final oldGoal = state[index];
      final updatedGoal = oldGoal.copyWith(
        targetWeight: targetWeight ?? oldGoal.targetWeight,
        targetDate: targetDate ?? oldGoal.targetDate,
      );
      
      state = [...state]..[index] = updatedGoal;
    }
  }

  Future<void> markAsAchieved(String id) async {
    final index = state.indexWhere((goal) => goal.id == id);
    if (index != -1) {
      final oldGoal = state[index];
      final achievedGoal = oldGoal.copyWith(
        isAchieved: true,
        achievedAt: DateTime.now(),
      );
      
      state = [...state]..[index] = achievedGoal;
    }
  }

  Goal? getActiveGoal() {
    try {
      return state.firstWhere((goal) => !goal.isAchieved);
    } catch (_) {
      return null;
    }
  }

  List<Goal> getAchievedGoals() {
    return state.where((goal) => goal.isAchieved).toList();
  }
}

void main() {
  group('MockGoalsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with empty goals', () {
      final goals = container.read(mockGoalsProvider);
      expect(goals, isEmpty);
    });

    group('addGoal', () {
      test('should add a goal', () async {
        final notifier = container.read(mockGoalsProvider.notifier);
        final targetDate = DateTime.now().add(Duration(days: 30));
        
        await notifier.addGoal(
          targetWeight: 65.0,
          targetDate: targetDate,
        );

        final goals = container.read(mockGoalsProvider);
        expect(goals.length, 1);
        expect(goals.first.targetWeight, 65.0);
        expect(goals.first.targetDate, targetDate);
        expect(goals.first.isAchieved, false);
      });

      test('should add multiple goals', () async {
        final notifier = container.read(mockGoalsProvider.notifier);
        
        await notifier.addGoal(targetWeight: 65.0);
        await notifier.addGoal(targetWeight: 60.0);
        await notifier.addGoal(targetWeight: 55.0);

        final goals = container.read(mockGoalsProvider);
        expect(goals.length, 3);
        expect(goals[0].targetWeight, 55.0); // Most recent first
        expect(goals[1].targetWeight, 60.0);
        expect(goals[2].targetWeight, 65.0);
      });
    });

    group('deleteGoal', () {
      test('should delete a goal by id', () async {
        final notifier = container.read(mockGoalsProvider.notifier);
        
        await notifier.addGoal(targetWeight: 65.0);
        final goalId = container.read(mockGoalsProvider).first.id;
        
        await notifier.deleteGoal(goalId);

        final goals = container.read(mockGoalsProvider);
        expect(goals, isEmpty);
      });

      test('should only delete specified goal', () async {
        final notifier = container.read(mockGoalsProvider.notifier);
        
        await notifier.addGoal(targetWeight: 65.0);
        await notifier.addGoal(targetWeight: 60.0);
        
        final goals = container.read(mockGoalsProvider);
        final firstGoalId = goals[1].id; // Older goal
        
        await notifier.deleteGoal(firstGoalId);

        final remainingGoals = container.read(mockGoalsProvider);
        expect(remainingGoals.length, 1);
        expect(remainingGoals.first.targetWeight, 60.0);
      });
    });

    group('updateGoal', () {
      test('should update goal properties', () async {
        final notifier = container.read(mockGoalsProvider.notifier);
        final originalDate = DateTime.now().add(Duration(days: 30));
        
        await notifier.addGoal(
          targetWeight: 65.0,
          targetDate: originalDate,
        );
        
        final goalId = container.read(mockGoalsProvider).first.id;
        final newDate = DateTime.now().add(Duration(days: 60));
        
        await notifier.updateGoal(
          goalId,
          targetWeight: 60.0,
          targetDate: newDate,
        );

        final goals = container.read(mockGoalsProvider);
        expect(goals.first.targetWeight, 60.0);
        expect(goals.first.targetDate, newDate);
      });

      test('should not update if goal not found', () async {
        final notifier = container.read(mockGoalsProvider.notifier);
        
        await notifier.addGoal(targetWeight: 65.0);
        await notifier.updateGoal('non-existent', targetWeight: 60.0);

        final goals = container.read(mockGoalsProvider);
        expect(goals.first.targetWeight, 65.0); // Unchanged
      });
    });

    group('markAsAchieved', () {
      test('should mark goal as achieved', () async {
        final notifier = container.read(mockGoalsProvider.notifier);
        
        await notifier.addGoal(targetWeight: 65.0);
        final goalId = container.read(mockGoalsProvider).first.id;
        
        await notifier.markAsAchieved(goalId);

        final goals = container.read(mockGoalsProvider);
        expect(goals.first.isAchieved, true);
        expect(goals.first.achievedAt, isNotNull);
      });

      test('should not affect other goals', () async {
        final notifier = container.read(mockGoalsProvider.notifier);
        
        await notifier.addGoal(targetWeight: 65.0);
        await notifier.addGoal(targetWeight: 60.0);
        
        final goals = container.read(mockGoalsProvider);
        final firstGoalId = goals[1].id;
        
        await notifier.markAsAchieved(firstGoalId);

        final updatedGoals = container.read(mockGoalsProvider);
        expect(updatedGoals[0].isAchieved, false);
        expect(updatedGoals[1].isAchieved, true);
      });
    });

    group('getActiveGoal', () {
      test('should return first unachieved goal', () async {
        final notifier = container.read(mockGoalsProvider.notifier);
        
        await notifier.addGoal(targetWeight: 65.0);
        await notifier.addGoal(targetWeight: 60.0);
        
        final activeGoal = notifier.getActiveGoal();
        expect(activeGoal?.targetWeight, 65.0); // First unachieved
      });

      test('should return null when all goals achieved', () async {
        final notifier = container.read(mockGoalsProvider.notifier);
        
        await notifier.addGoal(targetWeight: 65.0);
        final goalId = container.read(mockGoalsProvider).first.id;
        await notifier.markAsAchieved(goalId);

        final activeGoal = notifier.getActiveGoal();
        expect(activeGoal, isNull);
      });

      test('should return null when no goals', () {
        final notifier = container.read(mockGoalsProvider.notifier);
        final activeGoal = notifier.getActiveGoal();
        expect(activeGoal, isNull);
      });
    });

    group('getAchievedGoals', () {
      test('should return only achieved goals', () async {
        final notifier = container.read(mockGoalsProvider.notifier);
        
        await notifier.addGoal(targetWeight: 65.0);
        await notifier.addGoal(targetWeight: 60.0);
        await notifier.addGoal(targetWeight: 55.0);
        
        final goals = container.read(mockGoalsProvider);
        await notifier.markAsAchieved(goals[0].id);
        await notifier.markAsAchieved(goals[2].id);

        final achievedGoals = notifier.getAchievedGoals();
        expect(achievedGoals.length, 2);
        expect(achievedGoals.any((g) => g.targetWeight == 55.0), true);
        expect(achievedGoals.any((g) => g.targetWeight == 65.0), true);
        expect(achievedGoals.any((g) => g.targetWeight == 60.0), false);
      });

      test('should return empty list when no achieved goals', () async {
        final notifier = container.read(mockGoalsProvider.notifier);
        
        await notifier.addGoal(targetWeight: 65.0);
        await notifier.addGoal(targetWeight: 60.0);

        final achievedGoals = notifier.getAchievedGoals();
        expect(achievedGoals, isEmpty);
      });
    });
  });
}