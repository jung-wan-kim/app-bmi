import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_model.freezed.dart';
part 'goal_model.g.dart';

@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String userId,
    required double targetWeight,
    DateTime? targetDate,
    @Default(false) bool achieved,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) =>
      _$GoalFromJson(json);
}