import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/bmi_calculator.dart';

class WeightInputScreen extends ConsumerStatefulWidget {
  const WeightInputScreen({super.key});

  @override
  ConsumerState<WeightInputScreen> createState() => _WeightInputScreenState();
}

class _WeightInputScreenState extends ConsumerState<WeightInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  // 임시 데이터 (실제로는 프로바이더에서 가져옴)
  final double userHeight = 170.0;
  
  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
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
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  Future<void> _saveWeight() async {
    if (_formKey.currentState!.validate()) {
      // TODO: 실제 저장 로직 구현
      
      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('체중이 기록되었습니다'),
          backgroundColor: AppColors.success,
        ),
      );
      
      // 홈으로 돌아가기
      context.pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final bmi = weight > 0 ? BMICalculator.calculateBMI(weight, userHeight) : 0;
    final bmiCategory = weight > 0 ? BMICalculator.getBMICategory(bmi.toDouble()) : null;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('체중 기록'),
        actions: [
          TextButton(
            onPressed: _saveWeight,
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
                // 날짜 선택
                Text(
                  '날짜',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
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
                                DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _selectTime,
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
                              Icons.access_time,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // 체중 입력
                Text(
                  '체중 (kg)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0.0',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    suffixText: 'kg',
                    suffixStyle: const TextStyle(
                      fontSize: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '체중을 입력해주세요';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight < AppConstants.minWeight || weight > AppConstants.maxWeight) {
                      return '올바른 체중을 입력해주세요 (${AppConstants.minWeight}-${AppConstants.maxWeight}kg)';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {}); // BMI 실시간 계산을 위해
                  },
                ),
                const SizedBox(height: 24),
                
                // BMI 표시
                if (weight > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getBMIColor(bmiCategory!).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getBMIColor(bmiCategory),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'BMI',
                              style: TextStyle(
                                fontSize: 16,
                                color: _getBMIColor(bmiCategory),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              bmi.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 32,
                                color: _getBMIColor(bmiCategory),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          BMICalculator.getCategoryName(bmiCategory),
                          style: TextStyle(
                            fontSize: 18,
                            color: _getBMIColor(bmiCategory),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // 메모
                Text(
                  '메모 (선택사항)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: '오늘의 컨디션이나 특이사항을 기록해보세요',
                  ),
                ),
                const SizedBox(height: 32),
                
                // 저장 버튼
                ElevatedButton(
                  onPressed: _saveWeight,
                  child: const Text('체중 기록하기'),
                ),
              ],
            ),
          ),
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