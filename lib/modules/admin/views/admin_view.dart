import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:umkm_maps_app/core/theme/app_colors.dart';
import 'package:umkm_maps_app/core/theme/app_theme.dart';
import 'package:umkm_maps_app/core/widgets/app_button.dart';
import 'package:umkm_maps_app/core/widgets/app_card.dart';
import 'package:umkm_maps_app/modules/admin/controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() {
          switch (controller.currentTabIndex.value) {
            case 0:
              return const Text('Admin Dashboard');
            case 1:
              return const Text('Kelola Kategori');
            case 2:
              return const Text('Persetujuan Warung');
            default:
              return const Text('Admin Dashboard');
          }
        }),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20),
            onPressed: () => controller.logout(),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        switch (controller.currentTabIndex.value) {
          case 0:
            return _buildBerandaTab(context);
          case 1:
            return _buildCategoryManager(context, controller);
          case 2:
            return _buildManageUmkmTab(context);
          default:
            return _buildBerandaTab(context);
        }
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
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
                icon: Icon(Icons.category_outlined),
                activeIcon: Icon(Icons.category_rounded),
                label: 'Kategori',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.storefront_outlined),
                activeIcon: Icon(Icons.storefront_rounded),
                label: 'UMKM',
              ),
            ],
          )),
    );
  }

  Widget _buildUmkmList(
    BuildContext context,
    RxList list, {
    required Color statusColor,
    required bool isActionable,
  }) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined,
                  size: 56, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text('Tidak ada data',
                  style: AppTheme.bodyMd
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final data = list[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              onTap: () => isActionable
                  ? _showDetailDialog(context, controller, data)
                  : Get.toNamed('/profile-umkm', arguments: data['id']),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isActionable
                          ? Icons.storefront_outlined
                          : Icons.visibility_outlined,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['nama_toko'] ?? 'Tanpa Nama',
                            style: AppTheme.headingSm),
                        const SizedBox(height: 2),
                        Text(
                          data['profiles']?['email'] ?? '-',
                          style: AppTheme.bodySm,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: AppTheme.roundedFull,
                    ),
                    child: Text(
                      data['status_verifikasi'] ?? '-',
                      style: AppTheme.labelMd
                          .copyWith(color: statusColor, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textTertiary, size: 18),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCategoryManager(
      BuildContext context, AdminController controller) {
    final newCatCtrl = TextEditingController();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add category card
            AppCard(
              hasShadow: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: newCatCtrl,
                      style: AppTheme.bodyMd,
                      decoration: InputDecoration(
                        hintText: 'Nama kategori baru…',
                        prefixIcon: const Icon(Icons.category_outlined,
                            size: 18),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppTheme.roundedMd,
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppTheme.roundedMd,
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    label: 'Tambah',
                    fullWidth: false,
                    size: AppButtonSize.sm,
                    prefixIcon: const Icon(Icons.add_rounded,
                        size: 16, color: Colors.white),
                    onPressed: () {
                      if (newCatCtrl.text.trim().isNotEmpty) {
                        controller.addCategory(newCatCtrl.text);
                        newCatCtrl.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Kategori Aktif',
                style:
                    AppTheme.headingSm.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Expanded(
              child: controller.categoriesList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.category_outlined,
                              size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 8),
                          Text('Belum ada kategori',
                              style: AppTheme.bodySm),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: controller.categoriesList.length,
                      itemBuilder: (_, i) {
                        final cat = controller.categoriesList[i];
                        final catId = cat['id'];
                        final catName = cat['name'] as String;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            hasShadow: false,
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: AppTheme.roundedMd,
                                  ),
                                  child: const Icon(
                                    Icons.label_outline_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(catName, style: AppTheme.labelLg),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      color: AppColors.info, size: 18),
                                  onPressed: () => _showEditCategoryDialog(
                                      context, controller, catId, catName),
                                  visualDensity: VisualDensity.compact,
                                ),
                                if (catName != 'Lainnya')
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded,
                                        color: AppColors.error, size: 18),
                                    onPressed: () => _confirmDeleteCategory(
                                        context, controller, catId, catName),
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  void _showDetailDialog(
      BuildContext context, AdminController controller, Map data) async {
    final suratUrl = await controller.getSuratUrl(data['surat_izin_url']);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedXl),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(data['nama_toko'] ?? '-',
                        style: AppTheme.headingMd),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.roundedMd),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _infoRow(
                  'Status', data['status_verifikasi']?.toString() ?? '-'),
              _infoRow('Email', data['profiles']?['email'] ?? '-'),
              const SizedBox(height: 16),
              Text('Dokumen Legalitas', style: AppTheme.labelLg),
              const SizedBox(height: 8),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppTheme.roundedLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: AppTheme.roundedLg,
                  child: suratUrl.isEmpty
                      ? Center(
                          child: Text('Tidak ada dokumen',
                              style: AppTheme.bodySm))
                      : Image.network(suratUrl, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image_outlined,
                                color: AppColors.textTertiary),
                          )),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (data['status_verifikasi'] != 'rejected')
                    Expanded(
                      child: AppButton(
                        label: 'Tolak',
                        variant: AppButtonVariant.danger,
                        size: AppButtonSize.sm,
                        onPressed: () {
                          controller.eksekusiWarung(data['id'], 'rejected');
                          Get.back();
                        },
                      ),
                    ),
                  if (data['status_verifikasi'] != 'rejected')
                    const SizedBox(width: 12),
                  if (data['status_verifikasi'] != 'approved')
                    Expanded(
                      child: AppButton(
                        label: 'Setujui',
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.sm,
                        onPressed: () {
                          controller.eksekusiWarung(data['id'], 'approved');
                          Get.back();
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, AdminController controller,
      String id, String oldName) {
    final editCtrl = TextEditingController(text: oldName);
    Get.defaultDialog(
      title: 'Edit Kategori',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: editCtrl,
          decoration: const InputDecoration(labelText: 'Nama Baru'),
        ),
      ),
      textConfirm: 'Simpan',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        if (editCtrl.text.trim().isNotEmpty) {
          controller.updateCategory(id, oldName, editCtrl.text);
          Get.back();
        }
      },
    );
  }

  void _confirmDeleteCategory(BuildContext context, AdminController controller,
      String id, String name) {
    Get.defaultDialog(
      title: 'Hapus Kategori?',
      middleText:
          'Yakin hapus "$name"? Produk terkait akan dipindah ke "Lainnya".',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        controller.deleteCategory(id, name);
        Get.back();
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: AppTheme.labelMd),
          Text(value,
              style: AppTheme.bodyMd.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ── Tab 1: Beranda ────────────────────────────────────────────
  Widget _buildBerandaTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Banner
          Container(
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
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang, Admin!',
                        style: AppTheme.headingSm.copyWith(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kelola data warung, verifikasi permohonan, dan kelola kategori jajanan kota dengan lancar.',
                        style: AppTheme.bodySm.copyWith(color: Colors.white.withValues(alpha: 0.85), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Ikhtisar Statistik', style: AppTheme.headingSm),
          const SizedBox(height: 12),

          // Stats Layout
          Obx(() {
            final pendingCount = controller.pendingUmkm.length;
            final approvedCount = controller.approvedUmkm.length;
            final rejectedCount = controller.rejectedUmkm.length;
            final totalCount = controller.totalUmkm.value;
            final catCount = controller.categoriesList.length;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total UMKM',
                        value: '$totalCount',
                        subtitle: 'warung terdaftar',
                        icon: Icons.storefront_rounded,
                        color: AppColors.primary,
                        backgroundColor: AppColors.primarySurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Antrean Pending',
                        value: '$pendingCount',
                        subtitle: 'butuh verifikasi',
                        icon: Icons.hourglass_top_rounded,
                        color: AppColors.warning,
                        backgroundColor: AppColors.warningSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Warung Aktif',
                        value: '$approvedCount',
                        subtitle: 'telah disetujui',
                        icon: Icons.verified_rounded,
                        color: AppColors.success,
                        backgroundColor: AppColors.successSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Ditolak',
                        value: '$rejectedCount',
                        subtitle: 'berkas tidak valid',
                        icon: Icons.cancel_rounded,
                        color: AppColors.error,
                        backgroundColor: AppColors.errorSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildStatCardFull(
                  title: 'Kategori Menu',
                  value: '$catCount Kategori',
                  subtitle: 'Kategori menu jualan aktif kota',
                  icon: Icons.category_rounded,
                  color: AppColors.info,
                  backgroundColor: AppColors.infoSurface,
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // Quick actions
          Text('Aksi Cepat', style: AppTheme.headingSm),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Verifikasi',
                  subtitle: 'Periksa dokumen UMKM',
                  icon: Icons.verified_user_rounded,
                  onTap: () => controller.currentTabIndex.value = 2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Kategori',
                  subtitle: 'Edit daftar kategori',
                  icon: Icons.grid_view_rounded,
                  onTap: () => controller.currentTabIndex.value = 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.labelMd.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: AppTheme.roundedMd,
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: AppTheme.headingLg.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTheme.bodySm.copyWith(color: AppColors.textTertiary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardFull({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: AppTheme.roundedLg,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.labelLg.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(value, style: AppTheme.headingMd.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTheme.bodySm.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.labelLg),
                Text(subtitle, style: AppTheme.bodySm.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Manage UMKM ─────────────────────────────────────────
  Widget _buildManageUmkmTab(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              scrolledUnderElevation: 1,
              shadowColor: AppColors.border,
              title: const Text('Verifikasi Warung'),
              bottom: TabBar(
                isScrollable: false,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                labelStyle: AppTheme.labelMd.copyWith(color: AppColors.primary, fontSize: 13),
                unselectedLabelStyle: AppTheme.labelMd.copyWith(fontSize: 13),
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'Approved'),
                  Tab(text: 'Rejected'),
                  Tab(text: 'Semua'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            _buildUmkmList(context, controller.pendingUmkm,
                statusColor: AppColors.warning, isActionable: true),
            _buildUmkmList(context, controller.approvedUmkm,
                statusColor: AppColors.success, isActionable: true),
            _buildUmkmList(context, controller.rejectedUmkm,
                statusColor: AppColors.error, isActionable: true),
            _buildUmkmList(context, controller.allUmkm,
                statusColor: AppColors.info, isActionable: false),
          ],
        ),
      ),
    );
  }
}
