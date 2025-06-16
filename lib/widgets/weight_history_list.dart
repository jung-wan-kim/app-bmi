import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/weight_record.dart';
import '../providers/weight_records_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/bmi_calculator.dart';
import 'animated_widgets.dart';
import '../core/constants/app_animations.dart';

class WeightHistoryList extends ConsumerWidget {
  final bool showAllRecords;
  final int? limit;

  const WeightHistoryList({
    super.key,
    this.showAllRecords = false,
    this.limit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(weightRecordsProvider);
    
    if (records.isEmpty) {
      return _buildEmptyState();
    }

    final displayRecords = showAllRecords 
        ? records 
        : records.take(limit ?? 5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '체중 기록',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!showAllRecords && records.length > (limit ?? 5))
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WeightHistoryScreen(),
                    ),
                  );
                },
                child: const Text('전체보기'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ...displayRecords.asMap().entries.map((entry) => 
          SlideInAnimation(
            delay: AppAnimations.listItemStaggerDelay * entry.key,
            child: _buildRecordItem(context, ref, entry.value),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [const Icon(
            Icons.monitor_weight_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 기록된 체중이 없습니다',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 체중을 기록해보세요!',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(BuildContext context, WidgetRef ref, WeightRecord record) {
    final bmiCategory = BMICalculator.getBMICategory(record.bmi);
    final bmiColor = _getBMIColor(bmiCategory);

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('기록 삭제'),
              content: const Text('이 체중 기록을 삭제하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('삭제'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        ref.read(weightRecordsProvider.notifier).deleteRecord(record.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:const Text('기록이 삭제되었습니다'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: bmiColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    record.weight.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: bmiColor,
                    ),
                  ),
                  Text(
                    'kg',
                    style: TextStyle(
                      fontSize: 12,
                      color: bmiColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat('MM월 dd일').format(record.recordedAt),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('HH:mm').format(record.recordedAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: bmiColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'BMI ${record.bmi.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: bmiColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        BMICalculator.getCategoryName(bmiCategory),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (record.notes != null && record.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      record.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
  const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
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

// 전체 히스토리를 보여주는 별도 화면
class WeightHistoryScreen extends ConsumerWidget {
  const WeightHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('체중 기록'),
      ),
      body: const SingleChildScrollView(
        padding:const EdgeInsets.all(20),
        child: WeightHistoryList(showAllRecords: true),
      ),
    );
  }
}