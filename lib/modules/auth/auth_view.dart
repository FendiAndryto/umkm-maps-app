import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'auth_controller.dart';

class AuthView extends StatelessWidget {
  AuthView({super.key});

  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Obx(() {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    controller.isLogin.value ? Icons.vpn_key_rounded : Icons.add_business_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    controller.isLogin.value ? 'Masuk Dulu Bos' : 'Daftar Warung Baru',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),

                  // --- FORM KHUSUS REGISTER ---
                  if (!controller.isLogin.value) ...[
                    TextField(
                      controller: controller.namaTokoController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Toko / Warung',
                        prefixIcon: Icon(Icons.store),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Box Pilih Surat Izin
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            controller.selectedSurat.value != null 
                                ? Icons.check_circle 
                                : Icons.description_outlined,
                            color: controller.selectedSurat.value != null 
                                ? Colors.green 
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.selectedSurat.value != null 
                                  ? 'Surat Izin Terlampir ✅' 
                                  : 'Foto Surat Izin (SKU)',
                              style: TextStyle(
                                fontSize: 14,
                                color: controller.selectedSurat.value != null 
                                    ? Colors.black 
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => controller.pickSurat(),
                            child: const Text('Pilih Foto'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- TAMBAHAN BARU: TOMBOL AMBIL LOKASI GPS ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.isLocationPicked.value ? Colors.green : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on, 
                            color: controller.isLocationPicked.value ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.isLocationPicked.value 
                                ? 'Lokasi Warung Terkunci ✅' 
                                : 'Belum Set Lokasi Warung',
                              style: TextStyle(
                                fontSize: 14,
                                color: controller.isLocationPicked.value ? Colors.green.shade700 : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => controller.getCurrentLocation(),
                            child: const Text('Ambil GPS'),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // --- FORM EMAIL & PASSWORD ---
                  TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- TOMBOL SUBMIT ---
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : () => controller.submit(),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              controller.isLogin.value ? 'Masuk Sekarang' : 'Daftar Warung',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Link Pindah Mode
                  TextButton(
                    onPressed: () => controller.toggleMode(),
                    child: Text(
                      controller.isLogin.value
                          ? 'Belum punya akun? Daftar UMKM di sini.'
                          : 'Udah ada akun? Login aja bos.',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}