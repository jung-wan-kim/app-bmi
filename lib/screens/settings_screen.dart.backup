import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../providers/notification_settings_provider.dart';
import '../providers/weight_records_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../services/backup_restore_service.dart';
import '../core/constants/app_accessibility.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/responsive_utils.dart';

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
  String _userGender = 'male';
  
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
      _userGender = prefs.getString('userGender') ?? 'male';
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
    final isDarkMode = ref.watch(isDarkModeProvider);
    final localizations = AppLocalizations.of(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(localizations?.settings ?? '설정'),
      ),
      body: SafeArea(
        child: isTablet
            ? _buildTabletLayout(context, isDarkMode, localizations)
            : _buildMobileLayout(context, isDarkMode, localizations),
      ),
    );
  }
  
  Widget _buildMobileLayout(BuildContext context, bool isDarkMode, AppLocalizations? localizations) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 섹션
          Container(
            padding: const EdgeInsets.all(20),
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
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
                        _isDemoMode ? localizations?.demoMode ?? '데모 모드' : _userEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
              
              // 테마 설정
              _buildSection(
                title: '테마 설정',
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final themeMode = ref.watch(themeModeProvider);
                      return Semantics(
                        label: AppAccessibility.semanticLabels['themeToggle'],
                        hint: '현재 ${_getThemeModeText(themeMode)}',
                        child: _buildListTile(
                          title: '테마 모드',
                          subtitle: _getThemeModeText(themeMode),
                          leading: Icon(
                            themeMode == ThemeMode.dark 
                                ? Icons.dark_mode 
                                : themeMode == ThemeMode.light
                                    ? Icons.light_mode
                                    : Icons.brightness_auto,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showThemeModeDialog(ref),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 언어 설정
              Consumer(
                builder: (context, ref, child) {
                  final locale = ref.watch(localeProvider);
                  final l10n = AppLocalizations.of(context);
                  return _buildSection(
                    title: l10n?.language ?? '언어',
                    children: [
                      _buildListTile(
                        title: l10n?.language ?? '언어',
                        subtitle: locale.languageCode == 'ko' ? '한국어' : 'English',
                        leading: const Icon(Icons.language),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showLanguageDialog(ref),
                      ),
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
              
              // 클라우드 동기화 (데모 모드가 아닐 때만 표시)
              if (!_isDemoMode) ...[
                Consumer(
                  builder: (context, ref, child) {
                    // final syncState = ref.watch(syncProvider);
                    final lastSyncTime = ref.watch(lastSyncTimeProvider);
                    final isSyncing = ref.watch(isSyncingProvider);
                    final syncError = ref.watch(syncErrorProvider);
                    
                    return _buildSection(
                      title: '클라우드 동기화',
                      children: [
                        _buildListTile(
                          title: '동기화',
                          subtitle: _getSyncStatusText(lastSyncTime, isSyncing, syncError),
                          leading: Icon(
                            isSyncing 
                                ? Icons.sync 
                                : (syncError != null 
                                    ? Icons.sync_problem 
                                    : Icons.cloud_done),
                            color: isSyncing 
                                ? AppColors.primary 
                                : (syncError != null 
                                    ? AppColors.error 
                                    : AppColors.success),
                          ),
                          trailing: isSyncing 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: isSyncing ? null : () => _performSync(ref),
                        ),
                        if (syncError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    syncError,
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => ref.read(syncProvider.notifier).clearError(),
                                  child: const Text('닫기'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
              
              // 데이터 관리
              _buildSection(
                title: '데이터 관리',
                children: [
                  _buildListTile(
                    title: '데이터 백업',
                    subtitle: '현재 데이터를 파일로 저장합니다',
                    leading: const Icon(Icons.backup_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _createBackup,
                  ),
                  _buildListTile(
                    title: '데이터 복원',
                    subtitle: '백업 파일에서 데이터를 복원합니다',
                    leading: const Icon(Icons.restore_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _restoreBackup,
                  ),
                  _buildListTile(
                    title: '백업 파일 관리',
                    subtitle: '저장된 백업 파일을 관리합니다',
                    leading: const Icon(Icons.folder_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _manageBackupFiles,
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    title: '데이터 초기화',
                    subtitle: '모든 데이터를 삭제합니다',
                    leading: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
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
    String selectedGender = _userGender;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 수정'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
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
              const SizedBox(height: 16),
              const Text('성별', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('남성'),
                      value: 'male',
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() => selectedGender = value!);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('여성'),
                      value: 'female',
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() => selectedGender = value!);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      await prefs.setString('userGender', selectedGender);
      
      setState(() {
        _userName = nameController.text;
        _userHeight = double.tryParse(heightController.text) ?? _userHeight;
        _userGender = selectedGender;
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
        NotificationTime(hour: time.hour, minute: time.minute),
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

  String _getSyncStatusText(DateTime? lastSyncTime, bool isSyncing, String? error) {
    if (isSyncing) {
      return '동기화 중...';
    }
    
    if (error != null) {
      return '동기화 실패';
    }
    
    if (lastSyncTime == null) {
      return '아직 동기화되지 않음';
    }
    
    final now = DateTime.now();
    final difference = now.difference(lastSyncTime);
    
    if (difference.inMinutes < 1) {
      return '방금 동기화됨';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전 동기화됨';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전 동기화됨';
    } else {
      return DateFormat('MM/dd HH:mm').format(lastSyncTime);
    }
  }

  Future<void> _performSync(WidgetRef ref) async {
    final syncNotifier = ref.read(syncProvider.notifier);
    
    try {
      await syncNotifier.syncAll();
      
      final syncState = ref.read(syncProvider);
      if (syncState.lastResult?.success == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('동기화가 완료되었습니다\n${syncState.lastResult.toString()}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('동기화 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // 백업/복원 관련 메서드들

  Future<void> _createBackup() async {
    final backupService = BackupRestoreService();
    
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('백업 생성 중...'),
          ],
        ),
      ),
    );
    
    final result = await backupService.createBackup();
    
    if (!mounted) return;
    Navigator.pop(context); // 로딩 다이얼로그 닫기
    
    if (result.success) {
      // 백업 성공
      final shouldShare = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('백업 완료'),
          content: Text(
            '백업이 성공적으로 생성되었습니다.\n'
            '파일명: ${result.fileName}\n'
            '기록 수: ${result.recordCount}개\n\n'
            '백업 파일을 공유하시겠습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('나중에'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('공유'),
            ),
          ],
        ),
      );
      
      if (shouldShare == true && result.filePath != null) {
        await backupService.shareBackup(result.filePath!);
      }
    } else {
      // 백업 실패
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('백업 실패'),
          content: Text('백업 생성 중 오류가 발생했습니다.\n${result.error}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _restoreBackup() async {
    // 복원 경고
    final shouldRestore = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 복원'),
        content: const Text(
          '백업 파일에서 데이터를 복원하면 현재 데이터가 모두 교체됩니다.\n'
          '계속하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '복원',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    
    if (shouldRestore != true) return;
    
    final backupService = BackupRestoreService();
    
    // 백업 파일 선택
    final filePath = await backupService.selectBackupFile();
    if (filePath == null) return;
    
    // 로딩 다이얼로그 표시
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('데이터 복원 중...'),
          ],
        ),
      ),
    );
    
    final result = await backupService.restoreBackup(filePath);
    
    if (!mounted) return;
    Navigator.pop(context); // 로딩 다이얼로그 닫기
    
    if (result.success) {
      // 복원 성공
      // Provider 새로고침
      ref.invalidate(weightRecordsProvider);
      ref.invalidate(goalProvider);
      ref.invalidate(notificationSettingsProvider);
      
      // 화면 새로고침
      await _loadUserData();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('복원 완료'),
          content: Text(
            '데이터가 성공적으로 복원되었습니다.\n'
            '복원된 기록: ${result.recordCount}개\n'
            '백업 날짜: ${result.backupDate != null ? DateFormat('yyyy-MM-dd HH:mm').format(result.backupDate!) : '알 수 없음'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      // 복원 실패
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('복원 실패'),
          content: Text('데이터 복원 중 오류가 발생했습니다.\n${result.error}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _manageBackupFiles() async {
    final backupService = BackupRestoreService();
    final backupFiles = await backupService.getBackupFiles();
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '백업 파일 관리',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 10),
            if (backupFiles.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text('저장된 백업 파일이 없습니다'),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: backupFiles.length,
                  itemBuilder: (context, index) {
                    final file = backupFiles[index];
                    return ListTile(
                      title: Text(file.fileName),
                      subtitle: Text(
                        '${DateFormat('yyyy-MM-dd HH:mm').format(file.createdAt)} • ${file.formattedSize}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          switch (value) {
                            case 'share':
                              await backupService.shareBackup(file.filePath);
                              break;
                            case 'delete':
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('백업 삭제'),
                                  content: Text('${file.fileName}을(를) 삭제하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text(
                                        '삭제',
                                        style: TextStyle(color: AppColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (shouldDelete == true) {
                                await backupService.deleteBackupFile(file.filePath);
                                if (mounted) {
                                  Navigator.pop(context);
                                  _manageBackupFiles(); // 목록 새로고침
                                }
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('공유'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('삭제', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
      case ThemeMode.system:
        return '시스템 설정 따름';
    }
  }
  
  Future<void> _showThemeModeDialog(WidgetRef ref) async {
    final currentMode = ref.read(themeModeProvider);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테마 모드 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('라이트 모드'),
              subtitle: const Text('밝은 테마 사용'),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('다크 모드'),
              subtitle: const Text('어두운 테마 사용'),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('시스템 설정 따름'),
              subtitle: const Text('기기 설정에 따라 자동 전환'),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _showLanguageDialog(WidgetRef ref) async {
    final currentLocale = ref.read(localeProvider);
    final l10n = AppLocalizations.of(context);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.language ?? '언어 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('한국어'),
              value: 'ko',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(
                  const Locale('ko', 'KR'),
                );
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(
                  const Locale('en', 'US'),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTabletLayout(BuildContext context, bool isDarkMode, AppLocalizations? localizations) {
    return Row(
      children: [
        // 왼쪽: 프로필 및 기본 설정
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 카드
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isDemoMode ? localizations?.demoMode ?? '데모 모드' : _userEmail,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _editProfile,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(localizations?.editProfile ?? '프로필 편집'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 알림 설정
                Consumer(
                  builder: (context, ref, child) {
                    final notificationSettings = ref.watch(notificationSettingsProvider);
                    return _buildSection(
                      title: localizations?.notificationSettings ?? '알림 설정',
                      children: [
                        _buildSwitchTile(
                          title: localizations?.enableNotifications ?? '알림 허용',
                          subtitle: localizations?.notificationSubtitle ?? '체중 기록 리마인더를 받습니다',
                          value: notificationSettings.isEnabled,
                          onChanged: (value) {
                            ref.read(notificationSettingsProvider.notifier).toggleEnabled();
                          },
                        ),
                        if (notificationSettings.isEnabled) ...[
                          _buildListTile(
                            title: localizations?.notificationTime ?? '알림 시간',
                            subtitle: notificationSettings.reminderTime.format(),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _selectNotificationTime(ref),
                          ),
                          _buildListTile(
                            title: localizations?.notificationDays ?? '알림 요일',
                            subtitle: _getSelectedDaysText(notificationSettings.selectedDays),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _selectNotificationDays(ref),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                
                // 테마 및 언어 설정
                _buildSection(
                  title: localizations?.appearance ?? '외관',
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final themeMode = ref.watch(themeModeProvider);
                        return _buildListTile(
                          title: localizations?.theme ?? '테마',
                          subtitle: _getThemeModeText(themeMode),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showThemeModeDialog(ref),
                        );
                      },
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final locale = ref.watch(localeProvider);
                        return _buildListTile(
                          title: localizations?.language ?? '언어',
                          subtitle: locale.languageCode == 'ko' ? '한국어' : 'English',
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showLanguageDialog(ref),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const VerticalDivider(thickness: 1, width: 1),
        
        // 오른쪽: 데이터 관리 및 기타 설정
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 동기화 설정
                if (!_isDemoMode)
                  Consumer(
                    builder: (context, ref, child) {
                      final syncState = ref.watch(syncProvider);
                      return _buildSection(
                        title: localizations?.dataSync ?? '데이터 동기화',
                        children: [
                          _buildListTile(
                            title: localizations?.syncStatus ?? '동기화 상태',
                            subtitle: _getSyncStatusText(
                              syncState.lastSyncTime,
                              syncState.isSyncing,
                              syncState.lastError,
                            ),
                            trailing: syncState.isSyncing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : TextButton(
                                    onPressed: () => _performSync(ref),
                                    child: Text(localizations?.syncNow ?? '동기화'),
                                  ),
                          ),
                          if (syncState.lastResult != null)
                            _buildListTile(
                              title: localizations?.lastSyncResult ?? '마지막 동기화 결과',
                              subtitle: syncState.lastResult.toString(),
                            ),
                        ],
                      );
                    },
                  ),
                
                // 백업/복원
                _buildSection(
                  title: localizations?.backupRestore ?? '백업/복원',
                  children: [
                    _buildListTile(
                      title: localizations?.createBackup ?? '백업 생성',
                      subtitle: localizations?.createBackupSubtitle ?? '현재 데이터를 파일로 저장',
                      leading: const Icon(Icons.backup_outlined),
                      onTap: _createBackup,
                    ),
                    _buildListTile(
                      title: localizations?.restoreBackup ?? '데이터 복원',
                      subtitle: localizations?.restoreBackupSubtitle ?? '백업 파일에서 데이터 복원',
                      leading: const Icon(Icons.restore_outlined),
                      onTap: _restoreBackup,
                    ),
                    _buildListTile(
                      title: localizations?.manageBackups ?? '백업 파일 관리',
                      subtitle: localizations?.manageBackupsSubtitle ?? '저장된 백업 파일 보기',
                      leading: const Icon(Icons.folder_outlined),
                      onTap: _manageBackupFiles,
                    ),
                  ],
                ),
                
                // 데이터 관리
                _buildSection(
                  title: localizations?.dataManagement ?? '데이터 관리',
                  children: [
                    _buildListTile(
                      title: localizations?.clearAllData ?? '모든 데이터 초기화',
                      subtitle: localizations?.clearAllDataSubtitle ?? '모든 체중 기록과 목표 삭제',
                      leading: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
                      titleStyle: const TextStyle(color: AppColors.error),
                      onTap: _clearAllData,
                    ),
                  ],
                ),
                
                // 앱 정보
                _buildSection(
                  title: localizations?.appInfo ?? '앱 정보',
                  children: [
                    _buildListTile(
                      title: localizations?.version ?? '버전',
                      subtitle: '1.0.0',
                    ),
                    _buildListTile(
                      title: localizations?.privacyPolicy ?? '개인정보 처리방침',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: 개인정보 처리방침 페이지로 이동
                      },
                    ),
                    _buildListTile(
                      title: localizations?.termsOfService ?? '이용약관',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: 이용약관 페이지로 이동
                      },
                    ),
                  ],
                ),
                
                // 로그아웃 버튼
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: Text(
                      _isDemoMode 
                          ? localizations?.exitDemoMode ?? '데모 모드 종료'
                          : localizations?.signOut ?? '로그아웃',
                      style: const TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}