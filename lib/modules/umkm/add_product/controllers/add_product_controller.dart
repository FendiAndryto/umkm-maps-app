import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:umkm_maps_app/modules/umkm/dashboard/controllers/dashboard_controller.dart'; // Buat refresh data ntar

class AddProductController extends GetxController {
  final supabase = Supabase.instance.client;
  
  var isLoading = false.obs;
  
  // Buat nangkep inputan form
  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();
  var isPromo = false.obs;
  
  // Tambahan kategori reaktif bos!
  var selectedKategori = 'Makanan'.obs;
  var categories = <String>[].obs; // Sekarang dynamic!

  // Buat nyimpen foto yang dipilih
  var selectedImage = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('categories').select().order('name');
      final list = (response as List).map((e) => e['name'] as String).toList();
      
      // Hapus 'Lainnya' dan letakkan di paling akhir
      list.remove('Lainnya');
      categories.value = [...list, 'Lainnya'];
      
      if (categories.isNotEmpty) {
        selectedKategori.value = categories.first;
      }
    } catch (e) {
      // Fallback
      categories.value = ['Makanan', 'Minuman', 'Cemilan', 'Lainnya'];
    }
  }

  // Fungsi milih foto dari galeri (Kompresi & Resize Premium!)
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

  // Fungsi utama ngelempar data ke Supabase
  Future<void> submitProduct() async {
    if (namaController.text.isEmpty || hargaController.text.isEmpty) {
      Get.snackbar('Waduh', 'Nama sama harga wajib diisi bos!', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading(true);
      
      // Ambil ID UMKM dari controller dashboard
      final dashboardCtrl = Get.find<DashboardController>();
      final umkmId = dashboardCtrl.umkmId.value;
      
      String? imageUrl;

      // 1. Kalo dia milih foto, upload dulu ke Storage!
      if (selectedImage.value != null) {
        final file = selectedImage.value!;
        final fileExt = file.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        
        // PENTING: Ganti 'umkm-assets' pake nama bucket lu kalo beda!
        await supabase.storage.from('umkm-assets').upload(
          fileName,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        
        // Dapet link publik fotonya
        imageUrl = supabase.storage.from('umkm-assets').getPublicUrl(fileName);
      }

      // 2. Simpen data teks + link foto ke tabel products
      await supabase.from('products').insert({
        'umkm_id': umkmId,
        'nama_produk': namaController.text.trim(),
        'harga': int.parse(hargaController.text.replaceAll(RegExp(r'[^0-9]'), '')), // Biar aman kalo dia ngetik titik
        'deskripsi': deskripsiController.text.trim(),
        'foto_produk': imageUrl,
        'is_promo': isPromo.value,
        'kategori': selectedKategori.value, // Tambahan kategori bos!
      });

      // 3. Refresh list di dashboard biar langsung nongol!
      dashboardCtrl.fetchMyProducts();
      
      Get.back(); // Tutup halaman form
      Get.snackbar('Cakep!', 'Dagangan lu udah mejeng di etalase.', snackPosition: SnackPosition.BOTTOM);

    } catch (e) {
      Get.snackbar('Error Bos', 'Gagal upload: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
    } finally {
      isLoading(false);
    }
  }
}
