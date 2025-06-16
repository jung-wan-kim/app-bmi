import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/bmi_constants.dart';
import '../core/utils/bmi_calculator.dart';
import '../providers/goal_provider.dart';
import '../providers/weight_records_provider.dart';

class GoalSettingScreen extends ConsumerStatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  ConsumerState<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends ConsumerState<GoalSettingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _targetWeightController = TextEditingController();
  
  DateTime? _targetDate;
  double _currentWeight = 70.0;
  double _height = 170.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    final prefs = await SharedPreferences.getInstance();
    final latestRecord = ref.read(weightRecordsProvider.notifier).getLatestRecord();
    
    setState(() {
      _height = prefs.getDouble('demoUserHeight') ?? 170.0;
      _currentWeight = latestRecord?.weight ?? prefs.getDouble('demoUserWeight') ?? 70.0;
    });

    // 기존 목표가 있으면 로드
    final existingGoal = ref.read(goalProvider);
    if (existingGoal != null) {
      _targetWeightController.text = existingGoal.targetWeight.toString();
      _targetDate = existingGoal.targetDate;
    }
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _selectTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final targetWeight = double.parse(_targetWeightController.text);
        
        await ref.read(goalProvider.notifier).setGoal(
          targetWeight: targetWeight,
          targetDate: _targetDate,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('목표가 설정되었습니다'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('오류가 발생했습니다: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetWeight = double.tryParse(_targetWeightController.text) ?? 0;
    final targetBMI = targetWeight > 0 ? BMICalculator.calculateBMI(targetWeight, _height) : 0;
    final weightDifference = _currentWeight - targetWeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('목표 설정'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveGoal,
            child: const Text(
              '저장',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 현재 상태
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
                        '현재 상태',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              label: '현재 체중',
                              value: '${_currentWeight.toStringAsFixed(1)} kg',
                              icon: Icons.monitor_weight_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoItem(
                              label: '현재 BMI',
                              value: BMICalculator.calculateBMI(_currentWeight, _height).toStringAsFixed(1),
                              icon: Icons.analytics_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 목표 체중
                Text(
                  '목표 체중',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _targetWeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.0',
                    suffixText: 'kg',
                    suffixStyle: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    helperText: weightDifference > 0 
                      ? '${weightDifference.toStringAsFixed(1)}kg 감량 목표'
                      : weightDifference < 0
                        ? '${(-weightDifference).toStringAsFixed(1)}kg 증량 목표'
                        : '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '목표 체중을 입력해주세요';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight < AppConstants.minWeight || weight > AppConstants.maxWeight) {
                      return '올바른 체중을 입력해주세요 (${AppConstants.minWeight}-${AppConstants.maxWeight}kg)';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {}); // 실시간 계산을 위해
                  },
                ),
                const SizedBox(height: 24),

                // 목표 날짜
                Text(
                  '목표 날짜 (선택사항)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _selectTargetDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _targetDate != null
                            ? DateFormat('yyyy년 MM월 dd일').format(_targetDate!)
                            : '날짜를 선택하세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: _targetDate != null 
                              ? AppColors.textPrimary 
                              : AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (_targetDate != null)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _targetDate = null;
                              });
                            },
                            icon: const Icon(
                              Icons.clear,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 목표 BMI 표시
                if (targetWeight > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getBMIColor(BMICalculator.getBMICategory(targetBMI.toDouble())).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getBMIColor(BMICalculator.getBMICategory(targetBMI.toDouble())),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              color: _getBMIColor(BMICalculator.getBMICategory(targetBMI.toDouble())),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '목표 BMI',
                              style: TextStyle(
                                fontSize: 16,
                                color: _getBMIColor(BMICalculator.getBMICategory(targetBMI.toDouble())),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              targetBMI.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 28,
                                color: _getBMIColor(BMICalculator.getBMICategory(targetBMI.toDouble())),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          BMICalculator.getCategoryName(BMICalculator.getBMICategory(targetBMI.toDouble())),
                          style: TextStyle(
                            fontSize: 16,
                            color: _getBMIColor(BMICalculator.getBMICategory(targetBMI.toDouble())),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 권장 사항
                  if (targetBMI < 18.5 || targetBMI > 25) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '건강한 BMI는 18.5-25 범위입니다',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 32),

                // 저장 버튼
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveGoal,
                  child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('목표 설정하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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