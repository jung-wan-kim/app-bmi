import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../models/goal_model.dart';

class ProgressChart extends StatefulWidget {
  final double currentWeight;
  final double startWeight;
  final double targetWeight;
  final DateTime? targetDate;
  final double size;
  final bool showDetails;
  final bool animate;
  final Duration animationDuration;
  final VoidCallback? onTap;

  const ProgressChart({
    super.key,
    required this.currentWeight,
    required this.startWeight,
    required this.targetWeight,
    this.targetDate,
    this.size = 200,
    this.showDetails = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.onTap,
  });

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: _calculateProgress(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    if (widget.animate) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ProgressChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWeight != widget.currentWeight ||
        oldWidget.targetWeight != widget.targetWeight) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: _calculateProgress(),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _calculateProgress() {
    final totalToLose = widget.startWeight - widget.targetWeight;
    final currentLoss = widget.startWeight - widget.currentWeight;
    
    if (totalToLose == 0) return 1.0;
    
    // 목표 초과 달성도 허용 (최대 120%)
    return (currentLoss / totalToLose).clamp(0.0, 1.2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.showDetails ? widget.size * 1.5 : widget.size,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child:const Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 원형 진행률 차트
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 배경 원
                        CustomPaint(
                          size: Size(widget.size * 0.7, widget.size * 0.7),
                          painter: _CircularProgressPainter(
                            progress: 1.0,
                            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                            strokeWidth: widget.size * 0.08,
                          ),
                        ),
                        // 진행률
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size(widget.size * 0.7, widget.size * 0.7),
                              painter: _CircularProgressPainter(
                                progress: _progressAnimation.value,
                                color: _getProgressColor(_progressAnimation.value),
                                strokeWidth: widget.size * 0.08,
                                strokeCap: StrokeCap.round,
                              ),
                            );
                          },
                        ),
                        // 중앙 정보
                        _buildCenterInfo(context),
                      ],
                    ),
                  );
                },
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 24),
                _buildDetails(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterInfo(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final progress = _progressAnimation.value;
        final percentage = (progress * 100).clamp(0, 999);
        final isExceeded = progress > 1.0;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getProgressColor(progress),
              ),
            ),
            if (isExceeded) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '목표 초과!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else ...[
              Text(
                '달성률',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDetails(BuildContext context) {
    final theme = Theme.of(context);
    final weightLost = widget.startWeight - widget.currentWeight;
    final weightToLose = widget.currentWeight - widget.targetWeight;
    final daysRemaining = widget.targetDate?.difference(DateTime.now()).inDays;
    
    return Column(
      children: [
        // 체중 변화 정보
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDetailItem(
              context,
              '시작',
              '${widget.startWeight.toStringAsFixed(1)} kg',
              Icons.flag_outlined,
              theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
            ),
            _buildDetailItem(
              context,
              '현재',
              '${widget.currentWeight.toStringAsFixed(1)} kg',
              Icons.person,
              theme.primaryColor,
            ),
            _buildDetailItem(
              context,
              '목표',
              '${widget.targetWeight.toStringAsFixed(1)} kg',
              Icons.star,
              AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 진행 상황
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '감량한 체중',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${weightLost.abs().toStringAsFixed(1)} kg',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: weightLost > 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
              if (weightToLose > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '남은 체중',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${weightToLose.toStringAsFixed(1)} kg',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              if (daysRemaining != null && daysRemaining > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '남은 기간',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '$daysRemaining일',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: daysRemaining < 30 ? AppColors.warning : null,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        // 동기부여 메시지
        if (_progressAnimation.value > 0) ...[
          const SizedBox(height: 16),
          Text(
            _getMotivationalMessage(_progressAnimation.value),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color? color,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [const Icon(
          icon,
          size: 24,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return AppColors.success;
    if (progress >= 0.7) return AppColors.warning;
    if (progress >= 0.3) return AppColors.info;
    return AppColors.error;
  }

  String _getMotivationalMessage(double progress) {
    if (progress >= 1.0) return '축하합니다! 목표를 달성했어요! 🎉';
    if (progress >= 0.8) return '거의 다 왔어요! 조금만 더 힘내세요!';
    if (progress >= 0.6) return '잘하고 있어요! 계속 이대로만 하면 돼요!';
    if (progress >= 0.4) return '절반 가까이 왔네요! 화이팅!';
    if (progress >= 0.2) return '좋은 시작이에요! 꾸준히 해봐요!';
    return '천 리 길도 한 걸음부터! 시작이 중요해요!';
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.strokeCap = StrokeCap.butt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = strokeCap;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}