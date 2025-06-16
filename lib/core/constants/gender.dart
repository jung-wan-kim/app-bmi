enum Gender {
  male,
  female,
  other,
}

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return '남성';
      case Gender.female:
        return '여성';
      case Gender.other:
        return '기타';
    }
  }

  String get code {
    switch (this) {
      case Gender.male:
        return 'M';
      case Gender.female:
        return 'F';
      case Gender.other:
        return 'O';
    }
  }
}