import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailUmkmController extends GetxController {
  final supabase = Supabase.instance.client;
  
  var isLoading = true.obs;
  
  // Data reaktif buat produk dan toko
  var productData = {}.obs;
  var umkmData = {}.obs;

  @override
  void onInit() {
    super.onInit();
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
    super.onClose();
  }

  Future<void> fetchDetail(String productId) async {
    try {
      isLoading(true);
      
      // SIHIR SUPABASE: Tarik data produk join tabel umkm
      final response = await supabase
          .from('products')
          .select('*, umkm(*)') 
          .eq('id', productId)
          .maybeSingle(); // Pake maybeSingle biar ga crash kalau ID salah

      if (response != null) {
        productData.value = response;
        umkmData.value = response['umkm'] ?? {}; // Data warung masuk sini
      } else {
        Get.snackbar('Waduh', 'Data produk kaga ada bos!');
      }
      
    } catch (e) {
      Get.snackbar('Error', 'Gagal narik data detail: $e', snackPosition: SnackPosition.BOTTOM);
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
}