import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_surfaces.dart';
import '../../data/product_photo_service.dart';

/// Image d'un produit : photo réseau si disponible, sinon placeholder.
///
/// ⚠️ Les photos proviennent d'Unsplash et sont **temporaires, pour le
/// développement uniquement** (elles ne représentent pas le plat réellement
/// servi). Sans clé `UNSPLASH_ACCESS_KEY` (cas par défaut, tests/CI), le service
/// retourne `null` et seul le placeholder s'affiche. Voir
/// docs/design/decisions.md (D9) et [UnsplashPhotoService].
class ProductImage extends StatefulWidget {
  const ProductImage({
    super.key,
    required this.query,
    this.iconSize = 36,
    this.service,
  });

  final String query;
  final double iconSize;
  final ProductPhotoService? service;

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  late Future<String?> _future;

  @override
  void initState() {
    super.initState();
    final service = widget.service ?? defaultProductPhotoService;
    _future = service.photoUrl(widget.query);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _future,
      builder: (context, snapshot) {
        final url = snapshot.data;
        if (url == null) return _placeholder(context);
        // ⚠️ Photo de DÉVELOPPEMENT (Unsplash) — à remplacer par la vraie photo
        // produit avant production (cf. D9). Ne jamais shipper telle quelle.
        return Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : _placeholder(context),
          errorBuilder: (context, error, stack) => _placeholder(context),
        );
      },
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: context.surfaces.background,
      child: Icon(
        Icons.restaurant_menu,
        color: AppColors.muted,
        size: widget.iconSize,
      ),
    );
  }
}
