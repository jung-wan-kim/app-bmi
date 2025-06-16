import 'package:flutter/material.dart';
import 'dart:math' as math;

class CharacterAnimator extends StatefulWidget {
  final Widget child;
  final AnimationType animationType;
  final Duration duration;
  final bool repeat;
  final bool autoPlay;
  final VoidCallback? onAnimationComplete;

  const CharacterAnimator({
    super.key,
    required this.child,
    this.animationType = AnimationType.bounce,
    this.duration = const Duration(seconds: 2),
    this.repeat = true,
    this.autoPlay = true,
    this.onAnimationComplete,
  });

  @override
  State<CharacterAnimator> createState() => _CharacterAnimatorState();
}

class _CharacterAnimatorState extends State<CharacterAnimator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _secondaryAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    if (widget.autoPlay) {
      _startAnimation();
    }
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    switch (widget.animationType) {
      case AnimationType.bounce:
        _animation = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
        break;
      case AnimationType.shake:
        _animation = Tween<double>(
          begin: -1,
          end: 1,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticIn,
        ));
        break;
      case AnimationType.pulse:
        _animation = Tween<double>(
          begin: 1,
          end: 1.2,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
        break;
      case AnimationType.float:
        _animation = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
        _secondaryAnimation = Tween<double>(
          begin: 0,
          end: 2 * math.pi,
        ).animate(_controller);
        break;
      case AnimationType.wave:
        _animation = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.linear,
        ));
        break;
      case AnimationType.celebrate:
        _animation = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ));
        break;
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.repeat) {
          if (widget.animationType == AnimationType.shake ||
              widget.animationType == AnimationType.bounce) {
            _controller.reverse();
          } else {
            _controller.repeat();
          }
        } else {
          widget.onAnimationComplete?.call();
        }
      } else if (status == AnimationStatus.dismissed && widget.repeat) {
        _controller.forward();
      }
    });
  }

  void _startAnimation() {
    _controller.forward();
  }

  void stopAnimation() {
    _controller.stop();
  }

  void restartAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void didUpdateWidget(CharacterAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationType != widget.animationType ||
        oldWidget.duration != widget.duration) {
      _controller.dispose();
      _setupAnimation();
      if (widget.autoPlay) {
        _startAnimation();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        switch (widget.animationType) {
          case AnimationType.bounce:
            return Transform.translate(
              offset: Offset(0, -20 * _animation.value),
              child: widget.child,
            );
          case AnimationType.shake:
            return Transform.translate(
              offset: Offset(10 * _animation.value, 0),
              child: widget.child,
            );
          case AnimationType.pulse:
            return Transform.scale(
              scale: _animation.value,
              child: widget.child,
            );
          case AnimationType.float:
            return Transform.translate(
              offset: Offset(
                10 * math.sin(_secondaryAnimation.value),
                -15 * _animation.value,
              ),
              child: widget.child,
            );
          case AnimationType.wave:
            return Transform.rotate(
              angle: math.sin(_animation.value * 2 * math.pi) * 0.1,
              child: widget.child,
            );
          case AnimationType.celebrate:
            return Transform.scale(
              scale: 1 + 0.3 * _animation.value,
              child: Transform.rotate(
                angle: _animation.value * 2 * math.pi,
                child: widget.child,
              ),
            );
        }
      },
    );
  }
}

enum AnimationType {
  bounce,
  shake,
  pulse,
  float,
  wave,
  celebrate,
}

class ParticleAnimation extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color particleColor;
  final Duration duration;
  final bool enabled;

  const ParticleAnimation({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.particleColor = Colors.amber,
    this.duration = const Duration(seconds: 3),
    this.enabled = true,
  });

  @override
  State<ParticleAnimation> createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _particles = List.generate(
      widget.particleCount,
      (index) => Particle(
        position: Offset.zero,
        velocity: Offset(
          (math.Random().nextDouble() - 0.5) * 200,
          -math.Random().nextDouble() * 300 - 100,
        ),
        size: math.Random().nextDouble() * 6 + 2,
        color: widget.particleColor,
      ),
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(200, 200),
              painter: ParticlePainter(
                particles: _particles,
                progress: _controller.value,
              ),
            );
          },
        ),
      ],
    );
  }
}

class Particle {
  Offset position;
  final Offset velocity;
  final double size;
  final Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      final opacity = 1.0 - progress;
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity * 0.8)
        ..style = PaintingStyle.fill;

      final position = Offset(
        center.dx + particle.velocity.dx * progress,
        center.dy + particle.velocity.dy * progress + 
            200 * progress * progress, // 중력 효과
      );

      canvas.drawCircle(
        position,
        particle.size * (1 - progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class WeightChangeAnimation extends StatelessWidget {
  final double oldWeight;
  final double newWeight;
  final Duration duration;
  final TextStyle? textStyle;
  final VoidCallback? onComplete;

  const WeightChangeAnimation({
    super.key,
    required this.oldWeight,
    required this.newWeight,
    this.duration = const Duration(milliseconds: 1000),
    this.textStyle,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGain = newWeight > oldWeight;
    final difference = (newWeight - oldWeight).abs();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: oldWeight, end: newWeight),
      duration: duration,
      builder: (context, value, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${value.toStringAsFixed(1)} kg',
              style: textStyle ?? theme.textTheme.headlineMedium,
            ),
            if (value != oldWeight)
              Text(
                '${isGain ? '+' : '-'}${difference.toStringAsFixed(1)} kg',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isGain ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        );
      },
      onEnd: onComplete,
    );
  }
}