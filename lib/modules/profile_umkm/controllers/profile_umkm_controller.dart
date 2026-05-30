import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:umkm_maps_app/data/models/product_model.dart';

class ProfileUmkmController extends GetxController {
  final supabase = Supabase.instance.client;
  
  var isLoading = true.obs;
  var umkmData = {}.obs; // Nampung data toko
  var storeProducts = <ProductModel>[].obs; // Produk milik toko ini
  
  // Akumulasi rating dari seluruh produk warung ini bos!
  var storeAverageRating = 0.0.obs;
  var storeTotalReviews = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil umkmId yang dikirim pas pindah halaman
    String umkmId = Get.arguments;
    fetchStoreData(umkmId);
  }

  Future<void> fetchStoreData(String id) async {
    try {
      isLoading(true);

      // 1. Ambil Data Profil UMKM
      final storeResponse = await supabase
          .from('umkm')
          .select()
          .eq('id', id)
          .single();
      umkmData.value = storeResponse;

      // 2. Ambil Semua Produk Toko Ini (join ulasan agar rating terlihat di profil toko)
      final productsResponse = await supabase
          .from('products')
          .select('*, product_reviews(*)')
          .eq('umkm_id', id);

      storeProducts.value = (productsResponse as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();

      // Hitung total akumulasi rating dari semua produk warung ini bos!
      double totalRating = 0.0;
      int reviewCount = 0;
      for (var p in productsResponse as List) {
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
      Get.snackbar('Error', 'Gagal ambil profil toko: $e');
    } finally {
      isLoading(false);
    }
  }

  // Fungsi buka WhatsApp langsung dari Profil Toko
  Future<void> openWhatsApp() async {
    var rawPhone = umkmData['no_telepon'];
    if (rawPhone == null || rawPhone.toString().trim().isEmpty) {
      Get.snackbar('Waduh', 'Abang warung belum masukin nomor WhatsApp-nya bos!', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Format nomor HP ke standar wa.me
    String phone = rawPhone.toString().trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    }

    final url = Uri.parse('https://wa.me/$phone?text=Halo%20saya%20tertarik%20dengan%20warung%20jajanan%20Anda!');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Gagal buka WhatsApp, pastiin aplikasinya udah keinstall bos.');
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

    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication); 
    } else {
      Get.snackbar('Error', 'Gagal buka Maps, cek browser atau aplikasi Maps lu bos.');
    }
  }
}
