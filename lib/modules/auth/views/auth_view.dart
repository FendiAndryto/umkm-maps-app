import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:umkm_maps_app/core/theme/app_colors.dart';
import 'package:umkm_maps_app/core/theme/app_theme.dart';
import 'package:umkm_maps_app/core/widgets/app_button.dart';
import 'package:umkm_maps_app/core/widgets/app_text_field.dart';
import 'package:umkm_maps_app/modules/auth/controllers/auth_controller.dart';
import 'package:umkm_maps_app/routes/app_routes.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Obx(() {
            final isLogin = controller.isLogin.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Logo / Brand ───────────────────────────────────
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: AppTheme.roundedXl,
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isLogin ? 'Selamat Datang' : 'Daftar Warung',
                  textAlign: TextAlign.center,
                  style: AppTheme.headingXl,
                ),
                const SizedBox(height: 6),
                Text(
                  isLogin
                      ? 'Masuk ke akun UMKM kamu'
                      : 'Daftarkan warung kamu sekarang',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMd.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 36),

                // ── Register-only fields ────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: !isLogin
                      ? Column(
                          key: const ValueKey('register'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              controller: controller.namaTokoController,
                              label: 'Nama Toko / Warung',
                              hint: 'Mis. Warung Makan Bu Sari',
                              prefixIcon: Icons.storefront_outlined,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: controller.noTeleponController,
                              label: 'Nomor Telepon / WhatsApp',
                              hint: '08123456789',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            _UploadCard(
                              label: 'Foto Surat Izin (SKU)',
                              isAttached:
                                  controller.selectedSurat.value != null,
                              attachedLabel: 'Surat Izin Terlampir',
                              icon: Icons.description_outlined,
                              onTap: () => controller.pickSurat(),
                            ),
                            const SizedBox(height: 12),
                            _UploadCard(
                              label: 'Ambil Lokasi GPS Warung',
                              isAttached: controller.isLocationPicked.value,
                              attachedLabel: 'Lokasi Terkunci',
                              icon: Icons.location_on_outlined,
                              actionLabel: 'Ambil GPS',
                              onTap: () => controller.getCurrentLocation(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        )
                      : const SizedBox.shrink(key: ValueKey('login')),
                ),

                // ── Common fields ───────────────────────────────────
                AppTextField(
                  controller: controller.emailController,
                  label: 'Email',
                  hint: 'email@warung.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: controller.passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 28),

                // ── Submit ─────────────────────────────────────────
                AppButton(
                  label: isLogin ? 'Masuk Sekarang' : 'Daftar Warung',
                  isLoading: controller.isLoading.value,
                  onPressed: () => controller.submit(),
                ),
                const SizedBox(height: 16),

                // ── Toggle mode ───────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                      style: AppTheme.bodyMd
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => controller.toggleMode(),
                      child: Text(
                        isLogin ? 'Daftar di sini' : 'Masuk',
                        style: AppTheme.labelLg
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Divider ───────────────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ATAU',
                        style: AppTheme.labelMd.copyWith(color: AppColors.textTertiary, fontSize: 11),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Browse as Guest Button ────────────────────────
                AppButton(
                  label: 'Lihat Etalase Jajanan (Tamu)',
                  variant: AppButtonVariant.outline,
                  prefixIcon: const Icon(
                    Icons.explore_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String label;
  final String attachedLabel;
  final bool isAttached;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onTap;

  const _UploadCard({
    required this.label,
    required this.attachedLabel,
    required this.isAttached,
    required this.icon,
    required this.onTap,
    this.actionLabel = 'Pilih File',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isAttached ? AppColors.successSurface : AppColors.surface,
        borderRadius: AppTheme.roundedMd,
        border: Border.all(
          color: isAttached ? AppColors.success : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAttached ? Icons.check_circle_rounded : icon,
            color: isAttached ? AppColors.success : AppColors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isAttached ? attachedLabel : label,
              style: AppTheme.bodyMd.copyWith(
                color: isAttached ? AppColors.success : AppColors.textSecondary,
                fontWeight:
                    isAttached ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionLabel,
              style: AppTheme.labelMd.copyWith(color: AppColors.primary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
