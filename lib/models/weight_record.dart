class WeightRecord {
  final String id;
  final double weight;
  final double bmi;
  final DateTime recordedAt;
  final String? notes;

  WeightRecord({
    required this.id,
    required this.weight,
    required this.bmi,
    required this.recordedAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'weight': weight,
    'bmi': bmi,
    'recordedAt': recordedAt.toIso8601String(),
    'notes': notes,
  };

  factory WeightRecord.fromJson(Map<String, dynamic> json) => WeightRecord(
    id: json['id'],
    weight: (json['weight'] as num).toDouble(),
    bmi: (json['bmi'] as num).toDouble(),
    recordedAt: DateTime.parse(json['recordedAt']),
    notes: json['notes'],
  );
}