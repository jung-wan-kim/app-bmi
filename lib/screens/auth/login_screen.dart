import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    
    try {
      // Google Sign In 설정
      const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
      const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }
      
      // Supabase에 로그인
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      if (response.user != null) {
        // 프로필 확인
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .maybeSingle();
            
        if (!mounted) return;
        
        if (profile == null || profile['height'] == null) {
          // 프로필 미완성 - 프로필 설정으로
          context.go('/profile-setup');
        } else {
          // 홈으로 이동
          context.go('/home');
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:const Text('로그인 실패: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _enterDemoMode() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDemoMode', true);
      await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
      
      if (mounted) {
        // 데모 사용자 정보 설정
        await prefs.setString('demoUserName', '데모 사용자');
        await prefs.setDouble('demoUserHeight', 170.0);
        await prefs.setDouble('demoUserWeight', 65.0);
        await prefs.setString('demoUserGender', 'male');
        
        // 홈 화면으로 이동
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:const Text('데모 모드 진입 실패: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: const String.fromEnvironment('APPLE_SERVICE_ID'),
          redirectUri: Uri.parse(
            const String.fromEnvironment('APPLE_REDIRECT_URL'),
          ),
        ),
      );
      
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw 'Unable to get ID Token from Apple Sign In.';
      }
      
      // Supabase에 로그인
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );
      
      if (response.user != null) {
        // 프로필 확인
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .maybeSingle();
            
        if (!mounted) return;
        
        if (profile == null || profile['height'] == null) {
          // 프로필 미완성 - 프로필 설정으로
          context.go('/profile-setup');
        } else {
          // 홈으로 이동
          context.go('/home');
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:const Text('로그인 실패: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:const Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // 앱 로고
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.monitor_weight_outlined,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // 앱 이름
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // 서브타이틀
              Text(
                '간편하게 로그인하고\n건강한 체중 관리를 시작하세요',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // 로그인 버튼들
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                // Apple 로그인 버튼
                if (Theme.of(context).platform == TargetPlatform.iOS)
                  _buildSocialLoginButton(
                    onPressed: _signInWithApple,
                    icon: Icons.apple,
                    label: 'Apple로 로그인',
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                if (Theme.of(context).platform == TargetPlatform.iOS)
                  const SizedBox(height: 12),
                
                // Google 로그인 버튼
                _buildSocialLoginButton(
                  onPressed: _signInWithGoogle,
                  assetIcon: 'assets/icons/google_logo.png',
                  label: 'Google로 로그인',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textPrimary,
                  borderColor: AppColors.border,
                ),
              ],
              
              const SizedBox(height: 32),
              
              // 데모 모드 버튼
              TextButton(
                onPressed: _enterDemoMode,
                child: Text(
                  '데모 모드로 시작하기',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 약관
              Text(
                '계속 진행하시면 서비스 이용약관 및\n개인정보 처리방침에 동의하는 것으로 간주됩니다.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required VoidCallback onPressed,
    IconData? icon,
    String? assetIcon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    Color? borderColor,
  }) {
    returnconst SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(
            color: borderColor ?? backgroundColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)const Icon(icon, size: 24)
            else if (assetIcon != null)
              Image.asset(
                assetIcon,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.login, size: 24);
                },
              ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}