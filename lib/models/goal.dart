class Goal {
  final String id;
  final double targetWeight;
  final DateTime? targetDate;
  final DateTime createdAt;
  final bool isAchieved;

  Goal({
    required this.id,
    required this.targetWeight,
    this.targetDate,
    required this.createdAt,
    this.isAchieved = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'targetWeight': targetWeight,
    'targetDate': targetDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'isAchieved': isAchieved,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'],
    targetWeight: (json['targetWeight'] as num).toDouble(),
    targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
    createdAt: DateTime.parse(json['createdAt']),
    isAchieved: json['isAchieved'] ?? false,
  );

  Goal copyWith({
    String? id,
    double? targetWeight,
    DateTime? targetDate,
    DateTime? createdAt,
    bool? isAchieved,
  }) {
    return Goal(
      id: id ?? this.id,
      targetWeight: targetWeight ?? this.targetWeight,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      isAchieved: isAchieved ?? this.isAchieved,
    );
  }
}