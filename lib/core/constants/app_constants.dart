/// 앱 전체에서 사용되는 상수 정의
class AppConstants {
  // 앱 정보
  static const String appName = 'BMI Tracker';
  static const String appVersion = '1.0.0';
  
  // 온보딩
  static const int onboardingPageCount = 4;
  static const Duration onboardingAnimDuration = Duration(milliseconds: 300);
  
  // BMI 범위
  static const double bmiUnderweight = 18.5;
  static const double bmiNormal = 24.9;
  static const double bmiOverweight = 29.9;
  
  // 입력 제한
  static const double minWeight = 20.0; // kg
  static const double maxWeight = 300.0; // kg
  static const double minHeight = 50.0; // cm
  static const double maxHeight = 250.0; // cm
  
  // 차트 설정
  static const int defaultChartDays = 7;
  static const int maxChartDays = 365;
  
  // 애니메이션
  static const Duration pageTransition = Duration(milliseconds: 250);
  static const Duration buttonAnimation = Duration(milliseconds: 100);
  
  // 로컬 스토리지 키
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyWeightUnit = 'weight_unit';
  static const String keyHeightUnit = 'height_unit';
}