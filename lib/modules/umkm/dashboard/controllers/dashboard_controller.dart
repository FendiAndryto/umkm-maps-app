import 'dart:io'; // Wajib buat handle file foto
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Pastiin udah di-install bos
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator bos!
import 'package:geocoding/geocoding.dart'; // Import geocoding bos!
import 'package:umkm_maps_app/data/models/product_model.dart'; 

class DashboardController extends GetxController {
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  
  var isLoading = true.obs;
  var myProducts = <ProductModel>[].obs;
  var umkmId = ''.obs;
  var currentTabIndex = 0.obs;
  var latestReviews = <dynamic>[].obs;
  
  // Data Warung Reaktif
  var namaWarung = ''.obs;
  var deskripsiWarung = ''.obs;
  var fotoProfil = ''.obs;
  var statusVerifikasi = 'pending'.obs; 
  var noTelepon = ''.obs; // Tambahan reaktif nomor telepon bos!
  var latitude = 0.0.obs; // Koordinat lintang warung
  var longitude = 0.0.obs; // Koordinat bujur warung
  var alamatWarung = 'Memuat lokasi...'.obs; // Alamat nama jalan/daerah atau nama daerah

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
      noTelepon.value = umkmData['no_telepon'] ?? ''; // Muat nomor telepon bos!
      latitude.value = (umkmData['latitude'] as num?)?.toDouble() ?? 0.0; // Muat latitude
      longitude.value = (umkmData['longitude'] as num?)?.toDouble() ?? 0.0; // Muat longitude
      await convertToAddress(latitude.value, longitude.value); // Convert koordinat ke nama jalan/daerah!

      // 2. Tarik barang dagangan join ulasan agar rating terlihat di dashboard penjual
      if (statusVerifikasi.value == 'approved') {
        final response = await supabase
            .from('products')
            .select('*, product_reviews(*)')
            .eq('umkm_id', umkmId.value)
            .order('created_at', ascending: false);
            
        myProducts.assignAll((response as List)
            .map((e) => ProductModel.fromJson(e))
            .toList());

        await fetchLatestReviews();
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
      // 1. Pilih foto dari galeri HP (Kompresi & Resize Avatar)
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60, // Kompresi optimal
        maxWidth: 500,    // Batasi lebar maksimal 500px untuk avatar
        maxHeight: 500,   // Batasi tinggi maksimal 500px untuk avatar
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

  // --- FUNGSI REVERSE GEOCODING (Ubah koordinat jadi nama jalan / daerah) ---
  Future<void> convertToAddress(double lat, double lng) async {
    if (lat == 0.0 && lng == 0.0) {
      alamatWarung.value = 'Lokasi belum disetting';
      return;
    }
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Buat string nama jalan atau daerah yang paling pas
        String street = place.street ?? '';
        String subLocality = place.subLocality ?? '';
        String locality = place.locality ?? '';
        
        List<String> parts = [];
        if (street.isNotEmpty && street != place.name) {
          parts.add(street);
        } else if (place.name != null && place.name!.isNotEmpty) {
          parts.add(place.name!);
        }
        if (subLocality.isNotEmpty) parts.add(subLocality);
        if (locality.isNotEmpty) parts.add(locality);
        
        if (parts.isNotEmpty) {
          alamatWarung.value = parts.join(', ');
        } else {
          alamatWarung.value = 'Daerah tidak dikenal';
        }
      } else {
        alamatWarung.value = 'Alamat tidak ditemukan';
      }
    } catch (e) {
      alamatWarung.value = 'Lat: $lat, Lng: $lng'; // Fallback ke koordinat kalau error internet/geocoder
    }
  }

  // --- FUNGSI TEMBAK KOORDINAT GPS (Baru & Canggih!) ---
  Future<void> getCurrentLocation() async {
    try {
      isLoading(true);
      
      // 1. Cek & Minta Izin GPS
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Waduh Izin Ditolak',
          'Izin lokasi lu tolak permanen bos, buka setting HP manual gih!',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 2. Ambil Posisi Saat Ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;
      await convertToAddress(position.latitude, position.longitude);

      Get.snackbar(
        'GPS Sukses!',
        'Lokasi warung berhasil dikunci bos!',
        backgroundColor: Colors.green.shade100,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Deteksi GPS',
        'Masalah GPS: $e',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // --- FUNGSI UPDATE DATA TEKS DENGAN NOMOR TELEPON & KOORDINAT ---
  Future<void> updateProfile({
    required String nama,
    required String deskripsi,
    required String phone,
    required double lat,
    required double lng,
  }) async {
    if (nama.trim().isEmpty || deskripsi.trim().isEmpty || phone.trim().isEmpty) {
      Get.snackbar(
        'Validasi Gagal!',
        'Nama Warung, Deskripsi, dan No. Telepon tidak boleh ada yang kosong.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading(true);
      await supabase.from('umkm').update({
        'nama_toko': nama,
        'deskripsi': deskripsi,
        'no_telepon': phone.trim(),
        'latitude': lat,
        'longitude': lng,
      }).eq('id', umkmId.value);

      namaWarung.value = nama;
      deskripsiWarung.value = deskripsi;
      noTelepon.value = phone.trim();
      latitude.value = lat;
      longitude.value = lng;
      await convertToAddress(lat, lng);
      
      Get.snackbar(
        'Mantap Betul!',
        'Info & lokasi warung lu udah update bos.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Waduh Gagal!',
        'Gagal update info: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

  // --- FUNGSI AMBIL KOMENTAR TERBARU DARI SEMUA PRODUK ---
  Future<void> fetchLatestReviews() async {
    if (umkmId.value.isEmpty) return;
    try {
      final response = await supabase
          .from('product_reviews')
          .select('*, products!inner(*)')
          .eq('products.umkm_id', umkmId.value)
          .order('created_at', ascending: false);

      latestReviews.assignAll(response as List);
    } catch (e) {
      debugPrint('Gagal mengambil ulasan: $e');
    }
  }

  // --- FUNGSI HAPUS ULASAN/KOMENTAR ---
  Future<void> deleteReview(dynamic reviewId) async {
    try {
      isLoading(true);
      // Konversi ke int jika tipe data di database adalah integer untuk mencegah type mismatch
      final parsedId = int.tryParse(reviewId.toString()) ?? reviewId;
      
      // Lakukan hapus ke database
      await supabase.from('product_reviews').delete().eq('id', parsedId);
      
      // Ambil data ulasan & produk terbaru
      await fetchLatestReviews();
      await fetchMyProducts();
      
      // Cek apakah komentar masih ada setelah di-refetch (untuk mendeteksi RLS/hak akses)
      final isStillPresent = latestReviews.any((element) => element['id'].toString() == reviewId.toString());
      
      if (isStillPresent) {
        Get.snackbar(
          'Gagal Menghapus', 
          'Komentar gagal dihapus dari database. Hal ini kemungkinan disebabkan oleh kebijakan keamanan (RLS) Supabase yang membatasi hak hapus ulasan.', 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.amber.shade800, 
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Musnah!', 
          'Komentar/ulasan pembeli berhasil dihapus.', 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.green, 
          colorText: Colors.white
        );
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Error pas hapus ulasan: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAllNamed('/login'); 
  }
}
