import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:umkm_maps_app/modules/home/controllers/home_controller.dart';

class DetailUmkmController extends GetxController {
  final supabase = Supabase.instance.client;
  
  var isLoading = true.obs;
  var selectedStars = 5.obs; // Bintang yang dipilih saat review bos!
  var isLoggedIn = false.obs; // Cek status login

  
  // Data reaktif buat produk, toko, dan ulasan
  var productData = {}.obs;
  var umkmData = {}.obs;
  var reviews = <dynamic>[].obs; // Tempat menampung ulasan tamu bos!
  
  // Akumulasi rating dari seluruh produk warung ini bos!
  var storeAverageRating = 0.0.obs;
  var storeTotalReviews = 0.obs;

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = supabase.auth.currentUser != null;
    supabase.auth.onAuthStateChange.listen((data) {
      isLoggedIn.value = data.session != null;
    });

    // Ambil productId tiap kali controller diinisialisasi
    final productId = Get.arguments; 
    if (productId != null) {
      fetchDetail(productId);
    }
  }

  // Penting: Pas ganti halaman, hapus data lama biar kaga muncul data hantu
  @override
  void onClose() {
    productData.clear();
    umkmData.clear();
    reviews.clear();
    storeAverageRating.value = 0.0;
    storeTotalReviews.value = 0;
    super.onClose();
  }

  Future<void> fetchDetail(String productId) async {
    try {
      isLoading(true);
      
      // SIHIR SUPABASE: Tarik data produk join tabel umkm dan ulasan
      final response = await supabase
          .from('products')
          .select('*, umkm(*), product_reviews(*)') 
          .eq('id', productId)
          .maybeSingle(); // Pake maybeSingle biar ga crash kalau ID salah

      if (response != null) {
        productData.value = response;
        umkmData.value = response['umkm'] ?? {}; // Data warung masuk sini
        
        final reviewList = response['product_reviews'] as List? ?? [];
        // Urutkan review berdasarkan tanggal terbaru
        reviewList.sort((a, b) => b['created_at'].toString().compareTo(a['created_at'].toString()));
        reviews.value = reviewList;

        // Tarik akumulasi ulasan dari seluruh produk toko ini bos!
        await fetchStoreAccumulatedRating(umkmData['id']);
      } else {
        Get.snackbar('Waduh', 'Data produk kaga ada bos!');
      }
      
    } catch (e) {
      Get.snackbar('Error', 'Gagal narik data detail: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // Fungsi hitung akumulasi ulasan toko dinamis
  Future<void> fetchStoreAccumulatedRating(String? storeId) async {
    if (storeId == null) return;
    try {
      final allStoreProducts = await supabase
          .from('products')
          .select('*, product_reviews(*)')
          .eq('umkm_id', storeId);
      
      double totalRating = 0.0;
      int reviewCount = 0;
      for (var p in allStoreProducts as List) {
        final revs = p['product_reviews'] as List? ?? [];
        for (var r in revs) {
          totalRating += (r['rating'] as num).toDouble();
          reviewCount++;
        }
      }
      
      storeAverageRating.value = reviewCount > 0 
          ? double.parse((totalRating / reviewCount).toStringAsFixed(1)) 
          : 0.0;
      storeTotalReviews.value = reviewCount;
    } catch (e) {
      storeAverageRating.value = 0.0;
      storeTotalReviews.value = 0;
    }
  }

  // Fungsi kirim ulasan dari Tamu
  Future<void> submitReview(int rating, String komentar, String username) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      Get.snackbar('Waduh', 'Harus login dulu bos buat ngasih ulasan!', backgroundColor: Colors.orange.shade100, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final productId = Get.arguments;
    if (productId == null) return;
    
    try {
      isLoading(true);
      
      final reviewerName = username.trim().isEmpty 
          ? (user.email?.split('@').first ?? 'Pengguna')
          : username.trim();

      await supabase.from('product_reviews').insert({
        'product_id': productId,
        'rating': rating,
        'komentar': komentar.trim(),
        'username': reviewerName,
      });
      
      // Muat ulang detail produk agar rating bintang utama dan komentar langsung ter-update reaktif!
      await fetchDetail(productId);
      
      // Update juga HomeController agar halaman utama menampilkan rating bintang terbaru secara dinamis!
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchProducts();
      }
      
      Get.snackbar(
        'Sip!', 
        'Ulasan kamu berhasil dikirim, makasih ya!', 
        backgroundColor: Colors.green.shade100,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Gagal kirim', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isLoading(false);
    }
  }

  // Fungsi buka Google Maps
  Future<void> openGoogleMaps() async {
    final lat = umkmData['latitude'];
    final lng = umkmData['longitude'];
    
    if (lat == null || lng == null) {
      Get.snackbar('Waduh', 'Titik lokasi belum disetting sama abang warungnya!', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Link maps yang bener buat koordinat
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication); 
    } else {
      Get.snackbar('Error', 'Gagal buka Maps, cek browser atau aplikasi Maps lu bos.');
    }
  }

  // Fungsi buka WhatsApp
  Future<void> openWhatsApp() async {
    var rawPhone = umkmData['no_telepon'];
    if (rawPhone == null || rawPhone.toString().trim().isEmpty) {
      Get.snackbar('Waduh', 'Abang warung belum masukin nomor WhatsApp-nya bos!', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Format nomor HP ke standar wa.me
    String phone = rawPhone.toString().trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('0')) {
      phone = '62$phone';
    }

    final url = Uri.parse('https://wa.me/$phone?text=Halo%20saya%20tertarik%20dengan%20jajanan%20Anda!');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Gagal buka WhatsApp, pastiin aplikasinya udah keinstall bos.');
    }
  }
}
