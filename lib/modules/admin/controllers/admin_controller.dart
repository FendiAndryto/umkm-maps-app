import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:umkm_maps_app/modules/home/controllers/home_controller.dart';

class AdminController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = true.obs;
  var currentTabIndex = 0.obs;
  
  // Variabel buat nampung data UMKM
  var allUmkm = [].obs;
  var pendingUmkm = [].obs;
  var approvedUmkm = [].obs;
  var rejectedUmkm = [].obs;
  
  // Statistik buat Dashboard Dewa
  var totalUmkm = 0.obs;

  // Kelola Kategori Dinamis
  var categoriesList = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllUmkm();
    fetchCategories(); // Tarik kategori juga bos!
  }

  // --- FUNGSI TARIK SEMUA DATA ---
  Future<void> fetchAllUmkm() async {
    try {
      isLoading(true);
      
      // Tarik semua data UMKM join profiles buat dapet email
      final response = await supabase
          .from('umkm')
          .select('*, profiles(email)')
          .order('created_at', ascending: false);
          
      final data = response as List;
      
      // Update Statistik & List Utama
      allUmkm.value = data;
      totalUmkm.value = data.length;
      
      // Filter datanya secara lokal biar lincah dan ga berat ke server
      pendingUmkm.value = data.where((e) => e['status_verifikasi'] == 'pending').toList();
      approvedUmkm.value = data.where((e) => e['status_verifikasi'] == 'approved').toList();
      rejectedUmkm.value = data.where((e) => e['status_verifikasi'] == 'rejected').toList();
      
    } catch (e) {
      Get.snackbar('Error', 'Gagal narik antrean: $e');
    } finally {
      isLoading(false);
    }
  }

  // --- FUNGSI INTIP BERKAS RAHASIA ---
  Future<String> getSuratUrl(String? fileName) async {
    if (fileName == null || fileName.isEmpty) return '';
    try {
      // Bikin link sementara yang bakal mati dalam 60 detik
      return await supabase.storage
          .from('dokumen-legal')
          .createSignedUrl(fileName, 60); 
    } catch (e) {
      return '';
    }
  }

  // --- FUNGSI EKSEKUSI STATUS (ACC/TOLAK) ---
  Future<void> eksekusiWarung(String umkmId, String statusBaru) async {
    try {
      await supabase
          .from('umkm')
          .update({'status_verifikasi': statusBaru})
          .eq('id', umkmId);
          
      Get.snackbar('Sip!', 'Warung resmi di-$statusBaru bos!');
      
      // Tarik ulang data biar statistik & list langsung update
      fetchAllUmkm(); 
    } catch (e) {
      Get.snackbar('Error', 'Gagal eksekusi: $e');
    }
  }

  // --- FUNGSI CRUD KATEGORI DINAMIS ---
  
  Future<void> fetchCategories() async {
    try {
      final response = await supabase
          .from('categories')
          .select()
          .order('name');
      categoriesList.value = response as List;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat kategori: $e');
    }
  }

  Future<void> addCategory(String name) async {
    if (name.trim().isEmpty) return;
    try {
      await supabase.from('categories').insert({'name': name.trim()});
      fetchCategories();
      
      // Auto-update kategori di halaman utama secara real-time
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchCategories();
      }
      
      Get.snackbar('Sukses', 'Kategori baru "$name" berhasil ditambahkan!');
    } catch (e) {
      Get.snackbar('Error', 'Gagal tambah kategori: $e');
    }
  }

  Future<void> updateCategory(String id, String oldName, String newName) async {
    if (newName.trim().isEmpty || oldName == newName.trim()) return;
    try {
      final cleanNewName = newName.trim();
      
      // 1. Update nama di tabel categories
      await supabase.from('categories').update({'name': cleanNewName}).eq('id', id);
      
      // 2. Cascading update manual di tabel products agar produk ikut terupdate kategori-nya
      await supabase.from('products').update({'kategori': cleanNewName}).eq('kategori', oldName);
      
      fetchCategories();
      
      // Auto-update kategori & produk di halaman utama secara real-time
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        homeCtrl.fetchCategories();
        homeCtrl.fetchProducts();
      }
      
      Get.snackbar('Sukses', 'Kategori "$oldName" berhasil diubah menjadi "$cleanNewName"!');
    } catch (e) {
      Get.snackbar('Error', 'Gagal ubah kategori: $e');
    }
  }

  Future<void> deleteCategory(String id, String name) async {
    try {
      // 1. Hapus dari tabel categories
      await supabase.from('categories').delete().eq('id', id);
      
      // 2. Set kategori produk terkait ke 'Lainnya' biar ga kosong/null
      await supabase.from('products').update({'kategori': 'Lainnya'}).eq('kategori', name);
      
      fetchCategories();
      
      // Auto-update kategori & produk di halaman utama secara real-time
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        homeCtrl.fetchCategories();
        homeCtrl.fetchProducts();
      }
      
      Get.snackbar('Sukses', 'Kategori "$name" berhasil dihapus!');
    } catch (e) {
      Get.snackbar('Error', 'Gagal hapus kategori: $e');
    }
  }

  // --- LOGOUT ADMIN ---
  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAllNamed('/login');
  }
}
