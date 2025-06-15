import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedWeightUnit = 'kg';
  String _selectedHeightUnit = 'cm';
  
  Future<void> _signOut() async {
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
                          const Text(
                            '사용자님',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'user@example.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: 프로필 편집
                      },
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 알림 설정
              _buildSection(
                title: '알림 설정',
                children: [
                  _buildSwitchTile(
                    title: '알림 허용',
                    subtitle: '체중 기록 리마인더를 받습니다',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                  if (_notificationsEnabled) ...[
                    _buildListTile(
                      title: '알림 시간',
                      subtitle: '오전 9:00',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: 시간 선택
                      },
                    ),
                  ],
                ],
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
                    title: '데이터 내보내기',
                    subtitle: 'CSV 파일로 내보내기',
                    leading: const Icon(Icons.download_outlined),
                    onTap: () {
                      // TODO: 데이터 내보내기
                    },
                  ),
                  _buildListTile(
                    title: '데이터 백업',
                    subtitle: '클라우드에 백업하기',
                    leading: const Icon(Icons.cloud_upload_outlined),
                    onTap: () {
                      // TODO: 데이터 백업
                    },
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
              
              // 로그아웃
              Container(
                color: AppColors.surface,
                child: ListTile(
                  title: const Text(
                    '로그아웃',
                    style: TextStyle(
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
}