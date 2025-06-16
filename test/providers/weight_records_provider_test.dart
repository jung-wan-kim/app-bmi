import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_bmi/models/weight_record.dart';

// Simple mock provider for testing
final mockWeightRecordsProvider = StateNotifierProvider<MockWeightRecordsNotifier, List<WeightRecord>>((ref) {
  return MockWeightRecordsNotifier();
});

class MockWeightRecordsNotifier extends StateNotifier<List<WeightRecord>> {
  MockWeightRecordsNotifier() : super([]);
  int _idCounter = 0;

  Future<void> addRecord({
    required double weight,
    required double height,
    DateTime? recordedAt,
    String? notes,
  }) async {
    final now = DateTime.now();
    final bmi = (weight / ((height / 100) * (height / 100)));
    
    final newRecord = WeightRecord(
      id: 'test-${_idCounter++}',
      weight: weight,
      bmi: bmi,
      recordedAt: recordedAt ?? now,
      notes: notes,
    );

    state = [newRecord, ...state]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  Future<void> deleteRecord(String id) async {
    state = state.where((record) => record.id != id).toList();
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
        ? (newWeight / ((height / 100) * (height / 100)))
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

  void addRecordFromRealtime(WeightRecord record) {
    final existingIndex = state.indexWhere((r) => r.id == record.id);
    
    if (existingIndex == -1) {
      state = [record, ...state]
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    } else {
      state = [...state]
        ..[existingIndex] = record
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    }
  }

  void updateRecordFromRealtime(WeightRecord record) {
    final index = state.indexWhere((r) => r.id == record.id);
    
    if (index != -1) {
      state = [...state]
        ..[index] = record
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    } else {
      addRecordFromRealtime(record);
    }
  }

  void deleteRecordFromRealtime(String recordId) {
    state = state.where((record) => record.id != recordId).toList();
  }
}

void main() {
  group('MockWeightRecordsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with empty records', () {
      final records = container.read(mockWeightRecordsProvider);
      expect(records, isEmpty);
    });

    group('addRecord', () {
      test('should add a weight record', () async {
        final notifier = container.read(mockWeightRecordsProvider.notifier);
        
        await notifier.addRecord(
          weight: 70.5,
          height: 170,
          recordedAt: DateTime.now(),
        );

        final records = container.read(mockWeightRecordsProvider);
        expect(records.length, 1);
        expect(records.first.weight, 70.5);
        expect(records.first.bmi, closeTo(24.39, 0.01));
      });

      test('should add multiple records and sort by date', () async {
        final notifier = container.read(mockWeightRecordsProvider.notifier);
        final now = DateTime.now();
        
        await notifier.addRecord(
          weight: 70,
          height: 170,
          recordedAt: now.subtract(Duration(days: 2)),
        );
        await notifier.addRecord(
          weight: 71,
          height: 170,
          recordedAt: now,
        );
        await notifier.addRecord(
          weight: 69,
          height: 170,
          recordedAt: now.subtract(Duration(days: 1)),
        );

        final records = container.read(mockWeightRecordsProvider);
        expect(records.length, 3);
        // Should be sorted by date descending (newest first)
        expect(records[0].weight, 71); // Most recent
        expect(records[1].weight, 69); // Yesterday
        expect(records[2].weight, 70); // Two days ago
      });
    });

    group('updateRecord', () {
      test('should update an existing record', () async {
        final notifier = container.read(mockWeightRecordsProvider.notifier);
        final now = DateTime.now();
        
        await notifier.addRecord(
          weight: 70,
          height: 170,
          recordedAt: now,
        );
        
        final records = container.read(mockWeightRecordsProvider);
        final recordId = records.first.id;
        
        await notifier.updateRecord(
          recordId,
          weight: 75,
          height: 170,
        );

        final updatedRecords = container.read(mockWeightRecordsProvider);
        expect(updatedRecords.length, 1);
        expect(updatedRecords.first.weight, 75);
        expect(updatedRecords.first.bmi, closeTo(25.95, 0.01));
        expect(updatedRecords.first.id, recordId);
      });

      test('should not update if id does not exist', () async {
        final notifier = container.read(mockWeightRecordsProvider.notifier);
        
        await notifier.addRecord(
          weight: 70,
          height: 170,
          recordedAt: DateTime.now(),
        );
        
        await notifier.updateRecord(
          'non-existent',
          weight: 75,
        );

        final records = container.read(mockWeightRecordsProvider);
        expect(records.length, 1);
        expect(records.first.weight, 70); // Should remain unchanged
      });
    });

    group('deleteRecord', () {
      test('should delete a record by id', () async {
        final notifier = container.read(mockWeightRecordsProvider.notifier);
        
        await notifier.addRecord(
          weight: 70,
          height: 170,
          recordedAt: DateTime.now(),
        );
        
        final recordId = container.read(mockWeightRecordsProvider).first.id;
        await notifier.deleteRecord(recordId);

        final records = container.read(mockWeightRecordsProvider);
        expect(records, isEmpty);
      });

      test('should not affect other records', () async {
        final notifier = container.read(mockWeightRecordsProvider.notifier);
        final now = DateTime.now();
        
        await notifier.addRecord(
          weight: 70,
          height: 170,
          recordedAt: now.subtract(Duration(seconds: 2)),
        );
        await notifier.addRecord(
          weight: 71,
          height: 170,
          recordedAt: now,
        );
        
        final records = container.read(mockWeightRecordsProvider);
        expect(records.length, 2);
        
        final firstId = records[1].id; // Older record
        final secondId = records[0].id; // Newer record
        
        await notifier.deleteRecord(firstId);

        final remainingRecords = container.read(mockWeightRecordsProvider);
        expect(remainingRecords.length, 1);
        expect(remainingRecords.first.id, secondId);
        expect(remainingRecords.first.weight, 71);
      });
    });

    group('getLatestRecord', () {
      test('should return the most recent record', () async {
        final notifier = container.read(mockWeightRecordsProvider.notifier);
        final now = DateTime.now();
        
        await notifier.addRecord(
          weight: 70,
          height: 170,
          recordedAt: now.subtract(Duration(days: 2)),
        );
        await notifier.addRecord(
          weight: 71,
          height: 170,
          recordedAt: now,
        );
        await notifier.addRecord(
          weight: 69,
          height: 170,
          recordedAt: now.subtract(Duration(days: 1)),
        );

        final latest = notifier.getLatestRecord();
        expect(latest?.weight, 71);
      });

      test('should return null for empty records', () {
        final notifier = container.read(mockWeightRecordsProvider.notifier);
        final latest = notifier.getLatestRecord();
        expect(latest, isNull);
      });
    });

    group('realtime sync methods', () {
      test('should add record from realtime sync', () async {
        final notifier = container.read(mockWeightRecordsProvider.notifier);
        final record = WeightRecord(
          id: 'realtime-id',
          weight: 75,
          bmi: 25.95,
          recordedAt: DateTime.now(),
          notes: 'From realtime',
        );
        
        notifier.addRecordFromRealtime(record);
        
        final records = container.read(mockWeightRecordsProvider);
        expect(records.length, 1);
        expect(records.first.id, 'realtime-id');
        expect(records.first.weight, 75);
      });
      
      test('should update existing record from realtime sync', () async {
        final notifier = container.read(mockWeightRecordsProvider.notifier);
        final record = WeightRecord(
          id: 'realtime-id',
          weight: 75,
          bmi: 25.95,
          recordedAt: DateTime.now(),
        );
        
        notifier.addRecordFromRealtime(record);
        
        final updatedRecord = WeightRecord(
          id: 'realtime-id',
          weight: 80,
          bmi: 27.68,
          recordedAt: record.recordedAt,
          notes: 'Updated',
        );
        
        notifier.updateRecordFromRealtime(updatedRecord);
        
        final records = container.read(mockWeightRecordsProvider);
        expect(records.length, 1);
        expect(records.first.weight, 80);
        expect(records.first.notes, 'Updated');
      });
      
      test('should delete record from realtime sync', () async {
        final notifier = container.read(mockWeightRecordsProvider.notifier);
        final record = WeightRecord(
          id: 'realtime-id',
          weight: 75,
          bmi: 25.95,
          recordedAt: DateTime.now(),
        );
        
        notifier.addRecordFromRealtime(record);
        notifier.deleteRecordFromRealtime('realtime-id');
        
        final records = container.read(mockWeightRecordsProvider);
        expect(records, isEmpty);
      });
    });

    group('getRecordsInRange', () {
      test('should return records within date range', () async {
        final notifier = container.read(mockWeightRecordsProvider.notifier);
        final now = DateTime.now();
        
        await notifier.addRecord(
          weight: 70,
          height: 170,
          recordedAt: now.subtract(Duration(days: 10)),
        );
        await notifier.addRecord(
          weight: 71,
          height: 170,
          recordedAt: now.subtract(Duration(days: 5)),
        );
        await notifier.addRecord(
          weight: 72,
          height: 170,
          recordedAt: now,
        );

        final start = now.subtract(Duration(days: 7));
        final end = now.add(Duration(days: 1)); // Add 1 day to include today
        final filtered = notifier.getRecordsInRange(start, end);

        expect(filtered.length, 2);
        expect(filtered.any((r) => r.weight == 71), true);
        expect(filtered.any((r) => r.weight == 72), true);
        expect(filtered.any((r) => r.weight == 70), false);
      });
    });
  });
}