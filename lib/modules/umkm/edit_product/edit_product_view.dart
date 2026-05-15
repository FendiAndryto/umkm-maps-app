import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import 'edit_product_controller.dart';

class EditProductView extends StatelessWidget {
  EditProductView({super.key});
  final controller = Get.put(EditProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Jajanan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.pickImage(),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                child: controller.selectedImage.value != null
                    ? Image.file(controller.selectedImage.value!, fit: BoxFit.cover)
                    : (controller.oldImageUrl != null 
                        ? Image.network(controller.oldImageUrl!, fit: BoxFit.cover)
                        : const Icon(Icons.add_a_photo)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: controller.namaController, decoration: const InputDecoration(labelText: 'Nama Jajanan')),
            const SizedBox(height: 15),
            TextField(controller: controller.hargaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga')),
            const SizedBox(height: 15),
            TextField(controller: controller.deskripsiController, maxLines: 3, decoration: const InputDecoration(labelText: 'Deskripsi')),
            SwitchListTile(
              title: const Text('Promo 🔥'),
              value: controller.isPromo.value,
              onChanged: (v) => controller.isPromo.value = v,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.updateProduct(),
                child: controller.isLoading.value ? const CircularProgressIndicator() : const Text('Simpan Perubahan'),
              ),
            )
          ],
        ),
      )),
    );
  }
}