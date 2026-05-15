import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import 'add_product_controller.dart';

class AddProductView extends StatelessWidget {
  AddProductView({super.key});

  final AddProductController controller = Get.put(AddProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Menu'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kotak Pilih Foto
              GestureDetector(
                onTap: () => controller.pickImage(),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                  ),
                  child: controller.selectedImage.value != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(controller.selectedImage.value!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tap buat masukin foto jajanan lu', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: controller.namaController,
                decoration: const InputDecoration(labelText: 'Nama Jajanan', prefixIcon: Icon(Icons.fastfood)),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: controller.hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga (Rp)', prefixIcon: Icon(Icons.money)),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: controller.deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Deskripsi Singkat', prefixIcon: Icon(Icons.description)),
              ),
              const SizedBox(height: 16),

              // Switch buat nandain promo
              SwitchListTile(
                title: const Text('Masukin Daftar Promo? 🔥', style: TextStyle(fontWeight: FontWeight.bold)),
                value: controller.isPromo.value,
                activeColor: AppColors.primary,
                onChanged: (val) => controller.isPromo.value = val,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.submitProduct(),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Dagangan', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}