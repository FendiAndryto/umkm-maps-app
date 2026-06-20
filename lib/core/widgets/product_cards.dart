import 'package:flutter/material.dart';
import 'package:umkm_maps_app/data/models/product_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';

/// Horizontal product card (list row style)
class ProductCardHorizontal extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCardHorizontal({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: AppTheme.roundedMd,
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.surfaceVariant,
              child: _buildImage(),
            ),
          ),
          const SizedBox(width: 14),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.isPromo || product.kategori != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        if (product.isPromo) ...[
                          AppBadge.promo(),
                          const SizedBox(width: 6),
                        ],
                        if (product.kategori != null)
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  product.kategori!.toUpperCase(),
                                  style: AppTheme.labelMd.copyWith(
                                    fontSize: 9,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                Text(
                  product.namaProduk,
                  style: AppTheme.headingSm,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${product.harga}',
                  style: AppTheme.priceMd,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 3),
                    Text(
                      product.totalReviews > 0
                          ? '${product.averageRating} (${product.totalReviews})'
                          : 'Baru',
                      style: AppTheme.bodySm,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (product.fotoProduk != null && product.fotoProduk!.isNotEmpty) {
      return Image.network(
        product.fotoProduk!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : const _ImagePlaceholder(),
        errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(icon: Icons.broken_image_outlined),
      );
    }
    return const _ImagePlaceholder();
  }
}

/// Vertical product card (grid / carousel style)
class ProductCardVertical extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final double? width;

  const ProductCardVertical({
    super.key,
    required this.product,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusLg),
                  ),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColors.surfaceVariant,
                    child: _buildImage(),
                  ),
                ),
                if (product.isPromo)
                  Positioned(
                    top: 8, left: 8,
                    child: AppBadge.promo(),
                  ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.kategori != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.kategori!.toUpperCase(),
                          style: AppTheme.labelMd.copyWith(
                            fontSize: 9,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  Text(
                    product.namaProduk,
                    style: AppTheme.headingSm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text('Rp ${product.harga}', style: AppTheme.priceMd),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 13, color: AppColors.secondary),
                      const SizedBox(width: 3),
                      Text(
                        product.totalReviews > 0
                            ? '${product.averageRating}'
                            : 'Baru',
                        style: AppTheme.bodySm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (product.fotoProduk != null && product.fotoProduk!.isNotEmpty) {
      return Image.network(
        product.fotoProduk!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : const _ImagePlaceholder(),
        errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(icon: Icons.broken_image_outlined),
      );
    }
    return const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final IconData icon;
  const _ImagePlaceholder({this.icon = Icons.fastfood_rounded});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(icon, size: 32, color: AppColors.textTertiary),
    );
  }
}
