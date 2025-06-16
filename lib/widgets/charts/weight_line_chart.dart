import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/weight_record.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/bmi_calculator.dart';

class WeightLineChart extends StatelessWidget {
  final List<WeightRecord> records;
  final double? targetWeight;
  final double height;
  final String period;
  final bool showBmiLine;
  final VoidCallback? onTap;

  const WeightLineChart({
    super.key,
    required this.records,
    required this.height,
    this.targetWeight,
    this.period = 'week',
    this.showBmiLine = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _buildEmptyState(context);
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sortedRecords = List<WeightRecord>.from(records)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final minWeight = sortedRecords
        .map((r) => r.weight)
        .reduce((a, b) => a < b ? a : b) - 5;
    final maxWeight = sortedRecords
        .map((r) => r.weight)
        .reduce((a, b) => a > b ? a : b) + 5;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                _buildChartData(
                  context,
                  sortedRecords,
                  minWeight,
                  maxWeight,
                  isDark,
                ),
                duration: const Duration(milliseconds: 250),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 350,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? Colors.grey[900] 
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '체중 기록이 없습니다',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '체중을 기록하면 그래프가 표시됩니다',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final latestWeight = records.isNotEmpty ? records.last.weight : 0.0;
    final latestBmi = BMICalculator.calculateBMI(latestWeight, height);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '체중 변화',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getPeriodText(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
        if (records.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${latestWeight.toStringAsFixed(1)} kg',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              if (showBmiLine)
                Text(
                  'BMI ${latestBmi.toStringAsFixed(1)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          context,
          '체중',
          theme.primaryColor,
          solid: true,
        ),
        if (targetWeight != null) ...[
          const SizedBox(width: 24),
          _buildLegendItem(
            context,
            '목표 체중',
            AppColors.success,
            solid: false,
          ),
        ],
        if (showBmiLine) ...[
          const SizedBox(width: 24),
          _buildLegendItem(
            context,
            'BMI',
            AppColors.warning,
            solid: true,
          ),
        ],
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    {bool solid = true}
  ) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: solid ? color : Colors.transparent,
            border: solid ? null : Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  LineChartData _buildChartData(
    BuildContext context,
    List<WeightRecord> sortedRecords,
    double minY,
    double maxY,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final weightSpots = sortedRecords.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    final bmiSpots = showBmiLine
        ? sortedRecords.asMap().entries.map((entry) {
            final bmi = BMICalculator.calculateBMI(entry.value.weight, height);
            return FlSpot(entry.key.toDouble(), bmi * 3); // BMI를 시각적으로 조정
          }).toList()
        : <FlSpot>[];

    return LineChartData(
      minX: 0,
      maxX: (sortedRecords.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        // 체중 라인
        LineChartBarData(
          spots: weightSpots,
          isCurved: true,
          color: theme.primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: theme.primaryColor,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: theme.primaryColor.withOpacity(0.1),
          ),
        ),
        // 목표 체중 라인
        if (targetWeight != null)
          LineChartBarData(
            spots: List.generate(
              sortedRecords.length,
              (index) => FlSpot(index.toDouble(), targetWeight!),
            ),
            isCurved: false,
            color: AppColors.success,
            barWidth: 2,
            isStrokeCapRound: true,
            dashArray: [8, 4],
            dotData: const FlDotData(show: false),
          ),
        // BMI 라인
        if (showBmiLine && bmiSpots.isNotEmpty)
          LineChartBarData(
            spots: bmiSpots,
            isCurved: true,
            color: AppColors.warning,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: 10,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: _getBottomTitleInterval(sortedRecords.length),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= sortedRecords.length) {
                return const SizedBox.shrink();
              }
              final date = sortedRecords[index].recordedAt;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _formatDate(date),
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 11,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => isDark ? Colors.grey[800]! : Colors.white,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final date = sortedRecords[spot.x.toInt()].recordedAt;
              final isWeight = spot.barIndex == 0;
              final isBmi = showBmiLine && spot.barIndex == 2;
              
              String text;
              Color color;
              
              if (isWeight) {
                text = '${spot.y.toStringAsFixed(1)} kg';
                color = theme.primaryColor;
              } else if (isBmi) {
                final actualBmi = spot.y / 3; // 시각적 조정 되돌리기
                text = 'BMI ${actualBmi.toStringAsFixed(1)}';
                color = AppColors.warning;
              } else {
                text = '목표 ${spot.y.toStringAsFixed(1)} kg';
                color = AppColors.success;
              }
              
              return LineTooltipItem(
                '${DateFormat('M/d').format(date)}\n$text',
                TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  double _getBottomTitleInterval(int dataCount) {
    if (dataCount <= 7) return 1;
    if (dataCount <= 14) return 2;
    if (dataCount <= 30) return 5;
    return 7;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return '오늘';
    if (difference == 1) return '어제';
    if (difference < 7) return DateFormat('E', 'ko').format(date);
    
    return DateFormat('M/d').format(date);
  }

  String _getPeriodText() {
    switch (period) {
      case 'week':
        return '최근 7일';
      case 'month':
        return '최근 30일';
      case 'year':
        return '최근 1년';
      case 'all':
        return '전체 기간';
      default:
        return period;
    }
  }
}