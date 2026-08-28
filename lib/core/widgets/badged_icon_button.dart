import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Bouton icône d'AppBar avec **badge numérique** réutilisable (panier, cloche).
///
/// - Badge affiché **uniquement si [count] > 0** — jamais un badge vide ni une
///   simple couleur : le statut est toujours communiqué par un **chiffre**
///   (charte §15, pas de statut par couleur seule).
/// - Léger scale à l'augmentation de [count] (charte, respecte
///   `prefers-reduced-motion`).
/// - [semanticLabel] : annonce lecteur d'écran (ex. « 3 notifications non lues »).
class BadgedIconButton extends StatefulWidget {
  const BadgedIconButton({
    super.key,
    required this.icon,
    required this.count,
    required this.onPressed,
    required this.semanticLabel,
    this.tooltip,
  });

  final IconData icon;
  final int count;
  final VoidCallback onPressed;
  final String semanticLabel;
  final String? tooltip;

  @override
  State<BadgedIconButton> createState() => _BadgedIconButtonState();
}

class _BadgedIconButtonState extends State<BadgedIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.cartAdd,
    lowerBound: 1,
    upperBound: 1.35,
  );

  @override
  void didUpdateWidget(BadgedIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count > oldWidget.count && !AppMotion.reduceMotion(context)) {
      _controller.forward(from: 1).then((_) {
        if (mounted) _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: IconButton(
        onPressed: widget.onPressed,
        tooltip: widget.tooltip,
        icon: ScaleTransition(
          scale: _controller,
          child: ExcludeSemantics(
            child: Badge(
              isLabelVisible: widget.count > 0,
              label: Text('${widget.count}'),
              child: Icon(widget.icon),
            ),
          ),
        ),
      ),
    );
  }
}
