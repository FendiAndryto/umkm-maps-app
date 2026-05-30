import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:umkm_maps_app/modules/umkm/dashboard/controllers/dashboard_controller.dart';
import 'package:umkm_maps_app/data/models/product_model.dart';

class EditProductController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = false.obs;

  late ProductModel product;
  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();
  var isPromo = false.obs;
  var selectedImage = Rxn<File>();
  String? oldImageUrl;

  // Tambahan kategori reaktif bos!
  var selectedKategori = 'Makanan'.obs;
  var categories = <String>[].obs; // Sekarang dynamic!

  @override
  void onInit() {
    super.onInit();
    // Ambil data yang dikirim dari halaman sebelumnya
    product = Get.arguments as ProductModel;
    
    // Isi form pake data lama
    namaController.text = product.namaProduk;
    hargaController.text = product.harga.toString();
    deskripsiController.text = product.deskripsi ?? '';
    isPromo.value = product.isPromo;
    oldImageUrl = product.fotoProduk;
    selectedKategori.value = product.kategori ?? 'Lainnya'; // Load kategori lama
    
    fetchCategories(); // Load kategori dinamis dari database!
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('categories').select().order('name');
      final list = (response as List).map((e) => e['name'] as String).toList();
      
      // Hapus 'Lainnya' dan letakkan di paling akhir
      list.remove('Lainnya');
      categories.value = [...list, 'Lainnya'];
      
      // Jaga-jaga jika kategori lama sudah dihapus admin, set ke yang tersedia
      if (categories.isNotEmpty && !categories.contains(selectedKategori.value)) {
        selectedKategori.value = categories.first;
      }
    } catch (e) {
      categories.value = ['Makanan', 'Minuman', 'Cemilan', 'Lainnya'];
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 65, // Kompresi seimbang tanpa kehilangan detail visual
      maxWidth: 800,    // Batasi resolusi lebar maksimal 800px
      maxHeight: 800,   // Batasi resolusi tinggi maksimal 800px
    );
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  Future<void> updateProduct() async {
    try {
      isLoading(true);
      String? finalImageUrl = oldImageUrl;

      // 1. Kalo ada foto baru, upload!
      if (selectedImage.value != null) {
        final file = selectedImage.value!;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        await supabase.storage.from('umkm-assets').upload(fileName, file);
        finalImageUrl = supabase.storage.from('umkm-assets').getPublicUrl(fileName);
      }

      // 2. Update data ke tabel products
      await supabase.from('products').update({
        'nama_produk': namaController.text.trim(),
        'harga': int.parse(hargaController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        'deskripsi': deskripsiController.text.trim(),
        'foto_produk': finalImageUrl,
        'is_promo': isPromo.value,
        'kategori': selectedKategori.value, // Tambahan kategori bos!
      }).eq('id', product.id);

      Get.find<DashboardController>().fetchMyProducts();
      Get.back();
      Get.snackbar('Berhasil', 'Dagangan lu udah di-update bos!', backgroundColor: Colors.green.shade100);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
