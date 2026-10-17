import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_surfaces.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/category.dart';
import 'category_icons.dart';

/// Horizontal pill selector used by the final Snack catalogue.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        key: const Key('snack_category_selector'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryPill(
              label: loc.catalogueAll,
              icon: categoryIcon(null),
              selected: selectedId == null,
              onTap: () => onSelect(null),
            );
          }

          final category = categories[index - 1];

          return _CategoryPill(
            label: category.name,
            icon: categoryIcon(category.id),
            selected: selectedId == category.id,
            onTap: () => onSelect(category.id),
          );
        },
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.neutral0 : AppColors.navy900;
    final background = selected ? AppColors.pink600 : context.surfaces.surface;

    return Material(
      color: background,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.pink600 : context.surfaces.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 17, color: foreground),
              const SizedBox(width: 7),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
