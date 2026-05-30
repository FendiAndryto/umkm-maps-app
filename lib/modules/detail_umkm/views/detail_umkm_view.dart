import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:umkm_maps_app/core/theme/app_colors.dart';
import 'package:umkm_maps_app/core/theme/app_theme.dart';
import 'package:umkm_maps_app/core/widgets/app_button.dart';
import 'package:umkm_maps_app/core/widgets/app_card.dart';
import 'package:umkm_maps_app/core/widgets/app_text_field.dart';
import 'package:umkm_maps_app/modules/detail_umkm/controllers/detail_umkm_controller.dart';

class DetailUmkmView extends StatelessWidget {
  const DetailUmkmView({super.key});

  @override
  Widget build(BuildContext context) {
    final String? productId = Get.arguments?.toString();
    final controller = Get.put(DetailUmkmController(), tag: productId);

    final commentNameCtrl = TextEditingController();
    final commentBodyCtrl = TextEditingController();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) Get.delete<DetailUmkmController>(tag: productId);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (controller.productData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Text('Produk tidak ditemukan',
                      style: AppTheme.headingSm
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          final product = controller.productData;
          final umkm = controller.umkmData;

          return CustomScrollView(
            slivers: [
              // ── Hero image with back button ───────────────
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      Get.delete<DetailUmkmController>(tag: productId);
                      Get.back();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.shadowSm,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: AppColors.textPrimary),
                    ),
                  ),
                ),
                title: Text('Detail Jajanan', style: AppTheme.headingSm),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.surfaceVariant,
                    child: (product['foto_produk'] != null &&
                            product['foto_produk'].toString().isNotEmpty)
                        ? Image.network(
                            product['foto_produk'],
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : const Center(
                                        child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                            strokeWidth: 2)),
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.broken_image_outlined,
                                  size: 64, color: AppColors.textTertiary),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.fastfood_rounded,
                                size: 80, color: AppColors.textTertiary),
                          ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Product name & price ────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product['nama_produk'] ?? 'Produk',
                              style: AppTheme.headingLg,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Rp ${product['harga']}',
                            style: AppTheme.priceLg,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Rating summary
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.warningSurface,
                          borderRadius: AppTheme.roundedMd,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppColors.secondary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              controller.reviews.isNotEmpty
                                  ? '${(controller.reviews.map((e) => (e['rating'] as num)).reduce((a, b) => a + b) / controller.reviews.length).toStringAsFixed(1)} · ${controller.reviews.length} ulasan'
                                  : 'Belum ada ulasan',
                              style: AppTheme.labelMd.copyWith(
                                  color: AppColors.warning, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        product['deskripsi'] ??
                            'Belum ada deskripsi untuk menu ini.',
                        style: AppTheme.bodyLg
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      const Divider(),
                      const SizedBox(height: 20),

                      // ── Sold By card ────────────────────────
                      Text('Dijual Oleh', style: AppTheme.headingSm),
                      const SizedBox(height: 12),
                      AppCard(
                        onTap: () =>
                            Get.toNamed('/profile-umkm', arguments: umkm['id']),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primarySurface,
                                image: (umkm['foto_profil'] != null &&
                                        umkm['foto_profil']
                                            .toString()
                                            .isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            umkm['foto_profil']),
                                        fit: BoxFit.cover)
                                    : null,
                              ),
                              child: (umkm['foto_profil'] == null ||
                                      umkm['foto_profil']
                                          .toString()
                                          .isEmpty)
                                  ? const Icon(Icons.storefront_rounded,
                                      size: 24, color: AppColors.primary)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    umkm['nama_toko'] ?? 'Warung',
                                    style: AppTheme.headingSm,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    umkm['deskripsi'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.bodySm,
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(() => Row(
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          color: AppColors.secondary,
                                          size: 13),
                                      const SizedBox(width: 3),
                                      Text(
                                        controller.storeTotalReviews.value > 0
                                            ? '${controller.storeAverageRating.value} (${controller.storeTotalReviews.value})'
                                            : 'Warung Baru',
                                        style: AppTheme.bodySm,
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textTertiary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Action Buttons ──────────────────────
                      Row(
                        children: [
                          if (umkm['no_telepon'] != null &&
                              umkm['no_telepon'].toString().isNotEmpty) ...[
                            Expanded(
                              child: AppButton(
                                label: 'WhatsApp',
                                variant: AppButtonVariant.primary,
                                prefixIcon: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 16,
                                    color: Colors.white),
                                onPressed: () => controller.openWhatsApp(),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: AppButton(
                              label: 'Petunjuk Arah',
                              variant: AppButtonVariant.outline,
                              prefixIcon: const Icon(Icons.map_outlined,
                                  size: 16, color: AppColors.primary),
                              onPressed: () => controller.openGoogleMaps(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Divider
                      const Divider(),
                      const SizedBox(height: 20),

                      // ── Reviews section ─────────────────────
                      Text('Ulasan Pembeli ⭐', style: AppTheme.headingSm),
                      const SizedBox(height: 16),

                      // Review form
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Tulis Ulasanmu',
                                style: AppTheme.labelLg),
                            const SizedBox(height: 12),

                            // Star selector
                            Obx(() => Row(
                              children: List.generate(5, (i) {
                                final v = i + 1;
                                return GestureDetector(
                                  onTap: () =>
                                      controller.selectedStars.value = v,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      controller.selectedStars.value >= v
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      color: AppColors.secondary,
                                      size: 32,
                                    ),
                                  ),
                                );
                              }),
                            )),
                            const SizedBox(height: 14),

                            AppTextField(
                              controller: commentNameCtrl,
                              label: 'Nama (opsional)',
                              hint: 'Anonim',
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 12),

                            AppTextField(
                              controller: commentBodyCtrl,
                              label: 'Komentar',
                              hint: 'Jajanannya mantap, porsi besar...',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),

                            AppButton(
                              label: 'Kirim Ulasan',
                              size: AppButtonSize.sm,
                              fullWidth: false,
                              onPressed: () {
                                controller.submitReview(
                                  controller.selectedStars.value,
                                  commentBodyCtrl.text,
                                  commentNameCtrl.text,
                                );
                                commentBodyCtrl.clear();
                                commentNameCtrl.clear();
                                controller.selectedStars.value = 5;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Review list
                      Obx(() {
                        if (controller.reviews.isEmpty) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.rate_review_outlined,
                                      size: 48, color: AppColors.textTertiary),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada ulasan. Jadilah yang pertama!',
                                    textAlign: TextAlign.center,
                                    style: AppTheme.bodySm,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.reviews.length,
                          itemBuilder: (_, i) {
                            final rev = controller.reviews[i];
                            final name = rev['username'] ?? 'Anonim';
                            final comment = rev['komentar'] ?? '';
                            final rating = rev['rating'] ?? 5;
                            final dateStr = rev['created_at'] != null
                                ? DateTime.parse(rev['created_at'])
                                    .toLocal()
                                    .toString()
                                    .substring(0, 10)
                                : '';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AppCard(
                                hasShadow: false,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: AppColors.primarySurface,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              name.isNotEmpty
                                                  ? name[0].toUpperCase()
                                                  : 'A',
                                              style: AppTheme.labelLg
                                                  .copyWith(
                                                      color: AppColors.primary),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(name,
                                                  style: AppTheme.labelLg),
                                              Text(dateStr,
                                                  style: AppTheme.bodySm),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children:
                                              List.generate(5, (si) {
                                            return Icon(
                                              rating > si
                                                  ? Icons.star_rounded
                                                  : Icons.star_border_rounded,
                                              color: AppColors.secondary,
                                              size: 14,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    if (comment.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        comment,
                                        style: AppTheme.bodyMd.copyWith(
                                            color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
