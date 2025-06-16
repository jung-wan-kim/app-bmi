import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/gender.dart';
import '../core/constants/bmi_constants.dart';
import '../core/utils/bmi_calculator.dart';
import '../providers/weight_records_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/app_lifecycle_provider.dart';
import '../providers/realtime_sync_provider.dart';
import '../providers/offline_support_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/weight_history_list.dart';
import '../widgets/character/bmi_character.dart';
import '../widgets/character/character_animator.dart';
import '../widgets/charts/weight_line_chart.dart';
import '../widgets/charts/bmi_gauge.dart';
import '../widgets/charts/progress_chart.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/input_field.dart';
import '../widgets/animated_widgets.dart';
import '../core/constants/app_animations.dart';
import '../core/constants/app_accessibility.dart';
import '../widgets/accessible_button.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/responsive_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  
  // 데모 데이터
  double currentWeight = 70.5;
  double height = 170;
  double startWeight = 75.0; // 시작 체중 추가
  String userName = '사용자';
  bool isDemoMode = false;
  Gender userGender = Gender.male;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // 앱 초기화 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appLifecycleProvider.notifier);
    });
  }
  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDemoMode = prefs.getBool('isDemoMode') ?? false;
      if (isDemoMode) {
        userName = prefs.getString('demoUserName') ?? '데모 사용자';
        height = prefs.getDouble('demoUserHeight') ?? 170.0;
        currentWeight = prefs.getDouble('demoUserWeight') ?? 65.0;
        startWeight = prefs.getDouble('demoStartWeight') ?? currentWeight;
        userGender = prefs.getString('userGender') == 'female' ? Gender.female : Gender.male;
      }
    });
    
    // 최신 체중 기록 가져오기
    final latestRecord = ref.read(weightRecordsProvider.notifier).getLatestRecord();
    if (latestRecord != null) {
      setState(() {
        currentWeight = latestRecord.weight;
      });
    }
    
    // 시작 체중 저장 (첫 번째 기록)
    final allRecords = ref.read(weightRecordsProvider);
    if (allRecords.isNotEmpty && !prefs.containsKey('demoStartWeight')) {
      final firstRecord = allRecords.last;
      startWeight = firstRecord.weight;
      await prefs.setDouble('demoStartWeight', startWeight);
    }
  }
  
  double get currentBMI => BMICalculator.calculateBMI(currentWeight, height);
  BMICategory get bmiCategory => BMICalculator.getBMICategory(currentBMI);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final deviceType = ResponsiveUtils.getDeviceType(context);
    final isLargeScreen = ResponsiveUtils.isLargeScreen(context);
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, deviceType) {
            if (isLargeScreen) {
              return _buildTabletLayout(context, isDarkMode);
            } else {
              return _buildMobileLayout(context, isDarkMode);
            }
          },
        ),
      ),
      bottomNavigationBar: deviceType == DeviceType.mobile ? _buildBottomNavigation() : null,
    );
  }
  
  Widget _buildMobileLayout(BuildContext context, bool isDarkMode) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 데모 모드 배너
              if (isDemoMode)
                FadeInAnimation(
                  child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '데모 모드로 실행 중입니다',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              
              // 네트워크 및 동기화 상태 (데모 모드가 아닐 때만 표시)
              if (!isDemoMode)
                Consumer(
                  builder: (context, ref, child) {
                    final isOnline = ref.watch(isOnlineProvider);
                    // final networkStatus = ref.watch(networkStatusProvider);
                    final offlineQueueSize = ref.watch(offlineQueueSizeProvider);
                    final isRealtimeConnected = ref.watch(isRealtimeConnectedProvider);
                    
                    return Column(
                      children: [
                        // 오프라인 상태 표시
                        if (!isOnline || offlineQueueSize > 0)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isOnline 
                                  ? AppColors.warning.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isOnline 
                                    ? AppColors.warning.withOpacity(0.3)
                                    : AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isOnline ? Icons.cloud_queue : Icons.cloud_off,
                                  color: isOnline ? AppColors.warning : AppColors.error,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isOnline 
                                        ? '대기 중인 동기화: $offlineQueueSize개'
                                        : '오프라인 모드 (대기: $offlineQueueSize개)',
                                    style: TextStyle(
                                      color: isOnline ? AppColors.warning : AppColors.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isOnline && offlineQueueSize > 0)
                                  TextButton(
                                    onPressed: () async {
                                      await ref.read(offlineSupportProvider.notifier).processQueueManually();
                                    },
                                    child: const Text('동기화', style: TextStyle(fontSize: 12)),
                                  ),
                              ],
                            ),
                          ),
                        
                        // 실시간 동기화 상태
                        if (isOnline && isRealtimeConnected)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.sync,
                                  color: AppColors.success,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '실시간 동기화 활성',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.greeting.replaceAll('{}', userName) ?? '안녕하세요, $userName님! 👋',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)?.appName ?? 'BMI 트래커',
                        style: TextStyle(
                          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.push('/home/settings'),
                    icon: const Icon(Icons.settings_outlined),
                    iconSize: 28,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 현재 상태 카드
              SlideInAnimation(
                delay: AppAnimations.listItemStaggerDelay,
                child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '현재 체중',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${currentWeight.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.monitor_weight_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildInfoChip(
                          label: 'BMI',
                          value: currentBMI.toStringAsFixed(1),
                          color: _getBMIColor(),
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          label: '상태',
                          value: BMICalculator.getCategoryName(bmiCategory),
                          color: _getBMIColor(),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
              const SizedBox(height: 24),
              
              // BMI 캐릭터
              ScaleInAnimation(
                duration: AppAnimations.cardAnimationDuration,
                delay: AppAnimations.listItemStaggerDelay * 2,
                child: Semantics(
                  label: AppAccessibility.getBMIAnnouncement(currentBMI, bmiCategory.displayName),
                  child: Center(
                    child: CharacterAnimator(
                      animationType: AnimationType.float,
                      child: BMICharacter(
                        bmi: currentBMI,
                        targetBmi: 22.0,
                        size: 200,
                        style: CharacterStyle.cute,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // BMI 게이지
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BMI 상태',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: BMIGauge(
                        bmi: currentBMI,
                        targetBmi: 22.0,
                        size: 180,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 목표 진행 상황
              Consumer(
                builder: (context, ref, child) {
                  final goal = ref.watch(goalProvider);
                  
                  if (goal == null) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 48,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '목표를 설정해보세요',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () => context.push('/home/goal-setting'),
                            child: const Text('목표 설정하기'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // final progress = ref.read(goalProvider.notifier).calculateProgress(currentWeight, startWeight);
                  // final weightDifference = currentWeight - goal.targetWeight;
                  
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '목표 진행 상황',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '목표 체중: ${goal.targetWeight.toStringAsFixed(1)}kg',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => context.push('/home/goal-setting'),
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: '목표 수정',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProgressChart(
                        currentWeight: currentWeight,
                        startWeight: startWeight,
                        targetWeight: goal.targetWeight,
                        targetDate: goal.targetDate,
                        size: 200,
                        showDetails: true,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // 최근 7일 차트
              Consumer(
                builder: (context, ref, child) {
                  final records = ref.watch(weightRecordsProvider);
                  final goal = ref.watch(goalProvider);
                  
                  return WeightLineChart(
                    records: records,
                    height: height,
                    targetWeight: goal?.targetWeight,
                    period: 'week',
                    showBmiLine: true,
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // 체중 기록 히스토리
              const WeightHistoryList(limit: 5),
              const SizedBox(height: 24),
              
              // 체중 기록 버튼
              CustomButton(
                text: '오늘 체중 기록하기',
                onPressed: () => context.push('/home/weight-input'),
                icon: Icons.add,
                width: double.infinity,
              ),
        ],
      ),
    );
  }
  
  Widget _buildTabletLayout(BuildContext context, bool isDarkMode) {
    return Row(
      children: [
        // 사이드 네비게이션
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
            switch (index) {
              case 0:
                break;
              case 1:
                context.push('/home/statistics');
                break;
              case 2:
                context.push('/home/settings');
                break;
            }
          },
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: Text('홈'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: Text('통계'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: Text('프로필'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // 메인 콘텐츠
        Expanded(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 데모 모드 배너
                if (isDemoMode)
                  FadeInAnimation(
                    child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '데모 모드로 실행 중입니다',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                
                // 네트워크 및 동기화 상태
                if (!isDemoMode)
                  Consumer(
                    builder: (context, ref, child) {
                      final isOnline = ref.watch(isOnlineProvider);
                      // final networkStatus = ref.watch(networkStatusProvider);
                      final offlineQueueSize = ref.watch(offlineQueueSizeProvider);
                      final isRealtimeConnected = ref.watch(isRealtimeConnectedProvider);
                      
                      return Column(
                        children: [
                          // 오프라인 상태 표시
                          if (!isOnline || offlineQueueSize > 0)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isOnline 
                                    ? AppColors.warning.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isOnline 
                                      ? AppColors.warning.withOpacity(0.3)
                                      : AppColors.error.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isOnline ? Icons.cloud_queue : Icons.cloud_off,
                                    color: isOnline ? AppColors.warning : AppColors.error,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isOnline 
                                          ? '대기 중인 동기화: $offlineQueueSize개'
                                          : '오프라인 모드 (대기: $offlineQueueSize개)',
                                      style: TextStyle(
                                        color: isOnline ? AppColors.warning : AppColors.error,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (isOnline && offlineQueueSize > 0)
                                    TextButton(
                                      onPressed: () async {
                                        await ref.read(offlineSupportProvider.notifier).processQueueManually();
                                      },
                                      child: const Text('동기화', style: TextStyle(fontSize: 12)),
                                    ),
                                ],
                              ),
                            ),
                          
                          // 실시간 동기화 상태
                          if (isOnline && isRealtimeConnected)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.success.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.sync,
                                    color: AppColors.success,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '실시간 동기화 활성',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                
                // 태블릿 레이아웃: 좌우 분할
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 왼쪽: 현재 상태와 BMI 캐릭터
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              // 헤더
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)?.greeting.replaceAll('{}', userName) ?? '안녕하세요, $userName님! 👋',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                                            context: context,
                                            baseSize: 24,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppLocalizations.of(context)?.appName ?? 'BMI 트래커',
                                        style: TextStyle(
                                          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                                            context: context,
                                            baseSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () => context.push('/home/settings'),
                                    icon: const Icon(Icons.settings_outlined),
                                    iconSize: 28,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // 현재 상태 카드
                              SlideInAnimation(
                                delay: AppAnimations.listItemStaggerDelay,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryLight,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '현재 체중',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${currentWeight.toStringAsFixed(1)} kg',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: const Icon(
                                              Icons.monitor_weight_outlined,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          _buildInfoChip(
                                            label: 'BMI',
                                            value: currentBMI.toStringAsFixed(1),
                                            color: _getBMIColor(),
                                          ),
                                          const SizedBox(width: 12),
                                          _buildInfoChip(
                                            label: '상태',
                                            value: BMICalculator.getCategoryName(bmiCategory),
                                            color: _getBMIColor(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // BMI 캐릭터
                              ScaleInAnimation(
                                duration: AppAnimations.cardAnimationDuration,
                                delay: AppAnimations.listItemStaggerDelay * 2,
                                child: Semantics(
                                  label: AppAccessibility.getBMIAnnouncement(currentBMI, bmiCategory.displayName),
                                  child: Center(
                                    child: CharacterAnimator(
                                      animationType: AnimationType.float,
                                      child: BMICharacter(
                                        bmi: currentBMI,
                                        targetBmi: 22.0,
                                        size: ResponsiveUtils.getResponsiveValue(
                                          context: context,
                                          mobile: 200,
                                          tablet: 280,
                                          desktop: 320,
                                        ),
                                        style: CharacterStyle.cute,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // BMI 게이지
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'BMI 상태',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: BMIGauge(
                                        bmi: currentBMI,
                                        targetBmi: 22.0,
                                        size: 240,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 32),
                        
                        // 오른쪽: 목표, 차트, 기록
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              // 목표 진행 상황
                              Consumer(
                                builder: (context, ref, child) {
                                  final goal = ref.watch(goalProvider);
                                  
                                  if (goal == null) {
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.flag_outlined,
                                            size: 48,
                                            color: AppColors.textSecondary.withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            '목표를 설정해보세요',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          OutlinedButton(
                                            onPressed: () => context.push('/home/goal-setting'),
                                            child: const Text('목표 설정하기'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  
                                  final progress = ref.read(goalProvider.notifier).calculateProgress(currentWeight, startWeight);
                                  final weightDifference = currentWeight - goal.targetWeight;
                                  
                                  return Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  '목표 진행 상황',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '목표 체중: ${goal.targetWeight.toStringAsFixed(1)}kg',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              onPressed: () => context.push('/home/goal-setting'),
                                              icon: const Icon(Icons.edit_outlined),
                                              tooltip: '목표 수정',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ProgressChart(
                                        currentWeight: currentWeight,
                                        startWeight: startWeight,
                                        targetWeight: goal.targetWeight,
                                        targetDate: goal.targetDate,
                                        size: 280,
                                        showDetails: true,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              
                              // 최근 7일 차트
                              Consumer(
                                builder: (context, ref, child) {
                                  final records = ref.watch(weightRecordsProvider);
                                  final goal = ref.watch(goalProvider);
                                  
                                  return WeightLineChart(
                                    records: records,
                                    height: height,
                                    targetWeight: goal?.targetWeight,
                                    period: 'week',
                                    showBmiLine: true,
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              
                              // 체중 기록 히스토리
                              const WeightHistoryList(limit: 5),
                              const SizedBox(height: 24),
                              
                              // 체중 기록 버튼
                              CustomButton(
                                text: '오늘 체중 기록하기',
                                onPressed: () => context.push('/home/weight-input'),
                                icon: Icons.add,
                                width: double.infinity,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        switch (index) {
          case 0:
            break; // 홈
          case 1:
            context.push('/home/statistics');
            break;
          case 2:
            context.push('/home/settings');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: '통계',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '프로필',
        ),
      ],
    );
  }
  
  Widget _buildInfoChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getBMIColor() {
    switch (bmiCategory) {
      case BMICategory.underweight:
        return AppColors.bmiUnderweight;
      case BMICategory.normal:
        return AppColors.bmiNormal;
      case BMICategory.overweight:
        return AppColors.bmiOverweight;
      case BMICategory.obese:
        return AppColors.bmiObese;
    }
  }
  
  Widget _buildChart() {
    final records = ref.watch(weightRecordsProvider);
    
    // 최근 7일 데이터 가져오기
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    final recentRecords = records.where((record) => 
      record.recordedAt.isAfter(sevenDaysAgo.subtract(const Duration(days: 1)))
    ).toList();
    
    // 날짜별로 그룹화
    final Map<int, double> weightByDay = {};
    for (var record in recentRecords) {
      final dayDiff = now.difference(record.recordedAt).inDays;
      final dayIndex = 6 - dayDiff;
      if (dayIndex >= 0 && dayIndex <= 6) {
        // 같은 날 여러 기록이 있으면 최신 것만 사용
        if (!weightByDay.containsKey(dayIndex) || dayIndex == 6) {
          weightByDay[dayIndex] = record.weight;
        }
      }
    }
    
    // FlSpot 리스트 생성
    final spots = <FlSpot>[];
    for (int i = 0; i <= 6; i++) {
      if (weightByDay.containsKey(i)) {
        spots.add(FlSpot(i.toDouble(), weightByDay[i]!));
      }
    }
    
    if (spots.isEmpty) {
      return Center(
        child: Text(
          '차트를 표시하려면\n체중을 기록해주세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }
    
    // min/max 계산
    final weights = spots.map((e) => e.y).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final padding = (maxWeight - minWeight) * 0.1;
    final minY = minWeight - padding - 0.5;
    final maxY = maxWeight + padding + 0.5;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.5,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final days = ['월', '화', '수', '목', '금', '토', '일'];
                return Text(
                  days[value.toInt()],
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '방금';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else {
      return DateFormat('MM/dd HH:mm').format(dateTime);
    }
  }
}