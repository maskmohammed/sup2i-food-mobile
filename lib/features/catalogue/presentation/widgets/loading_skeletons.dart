import 'package:flutter/material.dart';

import '../../../../core/theme/app_surfaces.dart';
import '../../../../core/widgets/skeleton.dart';

/// Squelette de l'onglet Commander : rangée de catégories + grille de cartes,
/// reproduisant la mise en page réelle pour éviter le saut visuel au chargement.
class CatalogueSkeleton extends StatelessWidget {
  const CatalogueSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // Pastilles de catégories.
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) =>
                Skeleton(width: i == 0 ? 72 : 96, height: 36, borderRadius: 20),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemCount: 6,
            itemBuilder: (_, _) => const _ProductCardSkeleton(),
          ),
        ),
      ],
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaces.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.surfaces.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Skeleton(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 12,
            ),
          ),
          const SizedBox(height: 12),
          const Skeleton(width: double.infinity),
          const SizedBox(height: 8),
          const Skeleton(width: 80),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Skeleton(width: 56, height: 18),
              Skeleton.circle(size: 28),
            ],
          ),
        ],
      ),
    );
  }
}

/// Squelette de l'écran détail produit : image + titre/prix + lignes + bouton.
class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const AspectRatio(
          aspectRatio: 1.5,
          child: Skeleton(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Expanded(child: Skeleton(height: 24)),
                  SizedBox(width: 16),
                  Skeleton(width: 72, height: 24),
                ],
              ),
              SizedBox(height: 16),
              Skeleton(width: double.infinity),
              SizedBox(height: 8),
              Skeleton(width: 220),
              SizedBox(height: 24),
              Skeleton(width: 140, height: 48, borderRadius: 24),
              SizedBox(height: 32),
              Skeleton(width: double.infinity, height: 52, borderRadius: 12),
            ],
          ),
        ),
      ],
    );
  }
}
