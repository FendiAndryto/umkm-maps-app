import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import 'dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi Controller
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppColors.background, //
      appBar: AppBar(
        title: const Text('Markas UMKM'),
        backgroundColor: AppColors.primary, //
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => controller.logout(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        // TAMPILAN KALO BELOM DI-ACC ADMIN
        if (controller.statusVerifikasi.value != 'approved') {
          return _buildPendingOrRejected(controller.statusVerifikasi.value);
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ================= HEADER PROFIL + UPLOAD FOTO =================
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surface, //
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    // STACK FOTO PROFIL BIAR BISA DI-UPLOAD
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.teal.shade50,
                          backgroundImage: controller.fotoProfil.value.isNotEmpty 
                              ? NetworkImage(controller.fotoProfil.value) : null,
                          child: controller.fotoProfil.value.isEmpty 
                              ? const Icon(Icons.storefront, size: 50, color: AppColors.primary) : null,
                        ),
                        // TOMBOL KAMERA BUAT GANTI FOTO PROFIL
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => controller.uploadFotoProfil(), //
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(controller.namaWarung.value, 
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(controller.deskripsiWarung.value, 
                        textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    
                    // EDIT DATA TEKS (NAMA & DESKRIPSI)
                    ElevatedButton.icon(
                      onPressed: () => _showEditProfileDialog(context, controller),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit Profil Warung'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade50,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text('Etalase Jualan Lu', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            // ================= GRID DAGANGAN DENGAN ACTION DI BAWAH =================
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: controller.myProducts.isEmpty 
                ? const SliverToBoxAdapter(child: Center(child: Text('\n\nKosong bos, tambah menu gih!')))
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      mainAxisSpacing: 16, 
                      crossAxisSpacing: 16, 
                      childAspectRatio: 0.72, // Diatur biar muat tombol di bawah harga
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final p = controller.myProducts[index]; //
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                            ],
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // FOTO PRODUK
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: Container(
                                        width: double.infinity,
                                        color: Colors.grey.shade100,
                                        child: p.fotoProduk != null 
                                            ? Image.network(p.fotoProduk!, fit: BoxFit.cover)
                                            : const Icon(Icons.fastfood, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  // INFO PRODUK & ACTION
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.namaProduk, maxLines: 1, 
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text('Rp ${p.harga}', 
                                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                        
                                        const SizedBox(height: 12),
                                        const Divider(height: 1, thickness: 0.5),
                                        const SizedBox(height: 8),
                                        
                                        // --- TOMBOL EDIT & DELETE DI BAWAH ---
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            GestureDetector(
                                              onTap: () => Get.toNamed('/edit-product', arguments: p),
                                              child: const Icon(Icons.edit_note_rounded, color: Colors.blue, size: 24),
                                            ),
                                            Container(width: 1, height: 20, color: Colors.grey.shade200),
                                            GestureDetector(
                                              onTap: () => _confirmDelete(p, controller),
                                              child: const Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 24),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // TAG PROMO (MUNCUL KALO isPromo TRUE)
                              if (p.isPromo)
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary, //
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.local_fire_department, size: 12, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('PROMO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                      childCount: controller.myProducts.length,
                    ),
                  ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      }),
      // TOMBOL TAMBAH MENU (Floating)
      floatingActionButton: Obx(() => controller.statusVerifikasi.value == 'approved' 
        ? FloatingActionButton.extended(
            onPressed: () => Get.toNamed('/add-product'),
            backgroundColor: AppColors.primary,
            label: const Text('Tambah Menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.add, color: Colors.white),
          ) : const SizedBox.shrink()),
    );
  }

  // ================= DIALOG EDIT & DELETE =================
  void _showEditProfileDialog(BuildContext context, DashboardController controller) {
    final nameCtrl = TextEditingController(text: controller.namaWarung.value);
    final descCtrl = TextEditingController(text: controller.deskripsiWarung.value);
    Get.defaultDialog(
      title: 'Update Profil Warung',
      content: Column(
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Warung')),
          const SizedBox(height: 10),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi')),
        ],
      ),
      textConfirm: 'Simpan',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () => controller.updateProfile(nameCtrl.text, descCtrl.text), //
    );
  }

  void _confirmDelete(p, controller) {
    Get.defaultDialog(
      title: 'Hapus?', middleText: 'Yakin mau hapus ${p.namaProduk}?',
      textConfirm: 'Hapus', textCancel: 'Batal', confirmTextColor: Colors.white,
      buttonColor: Colors.red, onConfirm: () { 
        Get.back(); 
        controller.hapusDagangan(p.id); //
      }
    );
  }

  // LAYOUT KALO BELUM DI-ACC
  Widget _buildPendingOrRejected(String status) {
    bool isPending = status == 'pending';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPending ? Icons.hourglass_top : Icons.error_outline, 
                size: 80, color: isPending ? Colors.orange : Colors.red),
            const SizedBox(height: 20),
            Text(isPending ? 'Sabar Bos!' : 'Waduh Ditolak!', 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(isPending ? 'Surat izin lu lagi dicek admin.' : 'Admin bilang berkas lu kaga valid.', 
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}