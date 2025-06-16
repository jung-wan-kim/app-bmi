// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeightRecord _$WeightRecordFromJson(Map<String, dynamic> json) =>
    _WeightRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WeightRecordToJson(_WeightRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'weight': instance.weight,
      'bmi': instance.bmi,
      'recordedAt': instance.recordedAt.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
