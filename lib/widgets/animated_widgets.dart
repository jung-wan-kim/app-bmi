import 'package:flutter/material.dart';
import '../core/constants/app_animations.dart';

/// 페이드 인 애니메이션 위젯
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final Duration? delay;
  final Curve? curve;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration,
    this.delay,
    this.curve,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AppAnimations.normalDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AppAnimations.defaultCurve,
    );

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// 슬라이드 인 애니메이션 위젯
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final Duration? delay;
  final Curve? curve;
  final Offset? startOffset;

  const SlideInAnimation({
    super.key,
    required this.child,
    this.duration,
    this.delay,
    this.curve,
    this.startOffset,
  });

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AppAnimations.normalDuration,
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: widget.startOffset ?? AppAnimations.slideStart,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AppAnimations.defaultCurve,
    ));

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

/// 스케일 인 애니메이션 위젯
class ScaleInAnimation extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final Duration? delay;
  final Curve? curve;

  const ScaleInAnimation({
    super.key,
    required this.child,
    this.duration,
    this.delay,
    this.curve,
  });

  @override
  State<ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<ScaleInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AppAnimations.normalDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AppAnimations.cardAnimationCurve,
    ));

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// 스태거드 리스트 애니메이션 위젯
class StaggeredListAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration? itemDuration;
  final Duration? staggerDelay;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.itemDuration,
    this.staggerDelay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        children.length,
        (index) => SlideInAnimation(
          duration: itemDuration ?? AppAnimations.listItemDuration,
          delay: (staggerDelay ?? AppAnimations.listItemStaggerDelay) * index,
          child: children[index],
        ),
      ),
    );
  }
}

/// 탭 가능한 스케일 애니메이션
class TappableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;

  const TappableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.95,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<TappableScale> createState() => _TappableScaleState();
}

class _TappableScaleState extends State<TappableScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: widget.child,
        ),
      ),
    );
  }
}