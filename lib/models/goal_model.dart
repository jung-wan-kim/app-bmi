class Goal {
  final String id;
  final String userId;
  final double targetWeight;
  final DateTime? targetDate;
  final bool achieved;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    required this.id,
    required this.userId,
    required this.targetWeight,
    this.targetDate,
    this.achieved = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Goal copyWith({
    String? id,
    String? userId,
    double? targetWeight,
    DateTime? targetDate,
    bool? achieved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetWeight: targetWeight ?? this.targetWeight,
      targetDate: targetDate ?? this.targetDate,
      achieved: achieved ?? this.achieved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'targetWeight': targetWeight,
      'targetDate': targetDate?.toIso8601String(),
      'achieved': achieved,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      userId: json['userId'] as String,
      targetWeight: (json['targetWeight'] as num).toDouble(),
      targetDate: json['targetDate'] != null 
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      achieved: json['achieved'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Goal &&
        other.id == id &&
        other.userId == userId &&
        other.targetWeight == targetWeight &&
        other.targetDate == targetDate &&
        other.achieved == achieved &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      targetWeight,
      targetDate,
      achieved,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Goal(id: $id, userId: $userId, targetWeight: $targetWeight, targetDate: $targetDate, achieved: $achieved, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}