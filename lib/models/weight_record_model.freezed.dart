// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeightRecord {
  String get id;
  String get userId;
  double get weight;
  double get bmi;
  DateTime get recordedAt;
  String? get notes;
  DateTime get createdAt;

  /// Create a copy of WeightRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WeightRecordCopyWith<WeightRecord> get copyWith =>
      _$WeightRecordCopyWithImpl<WeightRecord>(
          this as WeightRecord, _$identity);

  /// Serializes this WeightRecord to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WeightRecord &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.bmi, bmi) || other.bmi == bmi) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, weight, bmi, recordedAt, notes, createdAt);

  @override
  String toString() {
    return 'WeightRecord(id: $id, userId: $userId, weight: $weight, bmi: $bmi, recordedAt: $recordedAt, notes: $notes, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $WeightRecordCopyWith<$Res> {
  factory $WeightRecordCopyWith(
          WeightRecord value, $Res Function(WeightRecord) _then) =
      _$WeightRecordCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      double weight,
      double bmi,
      DateTime recordedAt,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$WeightRecordCopyWithImpl<$Res> implements $WeightRecordCopyWith<$Res> {
  _$WeightRecordCopyWithImpl(this._self, this._then);

  final WeightRecord _self;
  final $Res Function(WeightRecord) _then;

  /// Create a copy of WeightRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? weight = null,
    Object? bmi = null,
    Object? recordedAt = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      bmi: null == bmi
          ? _self.bmi
          : bmi // ignore: cast_nullable_to_non_nullable
              as double,
      recordedAt: null == recordedAt
          ? _self.recordedAt
          : recordedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _WeightRecord implements WeightRecord {
  const _WeightRecord(
      {required this.id,
      required this.userId,
      required this.weight,
      required this.bmi,
      required this.recordedAt,
      this.notes,
      required this.createdAt});
  factory _WeightRecord.fromJson(Map<String, dynamic> json) =>
      _$WeightRecordFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final double weight;
  @override
  final double bmi;
  @override
  final DateTime recordedAt;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  /// Create a copy of WeightRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WeightRecordCopyWith<_WeightRecord> get copyWith =>
      __$WeightRecordCopyWithImpl<_WeightRecord>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WeightRecordToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WeightRecord &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.bmi, bmi) || other.bmi == bmi) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, weight, bmi, recordedAt, notes, createdAt);

  @override
  String toString() {
    return 'WeightRecord(id: $id, userId: $userId, weight: $weight, bmi: $bmi, recordedAt: $recordedAt, notes: $notes, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$WeightRecordCopyWith<$Res>
    implements $WeightRecordCopyWith<$Res> {
  factory _$WeightRecordCopyWith(
          _WeightRecord value, $Res Function(_WeightRecord) _then) =
      __$WeightRecordCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      double weight,
      double bmi,
      DateTime recordedAt,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$WeightRecordCopyWithImpl<$Res>
    implements _$WeightRecordCopyWith<$Res> {
  __$WeightRecordCopyWithImpl(this._self, this._then);

  final _WeightRecord _self;
  final $Res Function(_WeightRecord) _then;

  /// Create a copy of WeightRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? weight = null,
    Object? bmi = null,
    Object? recordedAt = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_WeightRecord(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      bmi: null == bmi
          ? _self.bmi
          : bmi // ignore: cast_nullable_to_non_nullable
              as double,
      recordedAt: null == recordedAt
          ? _self.recordedAt
          : recordedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
