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

  // State autentikasi dinamis
  var isLoggedIn = false.obs;
  var userProfile = {}.obs;

  // List UMKM untuk map in-app
  var umkmList = <dynamic>[].obs;
  var topUmkmList = <Map<String, dynamic>>[].obs;
  
  List<dynamic> get activeUmkmList => umkmList
      .where((u) => u['latitude'] != null && u['longitude'] != null && u['status_verifikasi'] != 'rejected')
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

  void _calculateTopUmkm() {
    final List<Map<String, dynamic>> computedList = [];
    
    // Hanya kalkulasi UMKM yang statusnya bukan ditolak
    for (var u in umkmList.where((u) => u['status_verifikasi'] != 'rejected')) {
      final umkmId = u['id'];
      final umkmProducts = _allProducts.where((p) => p.umkmId == umkmId).toList();
      
      double totalRating = 0.0;
      int reviewsCount = 0;
      for (var p in umkmProducts) {
        if (p.totalReviews > 0) {
          totalRating += (p.averageRating * p.totalReviews);
          reviewsCount += p.totalReviews;
        }
      }
      
      double avgRating = reviewsCount > 0 ? (totalRating / reviewsCount) : 0.0;
      
      computedList.add({
        ...(u as Map<String, dynamic>),
        'computed_rating': double.parse(avgRating.toStringAsFixed(1)),
        'reviews_count': reviewsCount,
      });
    }
    
    computedList.sort((a, b) => (b['computed_rating'] as double).compareTo(a['computed_rating'] as double));
    topUmkmList.value = computedList;
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
    _checkLoginStatus();
    fetchProducts();
    fetchCategories(); // Ambil kategori dinamis!
  }

  Future<void> _checkLoginStatus() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      isLoggedIn.value = true;
      try {
        final profile = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
        if (profile != null) userProfile.value = profile;
      } catch(e) {
        // Abaikan
      }
    }
    
    supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn && data.session != null) {
        isLoggedIn.value = true;
        try {
          final profile = await supabase.from('profiles').select().eq('id', data.session!.user.id).maybeSingle();
          if (profile != null) userProfile.value = profile;
        } catch(e) {
          // Abaikan
        }
      } else if (event == AuthChangeEvent.signedOut) {
        isLoggedIn.value = false;
        userProfile.clear();
      }
    });
  }

  void handleProfileTab() {
    if (isLoggedIn.value) {
      final role = userProfile['role'];
      if (role == 'admin') {
        Get.offAllNamed('/dashboard-admin');
      } else if (role == 'umkm') {
        Get.offAllNamed('/dashboard-umkm');
      } else {
        _showProfileBottomSheet();
      }
    } else {
      Get.toNamed('/login');
    }
  }

  void _showProfileBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Profil Akun',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              supabase.auth.currentUser?.email ?? 'Pengguna',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await supabase.auth.signOut();
                Get.back();
                Get.snackbar('Sukses', 'Berhasil logout bos!', backgroundColor: Colors.green.shade100);
              },
              icon: const Icon(Icons.logout, size: 24),
              label: const Text('Keluar (Logout)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
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
      
      // Ambil data warung UMKM untuk peta in-app dan validasi status terlebih dahulu
      await fetchUmkm();
      await determineMapCenter();
      _calculateTopUmkm();

      // Panggil fungsi filter buat misah data setelah data UMKM lengkap
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

  void selectCategory(String category) {
    selectedCategory.value = category; // Ganti filter kategori terpilih
    _filterProducts();                 // Jalankan filter
  }

  void _filterProducts() {
    // 1. Filter awal: Jangan tampilkan produk dari UMKM yang ditolak (rejected)
    final allowedUmkmIds = umkmList
        .where((u) => u['status_verifikasi'] != 'rejected')
        .map((u) => u['id'].toString())
        .toSet();

    List<ProductModel> filtered = _allProducts
        .where((p) => allowedUmkmIds.contains(p.umkmId))
        .toList();

    // 2. Filter berdasarkan Kategori (jika bukan 'Semua')
    if (selectedCategory.value != 'Semua') {
      filtered = filtered.where((p) => p.kategori == selectedCategory.value).toList();
    }

    // 2. Filter berdasarkan keyword pencarian (jika tidak kosong)
    if (searchQuery.isNotEmpty) {
      String keyword = searchQuery.value.toLowerCase();
      filtered = filtered.where((p) => p.namaProduk.toLowerCase().contains(keyword)).toList();
    }

    // 3. Urutkan produk berdasarkan rating tertinggi ke terendah
    filtered.sort((a, b) => b.averageRating.compareTo(a.averageRating));

    // 4. Pisahkan antara produk promo dan produk reguler
    promoProducts.value = filtered.where((p) => p.isPromo).toList();
    regularProducts.value = filtered.where((p) => !p.isPromo).toList();
  }

  // --- REFRESH DATA MANUAL ---
  Future<void> refreshData() async {
    await fetchCategories();
    await fetchProducts();
  }
}
