import 'package:flutter/foundation.dart';

/// 체중 기록 모델
@immutable
class WeightRecord {
  final String id;
  final String userId;
  final double weight; // kg
  final double? bmi;
  final DateTime recordedAt;
  final String? notes;
  final DateTime createdAt;

  const WeightRecord({
    required this.id,
    required this.userId,
    required this.weight,
    this.bmi,
    required this.recordedAt,
    this.notes,
    required this.createdAt,
  });

  /// Supabase JSON에서 모델 생성
  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      weight: json['weight'].toDouble(),
      bmi: json['bmi']?.toDouble(),
      recordedAt: DateTime.parse(json['recorded_at']),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// 모델을 Supabase JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'weight': weight,
      'bmi': bmi,
      'recorded_at': recordedAt.toIso8601String(),
      'notes': notes,
    };
  }

  /// 새 기록 생성용 JSON (id 제외)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'weight': weight,
      'bmi': bmi,
      'recorded_at': recordedAt.toIso8601String(),
      'notes': notes,
    };
  }

  /// 날짜 포맷팅
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(recordedAt).inDays;
    
    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else if (difference < 7) {
      return '$difference일 전';
    } else {
      return '${recordedAt.month}월 ${recordedAt.day}일';
    }
  }

  /// 체중 변화량 계산 (이전 기록과 비교)
  double weightDifference(WeightRecord previousRecord) {
    return weight - previousRecord.weight;
  }

  /// copyWith 메서드
  WeightRecord copyWith({
    String? id,
    String? userId,
    double? weight,
    double? bmi,
    DateTime? recordedAt,
    String? notes,
    DateTime? createdAt,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      recordedAt: recordedAt ?? this.recordedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeightRecord &&
        other.id == id &&
        other.userId == userId &&
        other.weight == weight &&
        other.bmi == bmi &&
        other.recordedAt == recordedAt &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        weight.hashCode ^
        bmi.hashCode ^
        recordedAt.hashCode ^
        notes.hashCode;
  }
}