import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_surfaces.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/category.dart';
import 'category_icons.dart';

/// Rangée horizontale de chips catégories (avec « Tous » en tête).
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Category> categories;
  final String? selectedId; // null = « Tous »
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Chip(
              label: loc.catalogueAll,
              icon: categoryIcon(null),
              selected: selectedId == null,
              onSelected: () => onSelect(null),
            );
          }
          final category = categories[index - 1];
          return _Chip(
            label: category.name,
            icon: categoryIcon(category.id),
            selected: selectedId == category.id,
            onSelected: () => onSelect(category.id),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    // Couleur d'ÉTAT (charte §22) : pink600 actif, muted inactif — jamais une
    // couleur par catégorie.
    final Color stateColor = selected ? AppColors.pink600 : AppColors.muted;

    return ChoiceChip(
      avatar: Icon(icon, size: 18, color: stateColor),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      backgroundColor: context.surfaces.surface,
      selectedColor: AppColors.pink600.withValues(alpha: 0.12),
      side: BorderSide(
        color: selected ? AppColors.pink600 : context.surfaces.border,
      ),
      labelStyle: TextStyle(
        color: selected ? AppColors.pink600 : context.surfaces.text,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}
