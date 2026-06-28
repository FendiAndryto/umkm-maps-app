import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:umkm_maps_app/core/theme/app_colors.dart';
import 'package:umkm_maps_app/core/theme/app_theme.dart';
import 'package:umkm_maps_app/core/widgets/app_button.dart';
import 'package:umkm_maps_app/core/widgets/app_text_field.dart';
import 'package:umkm_maps_app/modules/umkm/edit_product/controllers/edit_product_controller.dart';
import 'package:umkm_maps_app/modules/umkm/widgets/admin_whatsapp_button.dart';

class EditProductView extends GetView<EditProductController> {
  const EditProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Menu')),
      floatingActionButton: const AdminWhatsAppButton(),
      body: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Photo picker ────────────────────────────────
                GestureDetector(
                  onTap: () => controller.pickImage(),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: AppTheme.roundedLg,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ClipRRect(
                      borderRadius: AppTheme.roundedLg,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (controller.selectedImage.value != null)
                            Image.file(controller.selectedImage.value!,
                                fit: BoxFit.cover)
                          else if (controller.oldImageUrl != null)
                            Image.network(controller.oldImageUrl!,
                                fit: BoxFit.cover,
                                 errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.broken_image_outlined,
                                        color: AppColors.textTertiary)))
                          else
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: AppTheme.roundedLg,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 26,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text('Pilih foto menu', style: AppTheme.labelMd),
                              ],
                            ),
                          // Edit overlay
                          Positioned(
                            bottom: 12, right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: AppTheme.roundedFull,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.camera_alt_outlined,
                                      size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text('Ganti Foto',
                                      style: AppTheme.bodySm.copyWith(
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Fields ──────────────────────────────────────
                AppTextField(
                  controller: controller.namaController,
                  label: 'Nama Menu',
                  prefixIcon: Icons.fastfood_outlined,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: controller.hargaController,
                  label: 'Harga (Rp)',
                  prefixIcon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: controller.deskripsiController,
                  label: 'Deskripsi',
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // ── Category dropdown ────────────────────────────
                Text('Kategori', style: AppTheme.labelMd),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppTheme.roundedMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.categories
                              .contains(controller.selectedKategori.value)
                          ? controller.selectedKategori.value
                          : (controller.categories.isNotEmpty
                              ? controller.categories.first
                              : null),
                      isExpanded: true,
                      icon: const Icon(Icons.expand_more_rounded,
                          color: AppColors.primary),
                      style: AppTheme.bodyMd
                          .copyWith(color: AppColors.textPrimary),
                      items: controller.categories
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) controller.selectedKategori.value = v;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Promo toggle ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppTheme.roundedMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Tandai sebagai Promo 🔥',
                        style: AppTheme.labelLg),
                    value: controller.isPromo.value,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => controller.isPromo.value = v,
                  ),
                ),
                const SizedBox(height: 32),

                AppButton(
                  label: 'Simpan Perubahan',
                  isLoading: controller.isLoading.value,
                  onPressed: () => controller.updateProduct(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          )),
    );
  }
}
