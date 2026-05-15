import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'guest_controller.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final GuestController controller = Get.put(GuestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Etalase Jajanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () => Get.toNamed('/login'),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= SEARCH BAR (TAROH SINI BOS!) =================
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: TextField(
                  onChanged: (value) => controller.searchProduct(value), // Panggil fungsi filter lu
                  decoration: InputDecoration(
                    hintText: 'Cari jajanan enak di sini...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
              // ================= PROMO =================
              if (controller.promoProducts.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'Lagi Promo Nih! 🔥',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.promoProducts.length,
                    itemBuilder: (context, index) {
                      final product = controller.promoProducts[index];

                      return GestureDetector(
                        onTap: () => Get.toNamed(
                          '/detail-umkm',
                          arguments: product.id,
                        ),
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // ===== FOTO PRODUK =====
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Container(
                                  height: 120,
                                  width: double.infinity,
                                  color: Colors.grey.shade300,
                                  child: (product.fotoProduk != null &&
                                          product.fotoProduk!.isNotEmpty)
                                          ? Image.network(
                                          product.fotoProduk!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,

                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }

                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            );
                                          },

                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.fastfood,
                                            color: Colors.grey,
                                            size: 40,
                                          ),
                                        ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.namaProduk,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      'Rp ${product.harga}',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900,
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
                  ),
                ),
              ],

              // ================= REGULER =================
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text(
                  'Rekomendasi Jajanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (controller.regularProducts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Yah, belum ada yang jualan bos.',
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.regularProducts.length,
                  itemBuilder: (context, index) {
                    final product =
                        controller.regularProducts[index];

                    return GestureDetector(
                      onTap: () => Get.toNamed(
                        '/detail-umkm',
                        arguments: product.id,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [

                            // ===== FOTO PRODUK =====
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 80,
                                width: 80,
                                color: Colors.grey.shade300,
                                child: (product.fotoProduk != null &&
                                        product.fotoProduk!.isNotEmpty)
                                    ? Image.network(
                                        product.fotoProduk!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,

                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }

                                          return const Center(
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },

                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.storefront,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.namaProduk,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    'Rp ${product.harga}',
                                    style: const TextStyle(
                                      color:
                                          AppColors.primaryDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }
}