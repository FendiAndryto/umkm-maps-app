import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product_model.dart';

class ProfileUmkmController extends GetxController {
  final supabase = Supabase.instance.client;
  
  var isLoading = true.obs;
  var umkmData = {}.obs; // Nampung data toko
  var storeProducts = <ProductModel>[].obs; // Produk milik toko ini

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

      // 2. Ambil Semua Produk Toko Ini
      final productsResponse = await supabase
          .from('products')
          .select()
          .eq('umkm_id', id);

      storeProducts.value = (productsResponse as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();

    } catch (e) {
      Get.snackbar('Error', 'Gagal ambil profil toko: $e');
    } finally {
      isLoading(false);
    }
  }
}