import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import 'admin_controller.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.put(AdminController());

    return DefaultTabController(
      length: 4, // Nambah jadi 4 Tab bos
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: const Text('Dashboard Dewa', style: TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: AppColors.primary, //
                foregroundColor: Colors.white,
                pinned: true,
                floating: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => controller.logout(),
                  )
                ],
                // --- KARTU STATISTIK TOTAL UMKM ---
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(160),
                  child: Column(
                    children: [
                      Obx(() => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total UMKM Terdaftar', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text('Pantau Semua Mitra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                '${controller.totalUmkm.value}', //
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const TabBar(
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        isScrollable: true,
                        unselectedLabelColor: Colors.white70,
                        tabs: [
                          Tab(text: 'Pending'),
                          Tab(text: 'Approved'),
                          Tab(text: 'Rejected'),
                          Tab(text: 'Semua'), // Tab sakti baru buat pantau semua
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildList(context, controller, controller.pendingUmkm, Colors.orange),
              _buildList(context, controller, controller.approvedUmkm, Colors.green),
              _buildList(context, controller, controller.rejectedUmkm, Colors.red),
              _buildList(context, controller, controller.allUmkm, Colors.blue, isAdminAction: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, AdminController controller, RxList list, Color color, {bool isAdminAction = true}) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('Kosong melompong bos!', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final data = list[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(isAdminAction ? Icons.storefront : Icons.visibility, color: color),
              ),
              title: Text(data['nama_toko'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(data['profiles']?['email'] ?? 'No Email'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (isAdminAction) {
                  _showDetailDialog(context, controller, data); //
                } else {
                  // Kalo di tab Semua, langsung intip profilnya bos
                  Get.toNamed('/profile-umkm', arguments: data['id']); 
                }
              },
            ),
          );
        },
      );
    });
  }

  void _showDetailDialog(BuildContext context, AdminController controller, Map data) async {
    final suratUrl = await controller.getSuratUrl(data['surat_izin_url']);
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(data['nama_toko'], style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Status', data['status_verifikasi'].toString().toUpperCase()),
              _infoRow('Email', data['profiles']?['email'] ?? '-'),
              const SizedBox(height: 16),
              const Text('Dokumen Legalitas:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: suratUrl.isEmpty 
                    ? const Center(child: Text('Gak ada berkasnya bos!'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(suratUrl, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                        ),
                      ),
              ),
            ],
          ),
        ),
        actions: [
          if (data['status_verifikasi'] != 'rejected')
            TextButton(
              onPressed: () { controller.eksekusiWarung(data['id'], 'rejected'); Get.back(); },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Tolak'),
            ),
          if (data['status_verifikasi'] != 'approved')
            ElevatedButton(
              onPressed: () { controller.eksekusiWarung(data['id'], 'approved'); Get.back(); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('ACC Sekarang'),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}