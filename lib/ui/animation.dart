import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

// ---------------------------------------------------------------------------
// Jelly Spring Constants
// ---------------------------------------------------------------------------

/// Micro interaction: chip toggle, button press (~200ms).
const jellyMicro = SpringDescription(mass: 1.0, stiffness: 150, damping: 14);

/// Quick pop-in: card appear, download complete icon (~350ms).
const jellyQuick = SpringDescription(mass: 1.0, stiffness: 100, damping: 15);

/// Standard: page transition, modal enter (~450ms).
const jellyStandard = SpringDescription(mass: 1.0, stiffness: 120, damping: 12);

/// Slow bloom: NSFW blur reveal, empty state, hero image (~600ms).
const jellySlow = SpringDescription(mass: 1.0, stiffness: 80, damping: 10);

// ---------------------------------------------------------------------------
// Cubic approximations (for widgets that only take Curve, not spring)
// ---------------------------------------------------------------------------

/// Approximates [jellyQuick] — soft overshoot, one visible wobble.
const jellyCurve = Cubic(0.25, 1.3, 0.55, 1.0);

/// Approximates [jellyStandard] — gentler overshoot.
const jellyCurveGentle = Cubic(0.34, 1.25, 0.64, 1.0);

// ---------------------------------------------------------------------------
// Helper Widgets
// ---------------------------------------------------------------------------

/// Staggered fade+scale entrance for a list of children.
///
/// Each child fades in and scales from 0.92→1.03→1.0 with a [jellyQuick]
/// spring feel, delayed by [staggerMs] per index.
class JellyStaggerList extends StatelessWidget {
  final List<Widget> children;
  final int staggerMs;
  final Duration duration;

  const JellyStaggerList({
    super.key,
    required this.children,
    this.staggerMs = 60,
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(children.length, (i) {
        if (reduced) return children[i];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: duration,
          curve: const Interval(0.0, 1.0, curve: jellyCurve),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale:
                    0.92 +
                    0.11 * value.clamp(0.0, 0.6) / 0.6 -
                    (value > 0.6 ? 0.03 * (value - 0.6) / 0.4 : 0),
                child: child,
              ),
            );
          },
          child: children[i],
        );
      }),
    );
  }
}

/// Wraps a child in a jelly-tap scale animation.
///
/// On tap the child scales 1→0.94→1.02→1.0 over ~200ms.
class JellyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const JellyTap({super.key, required this.child, this.onTap});

  @override
  State<JellyTap> createState() => _JellyTapState();
}

class _JellyTapState extends State<JellyTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward(from: 0.0);
  void _onTapUp(_) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: Tween(
            begin: 1.0,
            end: 0.94,
          ).chain(CurveTween(curve: Curves.easeOut)).transform(_ctrl.value),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Convenience Builders
// ---------------------------------------------------------------------------

/// An [AnimatedScale] pre-configured with [jellyCurve].
class JellyScale extends StatelessWidget {
  final Widget child;
  final bool show;
  final Duration duration;

  const JellyScale({
    super.key,
    required this.child,
    required this.show,
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) return show ? child : const SizedBox.shrink();

    return AnimatedScale(
      scale: show ? 1.0 : 0.92,
      duration: duration,
      curve: jellyCurve,
      child: AnimatedOpacity(
        opacity: show ? 1.0 : 0.0,
        duration: duration,
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}

/// Drift-in from below: translateY(12→0) + fade, [jellySlow] feel.
class JellyDriftIn extends StatelessWidget {
  final Widget child;
  final bool show;
  final Duration duration;
  final double offsetY;

  const JellyDriftIn({
    super.key,
    required this.child,
    required this.show,
    this.duration = const Duration(milliseconds: 500),
    this.offsetY = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) return show ? child : const SizedBox.shrink();

    return AnimatedSlide(
      offset: show ? Offset.zero : Offset(0, offsetY / 100),
      duration: duration,
      curve: jellyCurveGentle,
      child: AnimatedOpacity(
        opacity: show ? 1.0 : 0.0,
        duration: duration,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer Skeleton
// ---------------------------------------------------------------------------

/// A shimmer placeholder that mimics the shape of a model card in the grid.
class ShimmerCard extends StatefulWidget {
  const ShimmerCard({super.key});

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduced = MediaQuery.of(context).disableAnimations;
    final base = theme.colorScheme.surfaceContainerHighest;
    final shimmer = theme.colorScheme.onSurface.withValues(alpha: 0.06);

    if (reduced) {
      return Card(child: Container(color: base));
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        return Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment(t * 3 - 1.5, -1),
                end: Alignment(t * 3, 1.5),
                colors: [base, shimmer, base],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A grid of [ShimmerCard] placeholders matching the card layout.
class ShimmerGrid extends StatelessWidget {
  final int count;
  final int crossAxisCount;

  const ShimmerGrid({super.key, this.count = 8, this.crossAxisCount = 3});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: count,
      itemBuilder: (_, _) => const ShimmerCard(),
    );
  }
}

// ---------------------------------------------------------------------------
// Page Transition
// ---------------------------------------------------------------------------

/// A [PageRouteBuilder] that slides up and fades in with a jelly feel.
///
/// Usage:
/// ```dart
/// Navigator.of(context).push(JellyPageRoute(builder: (_) => MyPage()));
/// ```
class JellyPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  JellyPageRoute({required this.builder})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final reduced = MediaQuery.of(context).disableAnimations;
          if (reduced) return child;

          return AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return Opacity(
                opacity: animation.value,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - animation.value)),
                  child: child,
                ),
              );
            },
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      );
}

// ---------------------------------------------------------------------------
// Animated Progress Bar
// ---------------------------------------------------------------------------

/// A [LinearProgressIndicator] with a gradient shimmer on the active track.
class JellyProgressBar extends StatelessWidget {
  final double value;
  final double height;

  const JellyProgressBar({super.key, required this.value, this.height = 6});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background track
              Container(
                height: height,
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              // Filled portion
              FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NSFW Blur Reveal
// ---------------------------------------------------------------------------

/// Blurs a child and reveals it on tap with a [jellySlow] animation.
///
/// Designed for NSFW thumbnails: starts blurred (radius 20), tap to
/// animate the blur away over 300ms.
class NsfwBlurReveal extends StatefulWidget {
  final Widget child;

  const NsfwBlurReveal({super.key, required this.child});

  @override
  State<NsfwBlurReveal> createState() => _NsfwBlurRevealState();
}

class _NsfwBlurRevealState extends State<NsfwBlurReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _blur;

  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _blur = Tween(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_revealed) return;
    setState(() => _revealed = true);
    _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return ImageFiltered(
            imageFilter: _revealed
                ? ImageFilter.blur(sigmaX: _blur.value, sigmaY: _blur.value)
                : ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                child!,
                if (!_revealed)
                  const Center(
                    child: Icon(
                      Icons.visibility,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ),
              ],
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
