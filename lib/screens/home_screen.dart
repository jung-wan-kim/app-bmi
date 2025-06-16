import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/bmi_calculator.dart';
import '../providers/weight_records_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/app_lifecycle_provider.dart';
import '../providers/realtime_sync_provider.dart';
import '../providers/offline_support_provider.dart';
import '../widgets/weight_history_list.dart';
import '../widgets/bmi_character.dart';
import '../widgets/bmi_character_painter.dart';
import '../widgets/advanced_bmi_character.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 데모 모드 배너
              if (isDemoMode)
                Container(
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
              
              // 네트워크 및 동기화 상태 (데모 모드가 아닐 때만 표시)
              if (!isDemoMode)
                Consumer(
                  builder: (context, ref, child) {
                    final isOnline = ref.watch(isOnlineProvider);
                    final networkStatus = ref.watch(networkStatusProvider);
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
                        '안녕하세요, $userName님! 👋',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '오늘도 건강한 하루 되세요',
                        style: TextStyle(
                          color: AppColors.textSecondary,
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
              Container(
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
              const SizedBox(height: 24),
              
              // BMI 캐릭터
              Center(
                child: AdvancedBMICharacter(
                  bmi: currentBMI,
                  size: 200,
                  gender: userGender,
                ),
              ),
              const SizedBox(height: 24),
              
              // BMI 진행 상황 표시
              BMIProgressIndicator(
                currentBMI: currentBMI,
                targetBMI: 22.0,
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
                  
                  final progress = ref.read(goalProvider.notifier).calculateProgress(currentWeight, startWeight);
                  final weightDifference = currentWeight - goal.targetWeight;
                  
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '목표 달성률',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${progress.toInt()}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => context.push('/home/goal-setting'),
                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '목표 체중: ${goal.targetWeight.toStringAsFixed(1)}kg (${weightDifference.abs().toStringAsFixed(1)}kg ${weightDifference > 0 ? "감량" : "증량"} 필요)',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (goal.targetDate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '목표 날짜: ${DateFormat('yyyy년 MM월 dd일').format(goal.targetDate!)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // 최근 7일 차트
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
                      '최근 7일 변화',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: _buildChart(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 체중 기록 히스토리
              const WeightHistoryList(limit: 5),
              const SizedBox(height: 24),
              
              // 체중 기록 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/home/weight-input'),
                  icon: const Icon(Icons.add),
                  label: const Text('오늘 체중 기록하기'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
      ),
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