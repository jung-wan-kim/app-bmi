import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../screens/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/profile_setup_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/weight_input_screen.dart';
import '../../screens/statistics_screen.dart';
import '../../screens/settings_screen.dart';

/// 라우터 프로바이더
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // 스플래시 화면
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // 온보딩
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // 로그인
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // 프로필 설정
      GoRoute(
        path: '/profile-setup',
        name: 'profileSetup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      
      // 홈 (메인 대시보드)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // 체중 입력
          GoRoute(
            path: 'weight-input',
            name: 'weightInput',
            builder: (context, state) => const WeightInputScreen(),
          ),
          
          // 통계
          GoRoute(
            path: 'statistics',
            name: 'statistics',
            builder: (context, state) => const StatisticsScreen(),
          ),
          
          // 설정
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    
    // 리다이렉트 로직
    redirect: (context, state) {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      final isLoggedIn = session != null;
      
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/onboarding';
      
      // 로그인하지 않은 경우
      if (!isLoggedIn && !isAuthRoute && state.matchedLocation != '/') {
        return '/login';
      }
      
      // 로그인한 경우 auth 라우트 접근 방지
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }
      
      return null;
    },
  );
});

/// 라우트 이름
class AppRoutes {
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String profileSetup = 'profileSetup';
  static const String home = 'home';
  static const String weightInput = 'weightInput';
  static const String statistics = 'statistics';
  static const String settings = 'settings';
}