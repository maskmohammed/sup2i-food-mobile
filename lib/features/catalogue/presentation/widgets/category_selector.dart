import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/category.dart';

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
              selected: selectedId == null,
              onSelected: () => onSelect(null),
            );
          }
          final category = categories[index - 1];
          return _Chip(
            label: category.name,
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
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      backgroundColor: AppColors.neutral0,
      selectedColor: AppColors.pink600,
      side: const BorderSide(color: AppColors.border),
      labelStyle: TextStyle(
        color: selected ? AppColors.neutral0 : AppColors.neutral900,
      ),
    );
  }
}
