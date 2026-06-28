import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:umkm_maps_app/core/theme/app_colors.dart';
import 'package:umkm_maps_app/core/theme/app_theme.dart';
import 'package:umkm_maps_app/core/widgets/app_button.dart';
import 'package:umkm_maps_app/core/widgets/app_card.dart';
import 'package:umkm_maps_app/data/models/product_model.dart';
import 'package:umkm_maps_app/modules/umkm/dashboard/controllers/dashboard_controller.dart';
import 'package:umkm_maps_app/modules/umkm/widgets/admin_whatsapp_button.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() {
          switch (controller.currentTabIndex.value) {
            case 0:
              return const Text('Beranda');
            case 1:
              return const Text('Menu Jualan');
            case 2:
              return const Text('Profil Warung');
            default:
              return const Text('Dashboard');
          }
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20),
            onPressed: () => controller.logout(),
            tooltip: 'Keluar',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return _buildSkeleton();

        if (controller.statusVerifikasi.value != 'approved') {
          return _buildPendingOrRejected(controller.statusVerifikasi.value);
        }

        switch (controller.currentTabIndex.value) {
          case 0:
            return _buildBerandaTab(context);
          case 1:
            return _buildProdukTab(context);
          case 2:
            return _buildAkunTab(context);
          default:
            return _buildBerandaTab(context);
        }
      }),
      bottomNavigationBar: Obx(() => controller.statusVerifikasi.value == 'approved'
          ? BottomNavigationBar(
              currentIndex: controller.currentTabIndex.value,
              onTap: (index) => controller.currentTabIndex.value = index,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              backgroundColor: AppColors.surface,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: AppTheme.labelMd.copyWith(color: AppColors.primary),
              unselectedLabelStyle: AppTheme.labelMd.copyWith(color: AppColors.textSecondary),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard_rounded),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2_rounded),
                  label: 'Produk',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Akun',
                ),
              ],
            )
          : const SizedBox.shrink()),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Obx(() => controller.statusVerifikasi.value == 'approved' &&
                  controller.currentTabIndex.value == 1
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: FloatingActionButton(
                    heroTag: 'add_product_btn',
                    onPressed: () => Get.toNamed('/add-product'),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 3,
                    tooltip: 'Tambah Menu',
                    child: const Icon(Icons.add_rounded, size: 28),
                  ),
                )
              : const SizedBox.shrink()),
          const AdminWhatsAppButton(),
        ],
      ),
    );
  }

  // ── Profile Header ────────────────────────────────────────────
  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppTheme.roundedXl,
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primarySurface,
                  border: Border.all(color: AppColors.border, width: 2),
                  image: controller.fotoProfil.value.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(controller.fotoProfil.value),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: controller.fotoProfil.value.isEmpty
                    ? const Icon(Icons.storefront_rounded,
                        size: 32, color: AppColors.primary)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => controller.uploadFotoProfil(),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.namaWarung.value,
                  style: AppTheme.headingMd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  controller.deskripsiWarung.value,
                  style: AppTheme.bodyMd
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (controller.noTelepon.value.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 13, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        controller.noTelepon.value,
                        style: AppTheme.bodySm,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

        ],
      ),
    );
  }

  // ── Stats Bar ─────────────────────────────────────────────────
  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppTheme.roundedLg,
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.inventory_2_outlined,
            label: 'Total Menu',
            value: '${controller.myProducts.length}',
          ),
          Container(width: 1, height: 36, color: AppColors.primary.withValues(alpha: 0.2)),
          _StatItem(
            icon: Icons.verified_outlined,
            label: 'Status',
            value: 'Aktif',
            valueColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  // ── Product grid card ─────────────────────────────────────────
  Widget _buildProductGridCard(ProductModel p) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusLg),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: AppColors.surfaceVariant,
                    child: p.fotoProduk != null
                        ? Image.network(p.fotoProduk!, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.fastfood_rounded,
                                  color: AppColors.textTertiary),
                            ))
                        : const Center(
                            child: Icon(Icons.fastfood_rounded,
                                color: AppColors.textTertiary)),
                  ),
                ),
                if (p.isPromo)
                  Positioned(
                    top: 8, left: 8,
                    child: AppBadge.promo(),
                  ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.namaProduk,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.headingSm.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Text('Rp ${p.harga}', style: AppTheme.priceMd.copyWith(fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.secondary, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      p.totalReviews > 0
                          ? '${p.averageRating} (${p.totalReviews})'
                          : 'Baru',
                      style: AppTheme.bodySm.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () => Get.toNamed('/edit-product', arguments: p),
                      child: const Icon(Icons.edit_outlined,
                          color: AppColors.info, size: 18),
                    ),
                    Container(width: 1, height: 16, color: AppColors.border),
                    GestureDetector(
                      onTap: () => _confirmDelete(p, controller),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty products ────────────────────────────────────────────
  Widget _buildEmptyProducts() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppTheme.roundedXl,
            ),
            child: const Icon(Icons.add_shopping_cart_rounded,
                size: 36, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),
          Text('Belum ada menu',
              style: AppTheme.headingSm
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            'Tambahkan menu jualanmu menggunakan tombol di bawah',
            textAlign: TextAlign.center,
            style: AppTheme.bodySm,
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Tambah Menu',
            prefixIcon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            fullWidth: false,
            onPressed: () => Get.toNamed('/add-product'),
          ),
        ],
      ),
    );
  }

  // ── Pending / Rejected state ─────────────────────────────────
  Widget _buildPendingOrRejected(String status) {
    final isPending = status == 'pending';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isPending ? AppColors.warningSurface : AppColors.errorSurface,
                borderRadius: AppTheme.roundedXl,
              ),
              child: Icon(
                isPending ? Icons.hourglass_top_rounded : Icons.cancel_outlined,
                size: 48,
                color: isPending ? AppColors.warning : AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPending ? 'Menunggu Verifikasi' : 'Pendaftaran Ditolak',
              style: AppTheme.headingMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isPending
                  ? 'Dokumen kamu sedang diperiksa admin. Mohon tunggu ya!'
                  : 'Dokumen tidak valid. Hubungi admin untuk info lebih lanjut.',
              style: AppTheme.bodyMd.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Skeleton loading ──────────────────────────────────────────
  Widget _buildSkeleton() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile card skeleton
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppTheme.roundedXl,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const AppSkeleton(width: 72, height: 72, borderRadius: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AppSkeleton(height: 18),
                      SizedBox(height: 8),
                      AppSkeleton(height: 14, width: 180),
                      SizedBox(height: 8),
                      AppSkeleton(height: 12, width: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const AppSkeleton(height: 60),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => const AppSkeleton(),
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Beranda ────────────────────────────────────────────
  Widget _buildBerandaTab(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Welcome Banner for Merchant
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppTheme.roundedXl,
                boxShadow: AppColors.shadowMd,
              ),
              child: Row(
                children: [
                  // Profile picture / avatar inside banner
                  Obx(() => Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.25),
                          border: Border.all(color: Colors.white, width: 2),
                          image: controller.fotoProfil.value.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(controller.fotoProfil.value),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: controller.fotoProfil.value.isEmpty
                            ? const Icon(Icons.storefront_rounded, size: 28, color: Colors.white)
                            : null,
                      )),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Halo, ',
                              style: AppTheme.headingSm.copyWith(color: Colors.white, fontSize: 18),
                            ),
                            Expanded(
                              child: Obx(() => Text(
                                    controller.namaWarung.value,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.headingSm.copyWith(
                                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  )),
                            ),
                            const Text(' 👋', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola komentar, ulasan pembeli, dan respon menu warungmu di sini.',
                          style: AppTheme.bodySm.copyWith(color: Colors.white.withValues(alpha: 0.85), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: SectionHeader(
              title: 'Ulasan Terbaru',
              actionLabel: controller.latestReviews.isEmpty ? null : '${controller.latestReviews.length} ulasan',
            ),
          ),
        ),

        // Reviews list
        Obx(() {
          if (controller.latestReviews.isEmpty) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppTheme.roundedXl,
                        ),
                        child: const Icon(Icons.rate_review_outlined,
                            size: 32, color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: 16),
                      Text('Belum ada ulasan', style: AppTheme.headingSm),
                      const SizedBox(height: 6),
                      Text(
                        'Ulasan dari pembeli akan muncul di sini jika ada menu yang diberi rating.',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodySm,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final rev = controller.latestReviews[i];
                  final reviewId = rev['id'].toString();
                  final name = rev['username'] ?? 'Anonim';
                  final comment = rev['komentar'] ?? '';
                  final rating = rev['rating'] ?? 5;
                  final dateStr = rev['created_at'] != null
                      ? DateTime.parse(rev['created_at'])
                          .toLocal()
                          .toString()
                          .substring(0, 10)
                      : '';
                  final productName = rev['products']?['nama_produk'] ?? 'Menu Jajanan';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: AppColors.primarySurface,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'A',
                                    style: AppTheme.labelLg.copyWith(color: AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: AppTheme.labelLg),
                                    Text(dateStr, style: AppTheme.bodySm),
                                  ],
                                ),
                              ),
                              Row(
                                children: List.generate(5, (si) {
                                  return Icon(
                                    rating > si ? Icons.star_rounded : Icons.star_border_rounded,
                                    color: AppColors.secondary,
                                    size: 14,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Target product tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: AppTheme.roundedMd,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.fastfood_outlined, size: 12, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  productName,
                                  style: AppTheme.bodySm.copyWith(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          if (comment.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              comment,
                              style: AppTheme.bodyMd.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _confirmDeleteReview(context, reviewId, name),
                              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                              label: Text('Hapus Komentar', style: AppTheme.labelMd.copyWith(color: AppColors.error, fontSize: 12)),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: controller.latestReviews.length,
              ),
            ),
          );
        }),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  void _confirmDeleteReview(BuildContext context, String reviewId, String reviewerName) {
    Get.defaultDialog(
      title: '',
      content: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(
              color: AppColors.errorSurface,
              borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusLg)),
            ),
            child: const Icon(Icons.delete_outline_rounded, size: 28, color: AppColors.error),
          ),
          const SizedBox(height: 16),
          Text('Hapus Komentar?', style: AppTheme.headingSm),
          const SizedBox(height: 8),
          Text(
            'Komentar dari "$reviewerName" akan dihapus permanen dari sistem.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMd.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      cancelTextColor: AppColors.textSecondary,
      onConfirm: () {
        Get.back();
        controller.deleteReview(reviewId);
      },
    );
  }

  // ── Tab 2: Produk ─────────────────────────────────────────────
  Widget _buildProdukTab(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildProfileHeader(context)),
        SliverToBoxAdapter(child: _buildStatsBar()),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: SectionHeader(
              title: 'Menu Jualan',
              actionLabel: controller.myProducts.isEmpty ? null : '${controller.myProducts.length} item',
            ),
          ),
        ),

        Obx(() => controller.myProducts.isEmpty
            ? SliverToBoxAdapter(child: _buildEmptyProducts())
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildProductGridCard(controller.myProducts[i]),
                    childCount: controller.myProducts.length,
                  ),
                ),
              )),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ── Tab 3: Akun ───────────────────────────────────────────────
  Widget _buildAkunTab(BuildContext context) {
    final nameCtrl  = TextEditingController(text: controller.namaWarung.value);
    final descCtrl  = TextEditingController(text: controller.deskripsiWarung.value);
    final phoneCtrl = TextEditingController(text: controller.noTelepon.value);
    final latCtrl   = TextEditingController(text: controller.latitude.value.toString());
    final lngCtrl   = TextEditingController(text: controller.longitude.value.toString());

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar Card
          AppCard(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Obx(() => Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primarySurface,
                            border: Border.all(color: AppColors.border, width: 2),
                            image: controller.fotoProfil.value.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(controller.fotoProfil.value),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: controller.fotoProfil.value.isEmpty
                              ? const Icon(Icons.storefront_rounded, size: 40, color: AppColors.primary)
                              : null,
                        )),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => controller.uploadFotoProfil(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 2),
                            boxShadow: AppColors.shadowSm,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() => Text(
                      controller.namaWarung.value,
                      style: AppTheme.headingLg,
                      textAlign: TextAlign.center,
                    )),
                const SizedBox(height: 4),
                Obx(() => Text(
                      controller.statusVerifikasi.value == 'approved' ? 'Warung Terverifikasi' : 'Status: ${controller.statusVerifikasi.value}',
                      style: AppTheme.labelMd.copyWith(
                        color: controller.statusVerifikasi.value == 'approved' ? AppColors.success : AppColors.warning,
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Fields Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Informasi Warung', style: AppTheme.headingSm),
                const SizedBox(height: 16),
                _SheetField(
                  label: 'Nama Warung',
                  ctrl: nameCtrl,
                  icon: Icons.storefront_outlined,
                ),
                const SizedBox(height: 14),
                _SheetField(
                  label: 'Deskripsi',
                  ctrl: descCtrl,
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                _SheetField(
                  label: 'Nomor Telepon WhatsApp',
                  ctrl: phoneCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // GPS Coordinates Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Lokasi Maps', style: AppTheme.headingSm),
                    TextButton.icon(
                      onPressed: () async {
                        await controller.getCurrentLocation();
                        latCtrl.text = controller.latitude.value.toString();
                        lngCtrl.text = controller.longitude.value.toString();
                      },
                      icon: const Icon(Icons.my_location_rounded, size: 14),
                      label: Text('GPS', style: AppTheme.labelMd.copyWith(color: AppColors.textOnPrimary, fontSize: 13)),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.roundedMd,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() => Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            controller.alamatWarung.value,
                            style: AppTheme.bodySm.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SheetField(
                        label: 'Latitude',
                        ctrl: latCtrl,
                        icon: Icons.south_rounded,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SheetField(
                        label: 'Longitude',
                        ctrl: lngCtrl,
                        icon: Icons.east_rounded,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          Obx(() => AppButton(
                label: 'Simpan Perubahan',
                isLoading: controller.isLoading.value,
                onPressed: () {
                  final lat = double.tryParse(latCtrl.text) ?? controller.latitude.value;
                  final lng = double.tryParse(lngCtrl.text) ?? controller.longitude.value;
                  controller.updateProfile(
                    nama: nameCtrl.text,
                    deskripsi: descCtrl.text,
                    phone: phoneCtrl.text,
                    lat: lat,
                    lng: lng,
                  );
                },
              )),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmDelete(ProductModel p, DashboardController ctrl) {
    Get.defaultDialog(
      title: '',
      content: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.errorSurface,
              borderRadius: AppTheme.roundedLg,
            ),
            child: const Icon(Icons.delete_outline_rounded,
                size: 28, color: AppColors.error),
          ),
          const SizedBox(height: 16),
          Text('Hapus Menu?', style: AppTheme.headingSm),
          const SizedBox(height: 8),
          Text('${p.namaProduk} akan dihapus permanen.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMd.copyWith(color: AppColors.textSecondary)),
        ],
      ),
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      cancelTextColor: AppColors.textSecondary,
      onConfirm: () {
        Get.back();
        ctrl.hapusDagangan(p.id);
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTheme.headingSm.copyWith(
                      color: valueColor ?? AppColors.primaryDark)),
              Text(label, style: AppTheme.bodySm),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData? icon;
  final TextInputType keyboardType;
  final int maxLines;

  const _SheetField({
    required this.label,
    required this.ctrl,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelMd),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTheme.bodyMd,
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 16, color: AppColors.primary)
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppTheme.roundedMd,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppTheme.roundedMd,
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
