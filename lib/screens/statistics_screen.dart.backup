import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/bmi_calculator.dart';
import '../providers/weight_records_provider.dart';
import '../providers/theme_provider.dart';
import '../models/weight_record.dart';
import '../widgets/animated_widgets.dart';
import '../core/constants/app_animations.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/responsive_utils.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

enum StatsPeriod { week, month, year, all }

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  StatsPeriod _selectedPeriod = StatsPeriod.week;
  
  // 통계 계산
  Map<String, dynamic> _calculateStatistics(List<WeightRecord> records) {
    if (records.isEmpty) {
      return {
        'avgWeight': 0.0,
        'totalChange': 0.0,
        'maxWeight': 0.0,
        'minWeight': 0.0,
        'startBMI': 0.0,
        'currentBMI': 0.0,
        'bmiChange': 0.0,
      };
    }
    
    final weights = records.map((r) => r.weight).toList();
    final avgWeight = weights.reduce((a, b) => a + b) / weights.length;
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    
    // 체중 변화 (첫 기록 대비 마지막 기록)
    final totalChange = records.isNotEmpty && records.length > 1 
        ? records.first.weight - records.last.weight 
        : 0.0;
    
    // BMI 변화
    final startBMI = records.isNotEmpty ? records.last.bmi : 0.0;
    final currentBMI = records.isNotEmpty ? records.first.bmi : 0.0;
    final bmiChange = currentBMI - startBMI;
    
    return {
      'avgWeight': avgWeight,
      'totalChange': totalChange,
      'maxWeight': maxWeight,
      'minWeight': minWeight,
      'startBMI': startBMI,
      'currentBMI': currentBMI,
      'bmiChange': bmiChange,
    };
  }
  
  List<WeightRecord> _getFilteredRecords() {
    final allRecords = ref.watch(weightRecordsProvider);
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case StatsPeriod.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        return allRecords.where((r) => r.recordedAt.isAfter(weekAgo)).toList();
      case StatsPeriod.month:
        final monthAgo = now.subtract(const Duration(days: 30));
        return allRecords.where((r) => r.recordedAt.isAfter(monthAgo)).toList();
      case StatsPeriod.year:
        final yearAgo = now.subtract(const Duration(days: 365));
        return allRecords.where((r) => r.recordedAt.isAfter(yearAgo)).toList();
      case StatsPeriod.all:
        return allRecords;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('통계'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 기간 선택 탭
        FadeInAnimation(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildPeriodTab(
                    localizations?.weeklyReport ?? '주간',
                    _selectedPeriod == StatsPeriod.week,
                    () => setState(() => _selectedPeriod = StatsPeriod.week),
                  ),
                ),
                Expanded(
                  child: _buildPeriodTab(
                    localizations?.monthlyReport ?? '월간',
                    _selectedPeriod == StatsPeriod.month,
                    () => setState(() => _selectedPeriod = StatsPeriod.month),
                  ),
                ),
                Expanded(
                  child: _buildPeriodTab(
                    localizations?.yearlyReport ?? '연간',
                    _selectedPeriod == StatsPeriod.year,
                    () => setState(() => _selectedPeriod = StatsPeriod.year),
                  ),
                ),
                Expanded(
                  child: _buildPeriodTab(
                    localizations?.allTimeReport ?? '전체',
                    _selectedPeriod == StatsPeriod.all,
                    () => setState(() => _selectedPeriod = StatsPeriod.all),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // 통계 요약 카드
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
                Text(
                  localizations?.periodStats ?? '기간 통계',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatsItem(
                        icon: Icons.trending_down,
                        label: localizations?.lowestWeight ?? '최저 체중',
                        value: '${stats['minWeight'].toStringAsFixed(1)} kg',
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: _buildStatsItem(
                        icon: Icons.trending_up,
                        label: localizations?.highestWeight ?? '최고 체중',
                        value: '${stats['maxWeight'].toStringAsFixed(1)} kg',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatsItem(
                        icon: Icons.show_chart,
                        label: localizations?.averageWeight ?? '평균 체중',
                        value: '${stats['avgWeight'].toStringAsFixed(1)} kg',
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: _buildStatsItem(
                        icon: Icons.swap_vert,
                        label: localizations?.totalChange ?? '총 변화량',
                        value: '${stats['totalChange'] > 0 ? '+' : ''}${stats['totalChange'].toStringAsFixed(1)} kg',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // BMI 변화 카드
        ScaleInAnimation(
          delay: AppAnimations.listItemStaggerDelay * 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.bmiProgress ?? 'BMI 변화',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBMIChangeItem(
                      label: localizations?.startBMI ?? '시작 BMI',
                      value: stats['startBMI'].toStringAsFixed(1),
                      category: BMICalculator.getBMICategory(stats['startBMI']),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.textSecondary,
                    ),
                    _buildBMIChangeItem(
                      label: localizations?.currentBMI ?? '현재 BMI',
                      value: stats['currentBMI'].toStringAsFixed(1),
                      category: BMICalculator.getBMICategory(stats['currentBMI']),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '${localizations?.bmiChange ?? 'BMI 변화'}: ${stats['bmiChange'] > 0 ? '+' : ''}${stats['bmiChange'].toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: stats['bmiChange'] < 0 ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // 체중 변화 차트
        FadeInAnimation(
          delay: AppAnimations.listItemStaggerDelay * 3,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.weightTrend ?? '체중 추이',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: _buildWeightChart(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // BMI 분포 차트
        FadeInAnimation(
          delay: AppAnimations.listItemStaggerDelay * 4,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.bmiDistribution ?? 'BMI 분포',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: _buildBMIDistributionChart(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTabletLayout(BuildContext context, Map<String, dynamic> stats, bool isDarkMode, AppLocalizations? localizations) {
    return Column(
      children: [
        // 기간 선택 탭
        FadeInAnimation(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildPeriodTab(
                    localizations?.weeklyReport ?? '주간',
                    _selectedPeriod == StatsPeriod.week,
                    () => setState(() => _selectedPeriod = StatsPeriod.week),
                  ),
                ),
                Expanded(
                  child: _buildPeriodTab(
                    localizations?.monthlyReport ?? '월간',
                    _selectedPeriod == StatsPeriod.month,
                    () => setState(() => _selectedPeriod = StatsPeriod.month),
                  ),
                ),
                Expanded(
                  child: _buildPeriodTab(
                    localizations?.yearlyReport ?? '연간',
                    _selectedPeriod == StatsPeriod.year,
                    () => setState(() => _selectedPeriod = StatsPeriod.year),
                  ),
                ),
                Expanded(
                  child: _buildPeriodTab(
                    localizations?.allTimeReport ?? '전체',
                    _selectedPeriod == StatsPeriod.all,
                    () => setState(() => _selectedPeriod = StatsPeriod.all),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // 태블릿용 2열 레이아웃
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽: 통계 카드들
            Expanded(
              child: Column(
                children: [
                  // 통계 요약 카드
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
                          Text(
                            localizations?.periodStats ?? '기간 통계',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatsItem(
                                  icon: Icons.trending_down,
                                  label: localizations?.lowestWeight ?? '최저 체중',
                                  value: '${stats['minWeight'].toStringAsFixed(1)} kg',
                                  color: Colors.white,
                                ),
                              ),
                              Expanded(
                                child: _buildStatsItem(
                                  icon: Icons.trending_up,
                                  label: localizations?.highestWeight ?? '최고 체중',
                                  value: '${stats['maxWeight'].toStringAsFixed(1)} kg',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatsItem(
                                  icon: Icons.show_chart,
                                  label: localizations?.averageWeight ?? '평균 체중',
                                  value: '${stats['avgWeight'].toStringAsFixed(1)} kg',
                                  color: Colors.white,
                                ),
                              ),
                              Expanded(
                                child: _buildStatsItem(
                                  icon: Icons.swap_vert,
                                  label: localizations?.totalChange ?? '총 변화량',
                                  value: '${stats['totalChange'] > 0 ? '+' : ''}${stats['totalChange'].toStringAsFixed(1)} kg',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // BMI 변화 카드
                  ScaleInAnimation(
                    delay: AppAnimations.listItemStaggerDelay * 2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations?.bmiProgress ?? 'BMI 변화',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildBMIChangeItem(
                                label: localizations?.startBMI ?? '시작 BMI',
                                value: stats['startBMI'].toStringAsFixed(1),
                                category: BMICalculator.getBMICategory(stats['startBMI']),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: AppColors.textSecondary,
                              ),
                              _buildBMIChangeItem(
                                label: localizations?.currentBMI ?? '현재 BMI',
                                value: stats['currentBMI'].toStringAsFixed(1),
                                category: BMICalculator.getBMICategory(stats['currentBMI']),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              '${localizations?.bmiChange ?? 'BMI 변화'}: ${stats['bmiChange'] > 0 ? '+' : ''}${stats['bmiChange'].toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: stats['bmiChange'] < 0 ? AppColors.success : AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 24),
            
            // 오른쪽: 차트들
            Expanded(
              child: Column(
                children: [
                  // 체중 변화 차트
                  FadeInAnimation(
                    delay: AppAnimations.listItemStaggerDelay * 3,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations?.weightTrend ?? '체중 추이',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 250,
                            child: _buildWeightChart(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // BMI 분포 차트
                  FadeInAnimation(
                    delay: AppAnimations.listItemStaggerDelay * 4,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations?.bmiDistribution ?? 'BMI 분포',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: _buildBMIDistributionChart(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPeriodTab(String label, bool isSelected, VoidCallback onTap) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatsItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color.withOpacity(0.8)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildBMIChangeItem({
    required String label,
    required String value,
    required BMICategory category,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getBMIColor(category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getBMIColor(category).withOpacity(0.3),
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getBMIColor(category),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          BMICalculator.getCategoryName(category),
          style: TextStyle(
            fontSize: 11,
            color: _getBMIColor(category),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? AppColors.borderDark : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeightChart() {
    final records = _getFilteredRecords();
    
    if (records.isEmpty) {
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
    
    final spots = _getWeightSpots();
    if (spots.isEmpty) return Container();
    
    final weights = spots.map((s) => s.y).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final padding = (maxWeight - minWeight) * 0.1;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
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
              interval: 2,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
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
                if (_selectedPeriod == StatsPeriod.week) {
                  // 주간
                  final now = DateTime.now();
                  final date = now.subtract(Duration(days: 6 - value.toInt()));
                  return Text(
                    DateFormat('M/d').format(date),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  );
                } else if (_selectedPeriod == StatsPeriod.month) {
                  // 월간
                  return Text(
                    '${value.toInt() + 1}주',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  );
                } else {
                  // 연간
                  final now = DateTime.now();
                  final month = now.month - 11 + value.toInt();
                  final actualMonth = month <= 0 ? month + 12 : month;
                  return Text(
                    '$actualMonth월',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                }
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: minWeight - padding - 1,
        maxY: maxWeight + padding + 1,
        lineBarsData: [
          LineChartBarData(
            spots: _getWeightSpots(),
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
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBMIChart() {
    final records = _getFilteredRecords();
    
    if (records.isEmpty) {
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
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 30,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
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
                if (_selectedPeriod == StatsPeriod.week) {
                  // 주간
                  final now = DateTime.now();
                  final date = now.subtract(Duration(days: 6 - value.toInt()));
                  return Text(
                    DateFormat('E', 'ko').format(date),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  );
                } else if (_selectedPeriod == StatsPeriod.month) {
                  // 월간
                  return Text(
                    '${value.toInt() + 1}주',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  );
                } else {
                  // 연간
                  final now = DateTime.now();
                  final month = now.month - 11 + value.toInt();
                  final actualMonth = month <= 0 ? month + 12 : month;
                  if (value.toInt() % 2 == 0) {
                    return Text(
                      '$actualMonth월',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    );
                  }
                  return const Text('');
                }
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: _getBMIBarGroups(),
      ),
    );
  }
  
  List<FlSpot> _getWeightSpots() {
    final records = _getFilteredRecords();
    if (records.isEmpty) return [];
    
    final now = DateTime.now();
    final spots = <FlSpot>[];
    
    if (_selectedPeriod == StatsPeriod.week) {
      // 주간: 날짜별로 그룹화
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: 6 - i));
        final dayRecords = records.where((r) => 
          r.recordedAt.year == date.year &&
          r.recordedAt.month == date.month &&
          r.recordedAt.day == date.day
        ).toList();
        
        if (dayRecords.isNotEmpty) {
          // 같은 날 여러 기록이 있으면 평균
          final avgWeight = dayRecords.map((r) => r.weight).reduce((a, b) => a + b) / dayRecords.length;
          spots.add(FlSpot(i.toDouble(), avgWeight));
        }
      }
    } else if (_selectedPeriod == StatsPeriod.month) {
      // 월간: 주별로 그룹화
      for (int i = 0; i < 4; i++) {
        final weekStart = now.subtract(Duration(days: (3 - i) * 7));
        final weekEnd = weekStart.add(const Duration(days: 7));
        final weekRecords = records.where((r) => 
          r.recordedAt.isAfter(weekStart) && r.recordedAt.isBefore(weekEnd)
        ).toList();
        
        if (weekRecords.isNotEmpty) {
          final avgWeight = weekRecords.map((r) => r.weight).reduce((a, b) => a + b) / weekRecords.length;
          spots.add(FlSpot(i.toDouble(), avgWeight));
        }
      }
    } else {
      // 연간: 월별로 그룹화
      for (int i = 0; i < 12; i++) {
        final month = now.month - 11 + i;
        final year = now.year + (month <= 0 ? -1 : 0);
        final actualMonth = month <= 0 ? month + 12 : month;
        
        final monthRecords = records.where((r) => 
          r.recordedAt.year == year && r.recordedAt.month == actualMonth
        ).toList();
        
        if (monthRecords.isNotEmpty) {
          final avgWeight = monthRecords.map((r) => r.weight).reduce((a, b) => a + b) / monthRecords.length;
          spots.add(FlSpot(i.toDouble(), avgWeight));
        }
      }
    }
    
    return spots;
  }
  
  List<BarChartGroupData> _getBMIBarGroups() {
    final records = _getFilteredRecords();
    if (records.isEmpty) return [];
    
    final now = DateTime.now();
    final groups = <BarChartGroupData>[];
    
    if (_selectedPeriod == StatsPeriod.week) {
      // 주간: 날짜별 BMI
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: 6 - i));
        final dayRecords = records.where((r) => 
          r.recordedAt.year == date.year &&
          r.recordedAt.month == date.month &&
          r.recordedAt.day == date.day
        ).toList();
        
        if (dayRecords.isNotEmpty) {
          final avgBMI = dayRecords.map((r) => r.bmi).reduce((a, b) => a + b) / dayRecords.length;
          groups.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: avgBMI,
                color: _getBMIColor(BMICalculator.getBMICategory(avgBMI)),
                width: 30,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ],
          ));
        }
      }
    } else {
      // 월간/연간: 주/월별 BMI
      final periods = _selectedPeriod == StatsPeriod.month ? 4 : 12;
      for (int i = 0; i < periods; i++) {
        List<WeightRecord> periodRecords;
        
        if (_selectedPeriod == StatsPeriod.month) {
          // 월간: 주별
          final weekStart = now.subtract(Duration(days: (3 - i) * 7));
          final weekEnd = weekStart.add(const Duration(days: 7));
          periodRecords = records.where((r) => 
            r.recordedAt.isAfter(weekStart) && r.recordedAt.isBefore(weekEnd)
          ).toList();
        } else {
          // 연간: 월별
          final month = now.month - 11 + i;
          final year = now.year + (month <= 0 ? -1 : 0);
          final actualMonth = month <= 0 ? month + 12 : month;
          periodRecords = records.where((r) => 
            r.recordedAt.year == year && r.recordedAt.month == actualMonth
          ).toList();
        }
        
        if (periodRecords.isNotEmpty) {
          final avgBMI = periodRecords.map((r) => r.bmi).reduce((a, b) => a + b) / periodRecords.length;
          groups.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: avgBMI,
                color: _getBMIColor(BMICalculator.getBMICategory(avgBMI)),
                width: _selectedPeriod == StatsPeriod.year ? 20 : 40,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ],
          ));
        }
      }
    }
    
    return groups;
  }
  
  Color _getBMIColor(BMICategory category) {
    switch (category) {
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
  
  Widget _buildBMIDistributionChart() {
    final records = _getFilteredRecords();
    
    if (records.isEmpty) {
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
    
    // BMI 카테고리별 분포 계산
    final Map<BMICategory, int> distribution = {};
    for (var record in records) {
      final category = BMICalculator.getBMICategory(record.bmi);
      distribution[category] = (distribution[category] ?? 0) + 1;
    }
    
    final total = records.length;
    final List<PieChartSectionData> sections = [];
    
    distribution.forEach((category, count) {
      final percentage = (count / total * 100);
      sections.add(
        PieChartSectionData(
          color: _getBMIColor(category),
          value: percentage,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });
    
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: BMICategory.values.map((category) {
            final count = distribution[category] ?? 0;
            if (count == 0) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getBMIColor(category),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    BMICalculator.getCategoryName(category),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}