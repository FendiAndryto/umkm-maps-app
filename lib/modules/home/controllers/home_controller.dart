import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:umkm_maps_app/data/models/product_model.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;

  // Map & Page Controllers
  var mapController = MapController();
  late final PageController mapPageController;
  var selectedUmkmIndex = 0.obs;

  void initMapController() {
    mapController = MapController();
  }

  // Master data (buat nyimpen semua data asli dari Supabase)
  var _allProducts = <ProductModel>[];

  // RxList buat di-render di UI (bisa berubah pas di-search)
  var promoProducts = <ProductModel>[].obs;
  var regularProducts = <ProductModel>[].obs;
  
  // Variabel buat nampung teks search bar
  var searchQuery = ''.obs;
  
  // Tambahan filter kategori reaktif bos!
  var selectedCategory = 'Semua'.obs;
  var categories = <String>['Semua'].obs; // Sekarang dynamic bos!

  var isLoading = true.obs;

  // Bottom Navigation Tab Index
  var selectedTabIndex = 0.obs;

  // List UMKM untuk map in-app
  var umkmList = <dynamic>[].obs;
  
  List<dynamic> get activeUmkmList => umkmList
      .where((u) => u['latitude'] != null && u['longitude'] != null)
      .toList();

  // Titik tengah Mapcn
  var mapCenter = const LatLng(-6.2088, 106.8456).obs; // Default Jakarta

  // Fungsi mengambil data warung UMKM dari Supabase
  Future<void> fetchUmkm() async {
    try {
      final response = await supabase.from('umkm').select();
      umkmList.value = response as List;
    } catch (e) {
      // Handle silently
    }
  }

  // Menentukan titik tengah peta berdasarkan warung terdekat atau GPS user
  Future<void> determineMapCenter() async {
    final active = activeUmkmList;
    if (active.isNotEmpty) {
      final lat = double.tryParse(active.first['latitude'].toString());
      final lng = double.tryParse(active.first['longitude'].toString());
      if (lat != null && lng != null) {
        final pos = LatLng(lat, lng);
        mapCenter.value = pos;
        selectedUmkmIndex.value = 0;
        
        try {
          mapController.move(pos, 14.0);
        } catch (e) {
          // Ignored: Map not rendered yet
        }
        
        if (mapPageController.hasClients) {
          mapPageController.jumpToPage(0);
        }
        return;
      }
    }
    
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final userPos = LatLng(pos.latitude, pos.longitude);
      mapCenter.value = userPos;
      
      try {
        mapController.move(userPos, 14.0);
      } catch (e) {
        // Ignored: Map not rendered yet
      }
    } catch (e) {
      // Fallback
    }
  }

  // Animasi ke koordinat toko tertentu & sinkronisasi dengan bottom sheet card
  void animateToStore(int index, LatLng latLng) {
    selectedUmkmIndex.value = index;
    mapCenter.value = latLng;
    
    try {
      mapController.move(latLng, 14.5);
    } catch (e) {
      // Ignored: Map not rendered yet
    }
    
    if (mapPageController.hasClients) {
      mapPageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Fungsi buka Google Maps untuk mencari warung UMKM terdekat
  Future<void> openGoogleMaps() async {
    try {
      final response = await supabase.from('umkm').select();
      if ((response as List).isNotEmpty) {
        for (var store in response) {
          final lat = store['latitude'];
          final lng = store['longitude'];
          if (lat != null && lng != null) {
            final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
              return;
            }
          }
        }
      }
    } catch (e) {
      // Fallback
    }

    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=UMKM+Jajanan');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Gagal buka Google Maps.');
    }
  }

  @override
  void onInit() {
    super.onInit();
    mapPageController = PageController(viewportFraction: 0.85);
    fetchProducts();
    fetchCategories(); // Ambil kategori dinamis!
  }

  @override
  void onClose() {
    mapPageController.dispose();
    mapController.dispose();
    super.onClose();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('categories').select().order('name');
      final list = (response as List).map((e) => e['name'] as String).toList();
      
      // Hapus 'Lainnya' dari daftar terurut dan letakkan selalu di paling akhir
      list.remove('Lainnya');
      categories.value = ['Semua', ...list, 'Lainnya'];
    } catch (e) {
      // Fallback jika database belum disetup
      categories.value = ['Semua', 'Makanan', 'Minuman', 'Cemilan', 'Lainnya'];
    }
  }

  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      
      final response = await supabase.from('products').select('*, product_reviews(*)');
      
      // Simpan ke master data dulu bos
      _allProducts = (response as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
      
      // Panggil fungsi filter buat misah data pertama kali
      _filterProducts();

      // Ambil data warung UMKM untuk peta in-app
      await fetchUmkm();
      await determineMapCenter();
      
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

  void selectCategory(String category) {
    selectedCategory.value = category; // Ganti filter kategori terpilih
    _filterProducts();                 // Jalankan filter
  }

  void _filterProducts() {
    List<ProductModel> filtered = _allProducts;

    // 1. Filter berdasarkan Kategori (jika bukan 'Semua')
    if (selectedCategory.value != 'Semua') {
      filtered = filtered.where((p) => p.kategori == selectedCategory.value).toList();
    }

    // 2. Filter berdasarkan keyword pencarian (jika tidak kosong)
    if (searchQuery.isNotEmpty) {
      String keyword = searchQuery.value.toLowerCase();
      filtered = filtered.where((p) => p.namaProduk.toLowerCase().contains(keyword)).toList();
    }

    // 3. Pisahkan antara produk promo dan produk reguler
    promoProducts.value = filtered.where((p) => p.isPromo).toList();
    regularProducts.value = filtered.where((p) => !p.isPromo).toList();
  }

  // --- REFRESH DATA MANUAL ---
  Future<void> refreshData() async {
    await fetchCategories();
    await fetchProducts();
  }
}
