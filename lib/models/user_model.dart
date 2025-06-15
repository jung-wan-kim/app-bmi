import 'package:flutter/foundation.dart';

/// 사용자 프로필 모델
@immutable
class UserModel {
  final String id;
  final String? email;
  final String? fullName;
  final String? gender;
  final DateTime? dateOfBirth;
  final double? height; // cm
  final double? targetWeight; // kg
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    this.email,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    this.height,
    this.targetWeight,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Supabase JSON에서 모델 생성
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      height: json['height']?.toDouble(),
      targetWeight: json['target_weight']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// 모델을 Supabase JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'height': height,
      'target_weight': targetWeight,
    };
  }

  /// 프로필 업데이트용 JSON (id 제외)
  Map<String, dynamic> toUpdateJson() {
    final json = toJson();
    json.remove('id');
    json.remove('email'); // email은 auth에서 관리
    return json;
  }

  /// 나이 계산
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// 프로필 완성도 확인
  bool get isProfileComplete {
    return fullName != null &&
        gender != null &&
        dateOfBirth != null &&
        height != null &&
        targetWeight != null;
  }

  /// copyWith 메서드
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? gender,
    DateTime? dateOfBirth,
    double? height,
    double? targetWeight,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      targetWeight: targetWeight ?? this.targetWeight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.gender == gender &&
        other.dateOfBirth == dateOfBirth &&
        other.height == height &&
        other.targetWeight == targetWeight;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        fullName.hashCode ^
        gender.hashCode ^
        dateOfBirth.hashCode ^
        height.hashCode ^
        targetWeight.hashCode;
  }
}