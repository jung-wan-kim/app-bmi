import 'package:flutter_test/flutter_test.dart';
import 'package:app_bmi/models/goal.dart';

void main() {
  group('Goal', () {
    final testDate = DateTime(2025, 1, 16);
    final targetDate = DateTime(2025, 3, 16);
    final achievedDate = DateTime(2025, 2, 16);

    group('constructor', () {
      test('should create Goal with all parameters', () {
        final goal = Goal(
          id: 'test-id',
          targetWeight: 65.0,
          targetDate: targetDate,
          createdAt: testDate,
          isAchieved: true,
          achievedAt: achievedDate,
        );

        expect(goal.id, 'test-id');
        expect(goal.targetWeight, 65.0);
        expect(goal.targetDate, targetDate);
        expect(goal.createdAt, testDate);
        expect(goal.isAchieved, true);
        expect(goal.achievedAt, achievedDate);
      });

      test('should create Goal with required parameters only', () {
        final goal = Goal(
          id: 'test-id',
          targetWeight: 65.0,
          createdAt: testDate,
        );

        expect(goal.id, 'test-id');
        expect(goal.targetWeight, 65.0);
        expect(goal.targetDate, isNull);
        expect(goal.createdAt, testDate);
        expect(goal.isAchieved, false);
        expect(goal.achievedAt, isNull);
      });
    });

    group('toJson', () {
      test('should convert Goal to JSON with all fields', () {
        final goal = Goal(
          id: 'test-id',
          targetWeight: 65.0,
          targetDate: targetDate,
          createdAt: testDate,
          isAchieved: true,
          achievedAt: achievedDate,
        );

        final json = goal.toJson();

        expect(json['id'], 'test-id');
        expect(json['targetWeight'], 65.0);
        expect(json['targetDate'], targetDate.toIso8601String());
        expect(json['createdAt'], testDate.toIso8601String());
        expect(json['isAchieved'], true);
        expect(json['achievedAt'], achievedDate.toIso8601String());
      });

      test('should convert Goal to JSON with null optional fields', () {
        final goal = Goal(
          id: 'test-id',
          targetWeight: 65.0,
          createdAt: testDate,
        );

        final json = goal.toJson();

        expect(json['id'], 'test-id');
        expect(json['targetWeight'], 65.0);
        expect(json['targetDate'], isNull);
        expect(json['createdAt'], testDate.toIso8601String());
        expect(json['isAchieved'], false);
        expect(json['achievedAt'], isNull);
      });
    });

    group('fromJson', () {
      test('should create Goal from JSON with all fields', () {
        final json = {
          'id': 'test-id',
          'targetWeight': 65.0,
          'targetDate': targetDate.toIso8601String(),
          'createdAt': testDate.toIso8601String(),
          'isAchieved': true,
          'achievedAt': achievedDate.toIso8601String(),
        };

        final goal = Goal.fromJson(json);

        expect(goal.id, 'test-id');
        expect(goal.targetWeight, 65.0);
        expect(goal.targetDate, targetDate);
        expect(goal.createdAt, testDate);
        expect(goal.isAchieved, true);
        expect(goal.achievedAt, achievedDate);
      });

      test('should handle missing optional fields', () {
        final json = {
          'id': 'test-id',
          'targetWeight': 65.0,
          'createdAt': testDate.toIso8601String(),
        };

        final goal = Goal.fromJson(json);

        expect(goal.targetDate, isNull);
        expect(goal.isAchieved, false);
        expect(goal.achievedAt, isNull);
      });

      test('should handle targetWeight as int', () {
        final json = {
          'id': 'test-id',
          'targetWeight': 65,
          'createdAt': testDate.toIso8601String(),
        };

        final goal = Goal.fromJson(json);

        expect(goal.targetWeight, 65.0);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = Goal(
          id: 'test-id',
          targetWeight: 65.0,
          targetDate: targetDate,
          createdAt: testDate,
          isAchieved: false,
        );

        final newTargetDate = DateTime(2025, 4, 16);
        final copy = original.copyWith(
          targetWeight: 60.0,
          targetDate: newTargetDate,
          isAchieved: true,
          achievedAt: achievedDate,
        );

        expect(copy.id, original.id);
        expect(copy.targetWeight, 60.0);
        expect(copy.targetDate, newTargetDate);
        expect(copy.createdAt, original.createdAt);
        expect(copy.isAchieved, true);
        expect(copy.achievedAt, achievedDate);
      });

      test('should keep original values when not specified', () {
        final original = Goal(
          id: 'test-id',
          targetWeight: 65.0,
          targetDate: targetDate,
          createdAt: testDate,
          isAchieved: true,
          achievedAt: achievedDate,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.targetWeight, original.targetWeight);
        expect(copy.targetDate, original.targetDate);
        expect(copy.createdAt, original.createdAt);
        expect(copy.isAchieved, original.isAchieved);
        expect(copy.achievedAt, original.achievedAt);
      });
    });

    group('isExpired', () {
      test('should return true when target date has passed', () {
        final pastDate = DateTime.now().subtract(Duration(days: 1));
        final goal = Goal(
          id: 'test-id',
          targetWeight: 65.0,
          targetDate: pastDate,
          createdAt: testDate,
        );

        final now = DateTime.now();
        final isExpired = goal.targetDate != null && goal.targetDate!.isBefore(now);

        expect(isExpired, true);
      });

      test('should return false when target date is in future', () {
        final futureDate = DateTime.now().add(Duration(days: 1));
        final goal = Goal(
          id: 'test-id',
          targetWeight: 65.0,
          targetDate: futureDate,
          createdAt: testDate,
        );

        final now = DateTime.now();
        final isExpired = goal.targetDate != null && goal.targetDate!.isBefore(now);

        expect(isExpired, false);
      });

      test('should return false when target date is null', () {
        final goal = Goal(
          id: 'test-id',
          targetWeight: 65.0,
          createdAt: testDate,
        );

        final isExpired = goal.targetDate != null && goal.targetDate!.isBefore(DateTime.now());

        expect(isExpired, false);
      });
    });

    group('daysRemaining', () {
      test('should calculate days remaining correctly', () {
        final futureDate = DateTime.now().add(Duration(days: 30));
        final goal = Goal(
          id: 'test-id',
          targetWeight: 65.0,
          targetDate: DateTime(futureDate.year, futureDate.month, futureDate.day),
          createdAt: testDate,
        );

        if (goal.targetDate != null) {
          final daysRemaining = goal.targetDate!.difference(DateTime.now()).inDays;
          expect(daysRemaining, inInclusiveRange(29, 30));
        }
      });

      test('should return 0 for past dates', () {
        final pastDate = DateTime.now().subtract(Duration(days: 10));
        final goal = Goal(
          id: 'test-id',
          targetWeight: 65.0,
          targetDate: pastDate,
          createdAt: testDate,
        );

        if (goal.targetDate != null) {
          final daysRemaining = goal.targetDate!.difference(DateTime.now()).inDays;
          expect(daysRemaining, lessThan(0));
        }
      });

      test('should handle null target date', () {
        final goal = Goal(
          id: 'test-id',
          targetWeight: 65.0,
          createdAt: testDate,
        );

        expect(goal.targetDate, isNull);
      });
    });
  });
}