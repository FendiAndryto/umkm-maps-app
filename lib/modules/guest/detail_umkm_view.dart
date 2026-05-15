import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'detail_umkm_controller.dart';

class DetailUmkmView extends StatelessWidget {
  const DetailUmkmView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pakai Get.put dengan tag unik biar data kaga ketuker antar produk
    final DetailUmkmController controller = Get.put(
      DetailUmkmController(), 
      tag: Get.arguments.toString()
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Jajanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Hapus controller manual biar memori bersih total pas balik
            Get.delete<DetailUmkmController>(tag: Get.arguments.toString());
            Get.back();
          },
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        if (controller.productData.isEmpty) {
          return const Center(
            child: Text(
              'Datanya gaib bos, nggak ketemu!',
            ),
          );
        }

        final product = controller.productData;
        final umkm = controller.umkmData;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= FOTO PRODUK =================
              Container(
                height: 280,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: (product['foto_produk'] != null &&
                        product['foto_produk'].toString().isNotEmpty)
                    ? Image.network(
                        product['foto_produk'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(Icons.fastfood, size: 100, color: Colors.grey),
                      ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= INFO PRODUK =================
                    Text(
                      product['nama_produk'] ?? 'Produk Tanpa Nama',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Rp ${product['harga']}',
                      style: const TextStyle(
                        fontSize: 22,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      product['deskripsi'] ?? 'Nggak ada deskripsi, langsung samperin aja buat nyobain.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const Divider(height: 50, thickness: 1, color: Colors.black12),

                    // ================= CARD UMKM =================
                    const Text(
                      'Dijual Oleh:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () => Get.toNamed('/profile-umkm', arguments: umkm['id']),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            // FOTO PROFIL UMKM (SEKARANG DAH LOAD FOTO BOSS!)
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              backgroundImage: (umkm['foto_profil'] != null && umkm['foto_profil'].toString().isNotEmpty)
                                  ? NetworkImage(umkm['foto_profil'])
                                  : null,
                              child: (umkm['foto_profil'] == null || umkm['foto_profil'].toString().isEmpty)
                                  ? const Icon(Icons.storefront, size: 30, color: AppColors.primary)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    umkm['nama_toko'] ?? 'Toko Anonim',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    umkm['deskripsi'] ?? 'Toko andalan warga',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ================= TOMBOL MAPS =================
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.openGoogleMaps(),
                        icon: const Icon(Icons.map_rounded, size: 24),
                        label: const Text('Buka di Google Maps', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}