import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../providers/theme_provider.dart';

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
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사용자 정보 카드
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!_isDemoMode && _userEmail.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _userEmail,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              if (_isDemoMode) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.warning),
                                  ),
                                  child: const Text(
                                    '데모 모드',
                                    style: TextStyle(
                                      color: AppColors.warning,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 프로필 정보
              _buildSection(
                title: '프로필 정보',
                children: [
                  ListTile(
                    title: const Text('키'),
                    subtitle: Text('${_userHeight.toStringAsFixed(1)} $_selectedHeightUnit'),
                    leading: const Icon(Icons.height),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showHeightInput,
                  ),
                  ListTile(
                    title: const Text('성별'),
                    subtitle: Text(_userGender == 'male' ? '남성' : '여성'),
                    leading: const Icon(Icons.person),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showGenderSelection,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 앱 설정
              _buildSection(
                title: '앱 설정',
                children: [
                  ListTile(
                    title: const Text('단위 설정'),
                    subtitle: Text('체중: $_selectedWeightUnit, 키: $_selectedHeightUnit'),
                    leading: const Icon(Icons.straighten),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showUnitSettings,
                  ),
                  ListTile(
                    title: const Text('테마'),
                    subtitle: Text(isDarkMode ? '다크 모드' : '라이트 모드'),
                    leading: const Icon(Icons.palette),
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        // 테마 전환 기능 비활성화
                        // ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 계정
              _buildSection(
                title: '계정',
                children: [
                  ListTile(
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
                ],
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
  
  void _showUnitSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('단위 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('체중 단위'),
              trailing: DropdownButton<String>(
                value: _selectedWeightUnit,
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: 'lb', child: Text('lb')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedWeightUnit = value;
                    });
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('키 단위'),
              trailing: DropdownButton<String>(
                value: _selectedHeightUnit,
                items: const [
                  DropdownMenuItem(value: 'cm', child: Text('cm')),
                  DropdownMenuItem(value: 'ft', child: Text('ft')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedHeightUnit = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('weightUnit', _selectedWeightUnit);
              await prefs.setString('heightUnit', _selectedHeightUnit);
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showHeightInput() {
    final controller = TextEditingController(text: _userHeight.toStringAsFixed(1));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('키 입력'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '키 ($_selectedHeightUnit)',
                border: OutlineInputBorder(),
                suffixText: _selectedHeightUnit,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedHeightUnit == 'cm' 
                  ? '일반적인 성인 키: 150-200cm'
                  : '일반적인 성인 키: 4\'10\"-6\'6\"',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final heightText = controller.text.trim();
              final height = double.tryParse(heightText);
              
              if (height == null || height <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('올바른 키를 입력해주세요')),
                );
                return;
              }
              
              // 키 범위 검증
              final isValidHeight = _selectedHeightUnit == 'cm' 
                  ? (height >= 100 && height <= 250)
                  : (height >= 3.0 && height <= 8.0);
              
              if (!isValidHeight) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _selectedHeightUnit == 'cm' 
                          ? '키는 100-250cm 범위로 입력해주세요'
                          : '키는 3-8ft 범위로 입력해주세요'
                    ),
                  ),
                );
                return;
              }
              
              setState(() {
                _userHeight = height;
              });
              
              final prefs = await SharedPreferences.getInstance();
              await prefs.setDouble('demoUserHeight', height);
              
              if (!mounted) return;
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('키가 업데이트되었습니다')),
              );
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showGenderSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('성별 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('남성'),
              value: 'male',
              groupValue: _userGender,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('여성'),
              value: 'female',
              groupValue: _userGender,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    ).then((selectedGender) async {
      if (selectedGender != null && selectedGender != _userGender) {
        setState(() {
          _userGender = selectedGender;
        });
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userGender', selectedGender);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('성별이 업데이트되었습니다')),
        );
      }
    });
  }
}