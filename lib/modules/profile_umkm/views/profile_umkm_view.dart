import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:umkm_maps_app/core/theme/app_colors.dart';
import 'package:umkm_maps_app/core/theme/app_theme.dart';
import 'package:umkm_maps_app/core/widgets/app_button.dart';
import 'package:umkm_maps_app/core/widgets/app_card.dart';
import 'package:umkm_maps_app/core/widgets/product_cards.dart';
import 'package:umkm_maps_app/modules/profile_umkm/controllers/profile_umkm_controller.dart';

class ProfileUmkmView extends GetView<ProfileUmkmController> {
  const ProfileUmkmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        final toko = controller.umkmData;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── AppBar ──────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              title: const Text('Profil Warung'),
            ),

            // ── Profile header card ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: AppCard(
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primarySurface,
                          border: Border.all(
                              color: AppColors.border, width: 2),
                          image: (toko['foto_profil'] != null &&
                                  toko['foto_profil']
                                      .toString()
                                      .isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(toko['foto_profil']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (toko['foto_profil'] == null ||
                                toko['foto_profil'].toString().isEmpty)
                            ? const Icon(Icons.storefront_rounded,
                                size: 40, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Verified badge
                      if (toko['status_verifikasi'] == 'approved') ...[
                        AppBadge.approved(),
                        const SizedBox(height: 8),
                      ],

                      // Store name
                      Text(
                        toko['nama_toko'] ?? 'Warung',
                        style: AppTheme.headingLg,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),

                      // Description
                      Text(
                        toko['deskripsi'] ?? '',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyMd
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),

                      // Rating
                      Obx(() => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.warningSurface,
                              borderRadius: AppTheme.roundedFull,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: AppColors.secondary, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  controller.storeTotalReviews.value > 0
                                      ? '${controller.storeAverageRating.value} · ${controller.storeTotalReviews.value} ulasan'
                                      : 'Warung Baru',
                                  style: AppTheme.labelMd.copyWith(
                                      color: AppColors.warning,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          )),

                      // Action buttons: WhatsApp & Petunjuk Arah
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (toko['no_telepon'] != null &&
                              toko['no_telepon'].toString().isNotEmpty) ...[
                            Expanded(
                              child: AppButton(
                                label: 'Chat WhatsApp',
                                variant: AppButtonVariant.secondary,
                                prefixIcon: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 16,
                                    color: AppColors.primary),
                                onPressed: () => controller.openWhatsApp(),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: AppButton(
                              label: 'Petunjuk Arah',
                              variant: AppButtonVariant.outline,
                              prefixIcon: const Icon(
                                  Icons.map_outlined,
                                  size: 16,
                                  color: AppColors.primary),
                              onPressed: () => controller.openGoogleMaps(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Product section header ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: SectionHeader(
                  title: 'Semua Menu',
                  actionLabel: '${controller.storeProducts.length} item',
                ),
              ),
            ),

            // ── Product grid ───────────────────────────────────
            controller.storeProducts.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(Icons.shopping_basket_outlined,
                              size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          Text('Belum ada menu tersedia',
                              style: AppTheme.bodySm),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final p = controller.storeProducts[i];
                          return ProductCardVertical(
                            product: p,
                            onTap: () =>
                                Get.toNamed('/detail-umkm', arguments: p.id),
                          );
                        },
                        childCount: controller.storeProducts.length,
                      ),
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }),
    );
  }
}
