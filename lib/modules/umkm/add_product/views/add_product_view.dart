import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:umkm_maps_app/core/theme/app_colors.dart';
import 'package:umkm_maps_app/core/theme/app_theme.dart';
import 'package:umkm_maps_app/core/widgets/app_button.dart';
import 'package:umkm_maps_app/core/widgets/app_text_field.dart';
import 'package:umkm_maps_app/modules/umkm/add_product/controllers/add_product_controller.dart';

class AddProductView extends GetView<AddProductController> {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tambah Menu')),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Photo picker ─────────────────────────────────
              GestureDetector(
                onTap: () => controller.pickImage(),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppTheme.roundedLg,
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: controller.selectedImage.value != null
                      ? ClipRRect(
                          borderRadius: AppTheme.roundedLg,
                          child: Image.file(
                            controller.selectedImage.value!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
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
                            Text('Tambah foto menu',
                                style: AppTheme.labelMd),
                            const SizedBox(height: 4),
                            Text('Tap untuk pilih dari galeri',
                                style: AppTheme.bodySm),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Fields ───────────────────────────────────────
              AppTextField(
                controller: controller.namaController,
                label: 'Nama Menu',
                hint: 'Mis. Nasi Goreng Spesial',
                prefixIcon: Icons.fastfood_outlined,
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: controller.hargaController,
                label: 'Harga (Rp)',
                hint: '15000',
                prefixIcon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: controller.deskripsiController,
                label: 'Deskripsi Singkat',
                hint: 'Ceritakan menu ini…',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // ── Category dropdown ─────────────────────────────
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
                    value: controller.categories.contains(
                            controller.selectedKategori.value)
                        ? controller.selectedKategori.value
                        : (controller.categories.isNotEmpty
                            ? controller.categories.first
                            : null),
                    isExpanded: true,
                    icon: const Icon(Icons.expand_more_rounded,
                        color: AppColors.primary),
                    style: AppTheme.bodyMd.copyWith(color: AppColors.textPrimary),
                    items: controller.categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) controller.selectedKategori.value = v;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Promo toggle ──────────────────────────────────
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
                  subtitle: Text('Menu akan muncul di bagian promo',
                      style: AppTheme.bodySm),
                  value: controller.isPromo.value,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => controller.isPromo.value = v,
                ),
              ),
              const SizedBox(height: 32),

              AppButton(
                label: 'Simpan Menu',
                isLoading: controller.isLoading.value,
                onPressed: () => controller.submitProduct(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }
}
