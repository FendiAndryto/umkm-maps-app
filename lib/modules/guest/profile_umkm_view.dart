import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'profile_umkm_controller.dart';

class ProfileUmkmView extends StatelessWidget {
  const ProfileUmkmView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    final controller = Get.put(ProfileUmkmController());

    return Scaffold(
      backgroundColor: AppColors.background, //
      appBar: AppBar(
        title: const Text('Profil UMKM'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final toko = controller.umkmData;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // HEADER PROFIL
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surface, //
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    // Foto Profil / Logo Toko
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.teal.shade50,
                      backgroundImage: (toko['foto_profil'] != null) 
                          ? NetworkImage(toko['foto_profil']) 
                          : null,
                      child: (toko['foto_profil'] == null) 
                          ? const Icon(Icons.storefront, size: 50, color: AppColors.primary) 
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Nama Toko
                    Text(
                      toko['nama_toko'] ?? 'Nama UMKM', //
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 8),
                    // Deskripsi Toko
                    Text(
                      toko['deskripsi'] ?? 'Gak ada deskripsi bos.', //
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    // Badge Verifikasi
                    if (toko['status_verifikasi'] == 'approved')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: AppColors.success, size: 16),
                            SizedBox(width: 6),
                            Text('Toko Terverifikasi', 
                              style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // JUDUL LIST PRODUK
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    const Text('Daftar Jajanan', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${controller.storeProducts.length} Produk', 
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ),

            // GRID LIST PRODUK
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = controller.storeProducts[index];
                    return GestureDetector(
                      onTap: () => Get.toNamed('/detail-umkm', arguments: product.id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Foto Produk
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade50,
                                  child: (product.fotoProduk != null)
                                      ? Image.network(product.fotoProduk!, fit: BoxFit.cover)
                                      : const Icon(Icons.fastfood, color: Colors.grey, size: 40),
                                ),
                              ),
                            ),
                            // Info Produk
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.namaProduk, //
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${product.harga}', //
                                    style: const TextStyle(
                                      color: AppColors.primary, 
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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