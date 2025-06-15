import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/bmi_calculator.dart';
import '../providers/weight_records_provider.dart';
import '../models/weight_record.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  int _selectedPeriod = 0; // 0: 주간, 1: 월간, 2: 연간
  
  // 통계 계산
  Map<String, double> _calculateStatistics(List<WeightRecord> records) {
    if (records.isEmpty) {
      return {
        'average': 0,
        'change': 0,
        'max': 0,
        'min': 0,
      };
    }
    
    final weights = records.map((r) => r.weight).toList();
    final average = weights.reduce((a, b) => a + b) / weights.length;
    final max = weights.reduce((a, b) => a > b ? a : b);
    final min = weights.reduce((a, b) => a < b ? a : b);
    
    // 체중 변화 (첫 기록 대비 마지막 기록)
    final change = records.isNotEmpty && records.length > 1 
        ? records.first.weight - records.last.weight 
        : 0.0;
    
    return {
      'average': average,
      'change': change,
      'max': max,
      'min': min,
    };
  }
  
  List<WeightRecord> _getFilteredRecords() {
    final allRecords = ref.watch(weightRecordsProvider);
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 0: // 주간
        final weekAgo = now.subtract(const Duration(days: 7));
        return allRecords.where((r) => r.recordedAt.isAfter(weekAgo)).toList();
      case 1: // 월간
        final monthAgo = now.subtract(const Duration(days: 30));
        return allRecords.where((r) => r.recordedAt.isAfter(monthAgo)).toList();
      case 2: // 연간
        final yearAgo = now.subtract(const Duration(days: 365));
        return allRecords.where((r) => r.recordedAt.isAfter(yearAgo)).toList();
      default:
        return allRecords;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('통계'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기간 선택
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _buildPeriodButton('주간', 0),
                    _buildPeriodButton('월간', 1),
                    _buildPeriodButton('연간', 2),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
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
                      '체중 변화',
                      style: TextStyle(
                        fontSize: 18,
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
              const SizedBox(height: 20),
              
              // 통계 요약
              Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final records = _getFilteredRecords();
                        final stats = _calculateStatistics(records);
                        return _buildStatCard(
                          title: '평균 체중',
                          value: stats['average']!.toStringAsFixed(1),
                          unit: 'kg',
                          icon: Icons.analytics_outlined,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final records = _getFilteredRecords();
                        final stats = _calculateStatistics(records);
                        final change = stats['change']!;
                        return _buildStatCard(
                          title: '체중 변화',
                          value: change >= 0 ? '+${change.toStringAsFixed(1)}' : change.toStringAsFixed(1),
                          unit: 'kg',
                          icon: change >= 0 ? Icons.trending_up : Icons.trending_down,
                          color: change >= 0 ? AppColors.warning : AppColors.success,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final records = _getFilteredRecords();
                        final stats = _calculateStatistics(records);
                        return _buildStatCard(
                          title: '최고 체중',
                          value: stats['max']!.toStringAsFixed(1),
                          unit: 'kg',
                          icon: Icons.arrow_upward,
                          color: AppColors.warning,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final records = _getFilteredRecords();
                        final stats = _calculateStatistics(records);
                        return _buildStatCard(
                          title: '최저 체중',
                          value: stats['min']!.toStringAsFixed(1),
                          unit: 'kg',
                          icon: Icons.arrow_downward,
                          color: AppColors.info,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // BMI 변화 차트
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
                      'BMI 변화',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: _buildBMIChart(),
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
  
  Widget _buildPeriodButton(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
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
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
                  color: AppColors.textSecondary,
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
                  color: AppColors.textSecondary,
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
                if (_selectedPeriod == 0) {
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
                } else if (_selectedPeriod == 1) {
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
                if (_selectedPeriod == 0) {
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
                } else if (_selectedPeriod == 1) {
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
    
    if (_selectedPeriod == 0) {
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
    } else if (_selectedPeriod == 1) {
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
    
    if (_selectedPeriod == 0) {
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
      final periods = _selectedPeriod == 1 ? 4 : 12;
      for (int i = 0; i < periods; i++) {
        List<WeightRecord> periodRecords;
        
        if (_selectedPeriod == 1) {
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
                width: _selectedPeriod == 2 ? 20 : 40,
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
}