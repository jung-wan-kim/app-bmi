import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'BMI Tracker',
      subtitle: '건강한 체중 관리의\n시작점',
      animationAsset: 'assets/animations/scale_weight.json',
      iconFallback: Icons.monitor_weight_outlined,
    ),
    OnboardingPageData(
      title: '매일 체중을 기록하고',
      subtitle: '변화를 한눈에',
      animationAsset: 'assets/animations/chart_grow.json',
      iconFallback: Icons.show_chart,
    ),
    OnboardingPageData(
      title: '나만의 BMI 캐릭터와',
      subtitle: '함께하는 건강 여정',
      animationAsset: 'assets/animations/character_transform.json',
      iconFallback: Icons.emoji_emotions,
    ),
    OnboardingPageData(
      title: '목표를 설정하고',
      subtitle: '건강한 변화를 시작하세요',
      animationAsset: 'assets/animations/goal_achieve.json',
      iconFallback: Icons.flag,
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
    if (!mounted) return;
    context.go('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip 버튼
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            
            // 페이지 콘텐츠
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),
            
            // 인디케이터와 버튼
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // 페이지 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // 액션 버튼
                  SizedBox(
                    width: double.infinity,
                    child: _currentPage == _pages.length - 1
                        ? ElevatedButton(
                            onPressed: _completeOnboarding,
                            child: const Text('시작하기'),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: AppConstants.onboardingAnimDuration,
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text('다음'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 애니메이션 또는 아이콘
          SizedBox(
            height: 200,
            child: _buildAnimation(),
          ),
          const SizedBox(height: 48),
          
          // 타이틀
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // 서브타이틀
          Text(
            data.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimation() {
    // Lottie 파일이 없을 경우 아이콘으로 대체
    return FutureBuilder(
      future: DefaultAssetBundle.of(context as BuildContext)
          .load(data.animationAsset),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Lottie.asset(
            data.animationAsset,
            fit: BoxFit.contain,
          );
        } else {
          // Lottie 파일이 없으면 아이콘 표시
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Icon(
                  data.iconFallback,
                  size: 100,
                  color: AppColors.primary,
                ),
              );
            },
          );
        }
      },
    );
  }
}

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String animationAsset;
  final IconData iconFallback;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.animationAsset,
    required this.iconFallback,
  });
}