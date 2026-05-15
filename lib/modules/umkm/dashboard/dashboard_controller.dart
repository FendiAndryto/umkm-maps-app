import 'dart:io'; // Wajib buat handle file foto
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Pastiin udah di-install bos
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/product_model.dart'; 

class DashboardController extends GetxController {
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  
  var isLoading = true.obs;
  var myProducts = <ProductModel>[].obs;
  var umkmId = ''.obs;
  
  // Data Warung Reaktif
  var namaWarung = ''.obs;
  var deskripsiWarung = ''.obs;
  var fotoProfil = ''.obs;
  var statusVerifikasi = 'pending'.obs; 

  @override
  void onInit() {
    super.onInit();
    fetchMyProducts();
  }

  // --- FUNGSI TARIK DATA UTAMA ---
  Future<void> fetchMyProducts() async {
    try {
      isLoading(true);
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        Get.offAllNamed('/login'); 
        return;
      }

      // 1. Tarik profil warung lengkap
      final umkmData = await supabase
          .from('umkm')
          .select()
          .eq('user_id', user.id)
          .single();
          
      umkmId.value = umkmData['id'];
      namaWarung.value = umkmData['nama_toko'];
      deskripsiWarung.value = umkmData['deskripsi'] ?? 'Toko andalan masyarakat';
      fotoProfil.value = umkmData['foto_profil'] ?? '';
      statusVerifikasi.value = umkmData['status_verifikasi']; 

      // 2. Tarik barang dagangan
      if (statusVerifikasi.value == 'approved') {
        final response = await supabase
            .from('products')
            .select()
            .eq('umkm_id', umkmId.value)
            .order('created_at', ascending: false);
            
        myProducts.assignAll((response as List)
            .map((e) => ProductModel.fromJson(e))
            .toList());
      }

    } catch (e) {
      Get.snackbar('Error', 'Gagal narik data: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // --- FUNGSI UPLOAD FOTO PROFIL (Sakti!) ---
  Future<void> uploadFotoProfil() async {
    try {
      // 1. Pilih foto dari galeri HP
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Kompres biar kaga boros storage Supabase
      );

      if (pickedFile == null) return;

      isLoading(true);
      File file = File(pickedFile.path);
      
      // Buat nama file unik: folder profiles/ + ID UMKM + Timestamp
      String fileName = 'profiles/${umkmId.value}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 2. Upload ke bucket 'umkm-assets'
      await supabase.storage.from('umkm-assets').upload(
        fileName,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      // 3. Ambil link publiknya
      final String publicUrl = supabase.storage
          .from('umkm-assets')
          .getPublicUrl(fileName);

      // 4. Update ke database tabel umkm
      await supabase.from('umkm').update({
        'foto_profil': publicUrl,
      }).eq('id', umkmId.value);

      // 5. Update variabel reaktif biar UI langsung berubah
      fotoProfil.value = publicUrl;
      
      Get.snackbar('Sip Mantap!', 'Foto profil warung lu udah ganti bos.', 
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      
    } catch (e) {
      Get.snackbar('Waduh Error!', 'Gagal upload foto: $e', 
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  // --- FUNGSI UPDATE DATA TEKS ---
  Future<void> updateProfile(String nama, String deskripsi) async {
    try {
      isLoading(true);
      await supabase.from('umkm').update({
        'nama_toko': nama,
        'deskripsi': deskripsi,
      }).eq('id', umkmId.value);

      namaWarung.value = nama;
      deskripsiWarung.value = deskripsi;
      Get.back(); // Tutup dialog edit
      Get.snackbar('Sip!', 'Info warung lu udah update bos.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Waduh', 'Gagal update info: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // --- FUNGSI HAPUS DAGANGAN ---
  Future<void> hapusDagangan(String productId) async {
    try {
      isLoading(true);
      await supabase.from('products').delete().eq('id', productId);
      fetchMyProducts(); // Refresh list jualan
      Get.snackbar('Musnah!', 'Dagangan lu udah ilang dari etalase.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Gagal', 'Error pas hapus: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAllNamed('/login'); 
  }
}