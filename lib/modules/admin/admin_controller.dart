import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = true.obs;
  
  // Variabel buat nampung data UMKM
  var allUmkm = [].obs;
  var pendingUmkm = [].obs;
  var approvedUmkm = [].obs;
  var rejectedUmkm = [].obs;
  
  // Statistik buat Dashboard Dewa
  var totalUmkm = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllUmkm();
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

  // --- LOGOUT ADMIN ---
  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAllNamed('/login');
  }
}