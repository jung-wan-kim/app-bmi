import 'package:flutter_test/flutter_test.dart';
import 'package:app_bmi/models/weight_record.dart';

void main() {
  group('WeightRecord', () {
    final testDate = DateTime(2025, 1, 16, 10, 30);
    
    group('constructor', () {
      test('should create WeightRecord with all parameters', () {
        final record = WeightRecord(
          id: 'test-id',
          weight: 70.5,
          bmi: 24.39,
          recordedAt: testDate,
          notes: 'Test note',
        );

        expect(record.id, 'test-id');
        expect(record.weight, 70.5);
        expect(record.bmi, 24.39);
        expect(record.recordedAt, testDate);
        expect(record.notes, 'Test note');
      });

      test('should create WeightRecord without optional notes', () {
        final record = WeightRecord(
          id: 'test-id',
          weight: 70,
          bmi: 24.22,
          recordedAt: testDate,
        );

        expect(record.id, 'test-id');
        expect(record.weight, 70);
        expect(record.bmi, 24.22);
        expect(record.recordedAt, testDate);
        expect(record.notes, isNull);
      });
    });

    group('toJson', () {
      test('should convert WeightRecord to JSON', () {
        final record = WeightRecord(
          id: 'test-id',
          weight: 70.5,
          bmi: 24.39,
          recordedAt: testDate,
          notes: 'Test note',
        );

        final json = record.toJson();

        expect(json['id'], 'test-id');
        expect(json['weight'], 70.5);
        expect(json['bmi'], 24.39);
        expect(json['recordedAt'], testDate.toIso8601String());
        expect(json['notes'], 'Test note');
      });

      test('should include null notes in JSON', () {
        final record = WeightRecord(
          id: 'test-id',
          weight: 70.5,
          bmi: 24.39,
          recordedAt: testDate,
          notes: null,
        );

        final json = record.toJson();

        expect(json.containsKey('notes'), true);
        expect(json['notes'], isNull);
      });
    });

    group('fromJson', () {
      test('should create WeightRecord from JSON', () {
        final json = {
          'id': 'test-id',
          'weight': 70.5,
          'bmi': 24.39,
          'recordedAt': testDate.toIso8601String(),
          'notes': 'Test note',
        };

        final record = WeightRecord.fromJson(json);

        expect(record.id, 'test-id');
        expect(record.weight, 70.5);
        expect(record.bmi, 24.39);
        expect(record.recordedAt, testDate);
        expect(record.notes, 'Test note');
      });

      test('should handle missing optional fields', () {
        final json = {
          'id': 'test-id',
          'weight': 70.5,
          'bmi': 24.39,
          'recordedAt': testDate.toIso8601String(),
        };

        final record = WeightRecord.fromJson(json);

        expect(record.notes, isNull);
      });

      test('should handle weight as int', () {
        final json = {
          'id': 'test-id',
          'weight': 70,
          'bmi': 24.22,
          'recordedAt': testDate.toIso8601String(),
        };

        final record = WeightRecord.fromJson(json);

        expect(record.weight, 70.0);
      });
    });

    // copyWith 테스트 생략 (WeightRecord에 copyWith 메서드가 없음)

    // equality 테스트 생략 (WeightRecord에 equality override가 없음)

    // toString 테스트 생략 (WeightRecord에 toString override가 없음)
  });
}