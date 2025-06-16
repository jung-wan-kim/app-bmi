class WeightRecord {
  final String id;
  final String userId;
  final double weight;
  final double bmi;
  final DateTime recordedAt;
  final String? notes;
  final DateTime createdAt;

  const WeightRecord({
    required this.id,
    required this.userId,
    required this.weight,
    required this.bmi,
    required this.recordedAt,
    this.notes,
    required this.createdAt,
  });

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'weight': weight,
      'bmi': bmi,
      'recordedAt': recordedAt.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
        other.notes == notes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      weight,
      bmi,
      recordedAt,
      notes,
      createdAt,
    );
  }

  @override
  String toString() {
    return 'WeightRecord(id: $id, userId: $userId, weight: $weight, bmi: $bmi, recordedAt: $recordedAt, notes: $notes, createdAt: $createdAt)';
  }
}