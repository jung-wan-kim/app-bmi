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
    final stats = _calculateStatistics(_getFilteredRecords());
    
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
              Container(
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
                        '주간',
                        _selectedPeriod == StatsPeriod.week,
                        () => setState(() => _selectedPeriod = StatsPeriod.week),
                      ),
                    ),
                    Expanded(
                      child: _buildPeriodTab(
                        '월간',
                        _selectedPeriod == StatsPeriod.month,
                        () => setState(() => _selectedPeriod = StatsPeriod.month),
                      ),
                    ),
                    Expanded(
                      child: _buildPeriodTab(
                        '연간',
                        _selectedPeriod == StatsPeriod.year,
                        () => setState(() => _selectedPeriod = StatsPeriod.year),
                      ),
                    ),
                    Expanded(
                      child: _buildPeriodTab(
                        '전체',
                        _selectedPeriod == StatsPeriod.all,
                        () => setState(() => _selectedPeriod = StatsPeriod.all),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 통계 요약 카드
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
                    const Text(
                      '기간 통계',
                      style: TextStyle(
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
                            label: '최저 체중',
                            value: '${stats['minWeight'].toStringAsFixed(1)} kg',
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: _buildStatsItem(
                            icon: Icons.trending_up,
                            label: '최고 체중',
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
                            label: '평균 체중',
                            value: '${stats['avgWeight'].toStringAsFixed(1)} kg',
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: _buildStatsItem(
                            icon: Icons.swap_vert,
                            label: '총 변화량',
                            value: '${stats['totalChange'] > 0 ? '+' : ''}${stats['totalChange'].toStringAsFixed(1)} kg',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // 체중 변화 차트
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
                      '체중 추이',
                      style: TextStyle(
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
            ],
          ),
        ),
      ),
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
  
  Widget _buildWeightChart() {
    final records = _getFilteredRecords();
    
    if (records.isEmpty) {
      return const Center(
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
                final now = DateTime.now();
                final date = now.subtract(Duration(days: 6 - value.toInt()));
                return Text(
                  DateFormat('M/d').format(date),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                );
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
  
  List<FlSpot> _getWeightSpots() {
    final records = _getFilteredRecords();
    if (records.isEmpty) return [];
    
    final now = DateTime.now();
    final spots = <FlSpot>[];
    
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
    
    return spots;
  }
}