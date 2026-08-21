import 'package:flutter/material.dart';

import 'app_state_view.dart';

/// Écran d'onglet provisoire (M1) : en-tête + état « à venir » centré.
/// Sera remplacé par le vrai contenu au jalon correspondant.
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppStateView.empty(icon: icon, title: title, message: message),
    );
  }
}
