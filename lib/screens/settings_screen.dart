import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../providers/notification_settings_provider.dart';
import '../providers/weight_records_provider.dart';
import '../providers/goal_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _selectedWeightUnit = 'kg';
  String _selectedHeightUnit = 'cm';
  String _userName = '사용자';
  String _userEmail = '';
  double _userHeight = 170.0;
  bool _isDemoMode = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDemoMode = prefs.getBool('isDemoMode') ?? false;
      _userName = prefs.getString('demoUserName') ?? '데모 사용자';
      _userHeight = prefs.getDouble('demoUserHeight') ?? 170.0;
      _selectedWeightUnit = prefs.getString('weightUnit') ?? 'kg';
      _selectedHeightUnit = prefs.getString('heightUnit') ?? 'cm';
    });
    
    if (!_isDemoMode) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _userEmail = user.email ?? '';
      }
    }
  }
  
  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    final isDemoMode = prefs.getBool('isDemoMode') ?? false;
    
    if (isDemoMode) {
      // 데모 모드 종료
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('데모 모드 종료'),
          content: const Text('데모 모드를 종료하시겠습니까?\n모든 데이터가 삭제됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                '종료',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
      
      if (shouldExit == true) {
        await prefs.clear();
        if (!mounted) return;
        context.go('/login');
      }
      return;
    }
    
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '로그아웃',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    
    if (shouldSignOut == true) {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      context.go('/login');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 섹션
              Container(
                padding: const EdgeInsets.all(20),
                color: AppColors.surface,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isDemoMode ? '데모 모드' : _userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _editProfile,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 알림 설정
              Consumer(
                builder: (context, ref, child) {
                  final notificationSettings = ref.watch(notificationSettingsProvider);
                  return _buildSection(
                    title: '알림 설정',
                    children: [
                      _buildSwitchTile(
                        title: '알림 허용',
                        subtitle: '체중 기록 리마인더를 받습니다',
                        value: notificationSettings.isEnabled,
                        onChanged: (value) {
                          ref.read(notificationSettingsProvider.notifier).toggleEnabled();
                        },
                      ),
                      if (notificationSettings.isEnabled) ...[
                        _buildListTile(
                          title: '알림 시간',
                          subtitle: notificationSettings.reminderTime.format(),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _selectNotificationTime(ref),
                        ),
                        _buildListTile(
                          title: '알림 요일',
                          subtitle: _getSelectedDaysText(notificationSettings.selectedDays),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _selectNotificationDays(ref),
                        ),
                      ],
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 8),
              
              // 단위 설정
              _buildSection(
                title: '단위 설정',
                children: [
                  _buildListTile(
                    title: '체중 단위',
                    subtitle: _selectedWeightUnit,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final selected = await _showUnitDialog(
                        title: '체중 단위 선택',
                        options: ['kg', 'lb'],
                        selected: _selectedWeightUnit,
                      );
                      if (selected != null) {
                        setState(() => _selectedWeightUnit = selected);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('weightUnit', selected);
                      }
                    },
                  ),
                  _buildListTile(
                    title: '키 단위',
                    subtitle: _selectedHeightUnit,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final selected = await _showUnitDialog(
                        title: '키 단위 선택',
                        options: ['cm', 'ft'],
                        selected: _selectedHeightUnit,
                      );
                      if (selected != null) {
                        setState(() => _selectedHeightUnit = selected);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('heightUnit', selected);
                      }
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 데이터 관리
              _buildSection(
                title: '데이터 관리',
                children: [
                  _buildListTile(
                    title: '데이터 초기화',
                    subtitle: '모든 데이터를 삭제합니다',
                    leading: const Icon(Icons.delete_forever_outlined),
                    onTap: _clearAllData,
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 정보
              _buildSection(
                title: '정보',
                children: [
                  _buildListTile(
                    title: '버전',
                    subtitle: '1.0.0',
                    leading: const Icon(Icons.info_outline),
                  ),
                  _buildListTile(
                    title: '개인정보 처리방침',
                    leading: const Icon(Icons.privacy_tip_outlined),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      // TODO: 개인정보 처리방침
                    },
                  ),
                  _buildListTile(
                    title: '이용약관',
                    leading: const Icon(Icons.description_outlined),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      // TODO: 이용약관
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 로그아웃 / 데모 모드 종료
              Container(
                color: AppColors.surface,
                child: ListTile(
                  title: Text(
                    _isDemoMode ? '데모 모드 종료' : '로그아웃',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  leading: const Icon(
                    Icons.logout,
                    color: AppColors.error,
                  ),
                  onTap: _signOut,
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildListTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
    );
  }
  
  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
  
  Future<String?> _showUnitDialog({
    required String title,
    required List<String> options,
    required String selected,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: selected,
              onChanged: (value) => Navigator.pop(context, value),
              activeColor: AppColors.primary,
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _userName);
    final heightController = TextEditingController(text: _userHeight.toString());
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '키',
                suffixText: _selectedHeightUnit,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('demoUserName', nameController.text);
      await prefs.setDouble('demoUserHeight', double.tryParse(heightController.text) ?? _userHeight);
      
      setState(() {
        _userName = nameController.text;
        _userHeight = double.tryParse(heightController.text) ?? _userHeight;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 수정되었습니다')),
        );
      }
    }
  }
  
  Future<void> _selectNotificationTime(WidgetRef ref) async {
    final settings = ref.read(notificationSettingsProvider);
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.reminderTime.hour,
        minute: settings.reminderTime.minute,
      ),
    );
    
    if (time != null) {
      ref.read(notificationSettingsProvider.notifier).updateReminderTime(
        TimeOfDay(hour: time.hour, minute: time.minute),
      );
    }
  }
  
  Future<void> _selectNotificationDays(WidgetRef ref) async {
    final settings = ref.read(notificationSettingsProvider);
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 요일 선택'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(7, (index) {
                return CheckboxListTile(
                  title: Text(days[index]),
                  value: settings.selectedDays[index],
                  onChanged: (value) {
                    ref.read(notificationSettingsProvider.notifier).toggleDay(index);
                    setState(() {});
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  String _getSelectedDaysText(List<bool> selectedDays) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final selected = [];
    
    for (int i = 0; i < selectedDays.length; i++) {
      if (selectedDays[i]) {
        selected.add(days[i]);
      }
    }
    
    if (selected.isEmpty) return '선택 안 함';
    if (selected.length == 7) return '매일';
    if (selected.length == 5 && !selectedDays[5] && !selectedDays[6]) return '평일';
    if (selected.length == 2 && selectedDays[5] && selectedDays[6]) return '주말';
    
    return selected.join(', ');
  }
  
  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 초기화'),
        content: const Text('모든 체중 기록과 목표가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '초기화',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      
      // 체중 기록 삭제
      await prefs.remove('weight_records');
      
      // 목표 삭제
      await prefs.remove('current_goal');
      
      // 알림 설정 초기화
      await prefs.remove('notification_settings');
      
      // Provider 초기화
      ref.invalidate(weightRecordsProvider);
      ref.invalidate(goalProvider);
      ref.invalidate(notificationSettingsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 데이터가 초기화되었습니다')),
        );
      }
    }
  }
}