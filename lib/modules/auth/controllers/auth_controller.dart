import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Wajib ada buat GPS bos!

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;
  
  var isLoading = false.obs;
  var isLogin = true.obs; // Toggle Login/Register
  
  // --- TAMBAHAN BARU: Variabel buat nampung role ---
  var selectedRole = 'pengguna'.obs;

  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final namaTokoController = TextEditingController(); 
  final noTeleponController = TextEditingController(); // Tambahan nomor telepon bos!

  // File Holder buat Surat Izin
  var selectedSurat = Rxn<File>();

  // --- TAMBAHAN BARU: Variabel buat nampung lokasi GPS ---
  var lat = 0.0.obs;
  var lng = 0.0.obs;
  var isLocationPicked = false.obs;

  // Fungsi ganti mode Login/Register
  void toggleMode() {
    isLogin.value = !isLogin.value;
    // Bersihin form biar ga nyisa data lama
    emailController.clear();
    passwordController.clear();
    namaTokoController.clear();
    noTeleponController.clear(); // Bersihin nomor telepon bos!
    selectedSurat.value = null;
    
    // Bersihin juga titik GPS-nya!
    lat.value = 0.0;
    lng.value = 0.0;
    isLocationPicked.value = false;
  }

  // Fungsi nampilin popup pilih role
  void showRoleSelectionDialog() {
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
              'Pilih Jenis Akun',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                selectedRole.value = 'pengguna';
                Get.back();
                if (isLogin.value) toggleMode();
              },
              icon: const Icon(Icons.person_outline, size: 24),
              label: const Text('Pengguna Biasa (Pemberi Rating)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.centerLeft,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                selectedRole.value = 'umkm';
                Get.back();
                if (isLogin.value) toggleMode();
              },
              icon: const Icon(Icons.storefront_outlined, size: 24),
              label: const Text('Pemilik UMKM (Daftar Warung)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.centerLeft,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Fungsi ambil foto dari galeri
  Future<void> pickSurat() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 70
    );
    
    if (pickedFile != null) {
      selectedSurat.value = File(pickedFile.path);
    }
  }

  // --- TAMBAHAN BARU: Fungsi Nembak GPS ---
  Future<void> getCurrentLocation() async {
    try {
      isLoading(true);
      
      // 1. Cek izin GPS ke satpam Android
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Waduh', 'Izin lokasi lu tolak permanen bos, buka setting HP manual gih!', backgroundColor: Colors.red.shade100);
        return;
      }

      // 2. Tembak koordinat!
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );

      lat.value = position.latitude;
      lng.value = position.longitude;
      isLocationPicked.value = true;

      Get.snackbar('Sukses', 'Lokasi warung terkunci bos!\nLat: ${lat.value}\nLng: ${lng.value}', backgroundColor: Colors.green.shade100);
    } catch (e) {
      Get.snackbar('Error GPS', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isLoading(false);
    }
  }

  // Eksekusi Tombol Submit
  Future<void> submit() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Waduh', 'Email sama password jangan dikosongin bos!', 
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading(true);
      
      if (isLogin.value) {
        // --- PROSES LOGIN ---
        final res = await supabase.auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        
        if (res.user != null) {
          // 1. Cek dulu jabatan dia di tabel profiles
          var profile = await supabase
              .from('profiles')
              .select('role')
              .eq('id', res.user!.id)
              .maybeSingle();
              
          // Kalau profile-nya nyangkut/nggak ada (karena error constraint sebelumnya), kita bikinin otomatis
          if (profile == null) {
            await supabase.from('profiles').insert({
              'id': res.user!.id,
              'email': res.user!.email,
              'role': 'pengguna',
            });
            profile = {'role': 'pengguna'};
          }
          
          Get.snackbar('Sukses', 'Berhasil masuk bos!');
          
          // 2. Pisahin jalurnya pake logika IF!
          if (profile['role'] == 'admin') {
            Get.offAllNamed('/dashboard-admin'); 
          } else if (profile['role'] == 'umkm') {
            Get.offAllNamed('/dashboard-umkm'); 
          } else {
            Get.offAllNamed('/'); 
          }
        }
      } else {
        // --- PROSES REGISTER UMKM ---
        if (selectedRole.value == 'umkm') {
          if (namaTokoController.text.isEmpty) {
            Get.snackbar('Waduh', 'Nama toko wajib diisi bos!');
            return;
          }
          if (noTeleponController.text.trim().isEmpty) {
            Get.snackbar('Waduh', 'Nomor telepon wajib diisi bos!', 
                backgroundColor: Colors.orange.shade100);
            return;
          }
          if (selectedSurat.value == null) {
            Get.snackbar('Ilegal Lu?', 'Surat izin dari kecamatan wajib ada!', 
                backgroundColor: Colors.orange.shade100);
            return;
          }
          // --- CEK LOKASI JUGA SEBELUM DI-ACC DAFTAR ---
          if (!isLocationPicked.value) {
            Get.snackbar('Buset', 'Lokasi warung lu di mana? Pencet tombol Ambil GPS dulu bos!', 
                backgroundColor: Colors.orange.shade100);
            return;
          }
        }
        
        // 1. Daftar ke Auth Supabase
        final res = await supabase.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        
        if (res.user != null) {
          final userId = res.user!.id;

          // 2. Suntik data ke tabel Profiles
          await supabase.from('profiles').insert({
            'id': userId,
            'email': res.user!.email,
            'role': selectedRole.value,
          });

          if (selectedRole.value == 'umkm') {
            // 3. Upload Surat Izin ke Bucket Private
            final file = selectedSurat.value!;
            final fileExt = file.path.split('.').last;
            final fileName = '${userId}_surat.$fileExt';
            
            await supabase.storage.from('dokumen-legal').upload(
              fileName,
              file,
              fileOptions: const FileOptions(upsert: true),
            );
            
            // 4. Suntik data ke tabel UMKM
            await supabase.from('umkm').insert({
              'user_id': userId,
              'nama_toko': namaTokoController.text.trim(),
              'status_verifikasi': 'pending', 
              'surat_izin_url': fileName, 
              'latitude': lat.value,   
              'longitude': lng.value,  
              'no_telepon': noTeleponController.text.trim(), 
            });
            
            Get.snackbar('Mantap!', 'Pendaftaran sukses. Tunggu divalidasi admin ya.', 
                snackPosition: SnackPosition.BOTTOM);
          } else {
             Get.snackbar('Mantap!', 'Pendaftaran berhasil. Silakan masuk.', 
                snackPosition: SnackPosition.BOTTOM);
          }
          toggleMode(); // Balikin ke mode login
        }
      }
    } on AuthException catch (e) {
      Get.snackbar('Gagal', e.message, backgroundColor: Colors.red.shade100);
    } catch (e) {
      Get.snackbar('Error', 'Ada masalah: $e', backgroundColor: Colors.red.shade100);
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    namaTokoController.dispose();
    noTeleponController.dispose(); // Hapus juga bos!
    super.onClose();
  }
}
