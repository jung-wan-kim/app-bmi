import 'package:flutter/material.dart';

/// 앱 지역화 델리게이트
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static const List<Locale> supportedLocales = [
    Locale('ko', 'KR'),
    Locale('en', 'US'),
  ];
  
  // 공통
  String get appName => _localizedValues[locale.languageCode]!['appName']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  
  // 홈 화면
  String get greeting => _localizedValues[locale.languageCode]!['greeting']!;
  String get currentWeight => _localizedValues[locale.languageCode]!['currentWeight']!;
  String get targetWeight => _localizedValues[locale.languageCode]!['targetWeight']!;
  String get weightChange => _localizedValues[locale.languageCode]!['weightChange']!;
  String get goalProgress => _localizedValues[locale.languageCode]!['goalProgress']!;
  String get noGoalSet => _localizedValues[locale.languageCode]!['noGoalSet']!;
  String get setGoal => _localizedValues[locale.languageCode]!['setGoal']!;
  
  // 체중 입력
  String get recordWeight => _localizedValues[locale.languageCode]!['recordWeight']!;
  String get date => _localizedValues[locale.languageCode]!['date']!;
  String get time => _localizedValues[locale.languageCode]!['time']!;
  String get weight => _localizedValues[locale.languageCode]!['weight']!;
  String get notes => _localizedValues[locale.languageCode]!['notes']!;
  String get weightUnit => _localizedValues[locale.languageCode]!['weightUnit']!;
  String get heightUnit => _localizedValues[locale.languageCode]!['heightUnit']!;
  String get enterWeight => _localizedValues[locale.languageCode]!['enterWeight']!;
  String get invalidWeight => _localizedValues[locale.languageCode]!['invalidWeight']!;
  String get weightRecorded => _localizedValues[locale.languageCode]!['weightRecorded']!;
  
  // 통계
  String get statistics => _localizedValues[locale.languageCode]!['statistics']!;
  String get weekly => _localizedValues[locale.languageCode]!['weekly']!;
  String get monthly => _localizedValues[locale.languageCode]!['monthly']!;
  String get yearly => _localizedValues[locale.languageCode]!['yearly']!;
  String get averageWeight => _localizedValues[locale.languageCode]!['averageWeight']!;
  String get highestWeight => _localizedValues[locale.languageCode]!['highestWeight']!;
  String get lowestWeight => _localizedValues[locale.languageCode]!['lowestWeight']!;
  String get bmiChange => _localizedValues[locale.languageCode]!['bmiChange']!;
  String get noDataForChart => _localizedValues[locale.languageCode]!['noDataForChart']!;
  
  // BMI 카테고리
  String get underweight => _localizedValues[locale.languageCode]!['underweight']!;
  String get normal => _localizedValues[locale.languageCode]!['normal']!;
  String get overweight => _localizedValues[locale.languageCode]!['overweight']!;
  String get obese => _localizedValues[locale.languageCode]!['obese']!;
  
  // 설정
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get enableNotifications => _localizedValues[locale.languageCode]!['enableNotifications']!;
  String get notificationTime => _localizedValues[locale.languageCode]!['notificationTime']!;
  String get notificationDays => _localizedValues[locale.languageCode]!['notificationDays']!;
  String get units => _localizedValues[locale.languageCode]!['units']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get lightMode => _localizedValues[locale.languageCode]!['lightMode']!;
  String get darkMode => _localizedValues[locale.languageCode]!['darkMode']!;
  String get systemMode => _localizedValues[locale.languageCode]!['systemMode']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get korean => _localizedValues[locale.languageCode]!['korean']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get dataManagement => _localizedValues[locale.languageCode]!['dataManagement']!;
  String get backup => _localizedValues[locale.languageCode]!['backup']!;
  String get restore => _localizedValues[locale.languageCode]!['restore']!;
  String get clearData => _localizedValues[locale.languageCode]!['clearData']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;
  String get privacyPolicy => _localizedValues[locale.languageCode]!['privacyPolicy']!;
  String get termsOfService => _localizedValues[locale.languageCode]!['termsOfService']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  
  // 메시지
  String get confirmDelete => _localizedValues[locale.languageCode]!['confirmDelete']!;
  String get confirmClearData => _localizedValues[locale.languageCode]!['confirmClearData']!;
  String get dataCleared => _localizedValues[locale.languageCode]!['dataCleared']!;
  String get backupComplete => _localizedValues[locale.languageCode]!['backupComplete']!;
  String get restoreComplete => _localizedValues[locale.languageCode]!['restoreComplete']!;
  String get syncComplete => _localizedValues[locale.languageCode]!['syncComplete']!;
  String get syncFailed => _localizedValues[locale.languageCode]!['syncFailed']!;
  String get networkError => _localizedValues[locale.languageCode]!['networkError']!;
  String get errorOccurred => _localizedValues[locale.languageCode]!['errorOccurred']!;
  
  // 온보딩
  String get onboardingTitle1 => _localizedValues[locale.languageCode]!['onboardingTitle1']!;
  String get onboardingDesc1 => _localizedValues[locale.languageCode]!['onboardingDesc1']!;
  String get onboardingTitle2 => _localizedValues[locale.languageCode]!['onboardingTitle2']!;
  String get onboardingDesc2 => _localizedValues[locale.languageCode]!['onboardingDesc2']!;
  String get onboardingTitle3 => _localizedValues[locale.languageCode]!['onboardingTitle3']!;
  String get onboardingDesc3 => _localizedValues[locale.languageCode]!['onboardingDesc3']!;
  String get onboardingTitle4 => _localizedValues[locale.languageCode]!['onboardingTitle4']!;
  String get onboardingDesc4 => _localizedValues[locale.languageCode]!['onboardingDesc4']!;
  String get getStarted => _localizedValues[locale.languageCode]!['getStarted']!;
  String get skip => _localizedValues[locale.languageCode]!['skip']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'ko': {
      // 공통
      'appName': 'BMI 트래커',
      'cancel': '취소',
      'confirm': '확인',
      'save': '저장',
      'delete': '삭제',
      'edit': '수정',
      'settings': '설정',
      'close': '닫기',
      
      // 홈 화면
      'greeting': '안녕하세요, {}님! 👋',
      'currentWeight': '현재 체중',
      'targetWeight': '목표 체중',
      'weightChange': '체중 변화',
      'goalProgress': '목표 달성률',
      'noGoalSet': '목표가 설정되지 않았습니다',
      'setGoal': '목표 설정하기',
      
      // 체중 입력
      'recordWeight': '체중 기록',
      'date': '날짜',
      'time': '시간',
      'weight': '체중',
      'notes': '메모',
      'weightUnit': '체중 단위',
      'heightUnit': '키 단위',
      'enterWeight': '체중을 입력해주세요',
      'invalidWeight': '올바른 체중을 입력해주세요',
      'weightRecorded': '체중이 기록되었습니다',
      
      // 통계
      'statistics': '통계',
      'weekly': '주간',
      'monthly': '월간',
      'yearly': '연간',
      'averageWeight': '평균 체중',
      'highestWeight': '최고 체중',
      'lowestWeight': '최저 체중',
      'bmiChange': 'BMI 변화',
      'noDataForChart': '차트를 표시하려면\n체중을 기록해주세요',
      
      // BMI 카테고리
      'underweight': '저체중',
      'normal': '정상',
      'overweight': '과체중',
      'obese': '비만',
      
      // 설정
      'profile': '프로필',
      'notifications': '알림 설정',
      'enableNotifications': '알림 허용',
      'notificationTime': '알림 시간',
      'notificationDays': '알림 요일',
      'units': '단위 설정',
      'theme': '테마 모드',
      'lightMode': '라이트 모드',
      'darkMode': '다크 모드',
      'systemMode': '시스템 설정 따름',
      'language': '언어',
      'korean': '한국어',
      'english': 'English',
      'dataManagement': '데이터 관리',
      'backup': '데이터 백업',
      'restore': '데이터 복원',
      'clearData': '데이터 초기화',
      'about': '정보',
      'version': '버전',
      'privacyPolicy': '개인정보 처리방침',
      'termsOfService': '이용약관',
      'logout': '로그아웃',
      
      // 메시지
      'confirmDelete': '정말 삭제하시겠습니까?',
      'confirmClearData': '모든 데이터가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
      'dataCleared': '모든 데이터가 초기화되었습니다',
      'backupComplete': '백업이 완료되었습니다',
      'restoreComplete': '데이터가 복원되었습니다',
      'syncComplete': '동기화가 완료되었습니다',
      'syncFailed': '동기화 실패',
      'networkError': '네트워크 오류',
      'errorOccurred': '오류가 발생했습니다',
      
      // 온보딩
      'onboardingTitle1': '체중을 기록하세요',
      'onboardingDesc1': '매일 체중을 기록하고\n변화를 추적해보세요',
      'onboardingTitle2': 'BMI를 확인하세요',
      'onboardingDesc2': '실시간으로 계산되는 BMI로\n건강 상태를 파악하세요',
      'onboardingTitle3': '목표를 설정하세요',
      'onboardingDesc3': '목표 체중을 설정하고\n달성률을 확인하세요',
      'onboardingTitle4': '통계를 분석하세요',
      'onboardingDesc4': '차트와 그래프로\n체중 변화를 한눈에 확인하세요',
      'getStarted': '시작하기',
      'skip': '건너뛰기',
      'next': '다음',
    },
    'en': {
      // 공통
      'appName': 'BMI Tracker',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'settings': 'Settings',
      'close': 'Close',
      
      // 홈 화면
      'greeting': 'Hello, {}! 👋',
      'currentWeight': 'Current Weight',
      'targetWeight': 'Target Weight',
      'weightChange': 'Weight Change',
      'goalProgress': 'Goal Progress',
      'noGoalSet': 'No goal set',
      'setGoal': 'Set Goal',
      
      // 체중 입력
      'recordWeight': 'Record Weight',
      'date': 'Date',
      'time': 'Time',
      'weight': 'Weight',
      'notes': 'Notes',
      'weightUnit': 'Weight Unit',
      'heightUnit': 'Height Unit',
      'enterWeight': 'Please enter weight',
      'invalidWeight': 'Please enter valid weight',
      'weightRecorded': 'Weight recorded successfully',
      
      // 통계
      'statistics': 'Statistics',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'averageWeight': 'Average Weight',
      'highestWeight': 'Highest Weight',
      'lowestWeight': 'Lowest Weight',
      'bmiChange': 'BMI Change',
      'noDataForChart': 'Record weight to\ndisplay chart',
      
      // BMI 카테고리
      'underweight': 'Underweight',
      'normal': 'Normal',
      'overweight': 'Overweight',
      'obese': 'Obese',
      
      // 설정
      'profile': 'Profile',
      'notifications': 'Notifications',
      'enableNotifications': 'Enable Notifications',
      'notificationTime': 'Notification Time',
      'notificationDays': 'Notification Days',
      'units': 'Units',
      'theme': 'Theme Mode',
      'lightMode': 'Light Mode',
      'darkMode': 'Dark Mode',
      'systemMode': 'System Default',
      'language': 'Language',
      'korean': '한국어',
      'english': 'English',
      'dataManagement': 'Data Management',
      'backup': 'Backup Data',
      'restore': 'Restore Data',
      'clearData': 'Clear Data',
      'about': 'About',
      'version': 'Version',
      'privacyPolicy': 'Privacy Policy',
      'termsOfService': 'Terms of Service',
      'logout': 'Logout',
      
      // 메시지
      'confirmDelete': 'Are you sure you want to delete?',
      'confirmClearData': 'All data will be deleted.\nThis action cannot be undone.',
      'dataCleared': 'All data has been cleared',
      'backupComplete': 'Backup completed',
      'restoreComplete': 'Data restored',
      'syncComplete': 'Sync completed',
      'syncFailed': 'Sync failed',
      'networkError': 'Network error',
      'errorOccurred': 'An error occurred',
      
      // 온보딩
      'onboardingTitle1': 'Track Your Weight',
      'onboardingDesc1': 'Record your weight daily\nand track changes',
      'onboardingTitle2': 'Check Your BMI',
      'onboardingDesc2': 'Monitor your health with\nreal-time BMI calculations',
      'onboardingTitle3': 'Set Your Goals',
      'onboardingDesc3': 'Set target weight and\ntrack your progress',
      'onboardingTitle4': 'Analyze Statistics',
      'onboardingDesc4': 'View weight changes\nwith charts and graphs',
      'getStarted': 'Get Started',
      'skip': 'Skip',
      'next': 'Next',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['ko', 'en'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}