import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product_model.dart'; // Sesuaikan path-nya bos!

class GuestController extends GetxController {
  final supabase = Supabase.instance.client;

  // Master data (buat nyimpen semua data asli dari Supabase)
  var _allProducts = <ProductModel>[];

  // RxList buat di-render di UI (bisa berubah pas di-search)
  var promoProducts = <ProductModel>[].obs;
  var regularProducts = <ProductModel>[].obs;
  
  // Variabel buat nampung teks search bar
  var searchQuery = ''.obs;
  
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      
      final response = await supabase.from('products').select();
      
      // Simpan ke master data dulu bos
      _allProducts = (response as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
      
      // Panggil fungsi filter buat misah data pertama kali
      _filterProducts();
      
    } catch (e) {
      Get.snackbar(
        'Waduh Error Bos!', 
        'Gagal narik data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // --- INI FUNGSI BARU BUAT SEARCH & FILTER NYA ---
  void searchProduct(String query) {
    searchQuery.value = query; // Update teks search
    _filterProducts();         // Jalankan filternya bos!
  }

  void _filterProducts() {
    if (searchQuery.isEmpty) {
      // Kalo search bar kosong, tampilin semua produk asli
      promoProducts.value = _allProducts.where((p) => p.isPromo).toList();
      regularProducts.value = _allProducts.where((p) => !p.isPromo).toList();
    } else {
      // Kalo user ngetik, filter berdasarkan nama_product (lowercase biar ga sensitif)
      String keyword = searchQuery.value.toLowerCase();
      
      promoProducts.value = _allProducts
          .where((p) => p.isPromo && p.namaProduk.toLowerCase().contains(keyword))
          .toList();

      regularProducts.value = _allProducts
          .where((p) => !p.isPromo && p.namaProduk.toLowerCase().contains(keyword))
          .toList();
    }
  }
}