import 'package:flutter/material.dart';

import '../theme/app_surfaces.dart';

/// Bloc « squelette » (placeholder de chargement) avec pulsation douce.
///
/// Respecte `prefers-reduced-motion` : si les animations sont désactivées
/// (`MediaQuery.disableAnimations`), le bloc reste statique (pas de contrôleur
/// actif). La charte des durées est centralisée au point 7 ; la pulsation ~1 s
/// reste discrète.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  /// Raccourci pour un bloc circulaire (avatars, pastilles).
  const Skeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = 0,
      shape = BoxShape.circle;

  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  bool _animating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion && _animating) {
      _controller.stop();
      _animating = false;
    } else if (!reduceMotion && !_animating) {
      _controller.repeat(reverse: true);
      _animating = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.surfaces.border;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Pulsation d'opacité entre 0.35 et 0.7 ; statique si réduit.
        final t = _animating ? _controller.value : 0.5;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: base.withValues(alpha: 0.35 + 0.35 * t),
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? BorderRadius.circular(widget.borderRadius)
                : null,
          ),
        );
      },
    );
  }
}
