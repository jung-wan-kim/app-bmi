import 'package:freezed_annotation/freezed_annotation.dart';

part 'weight_record_model.freezed.dart';
part 'weight_record_model.g.dart';

@freezed
class WeightRecord with _$WeightRecord {
  const factory WeightRecord({
    required String id,
    required String userId,
    required double weight,
    required double bmi,
    required DateTime recordedAt,
    String? notes,
    required DateTime createdAt,
  }) = _WeightRecord;

  factory WeightRecord.fromJson(Map<String, dynamic> json) =>
      _$WeightRecordFromJson(json);
}