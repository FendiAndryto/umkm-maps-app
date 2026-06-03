# 🌟 UMKM Maps App 📍

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![GetX](https://img.shields.io/badge/GetX-%236600FF.svg?style=for-the-badge)](https://pub.dev/packages/get)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Aplikasi Promosi & Pemetaan Lokasi UMKM Berbasis **Flutter** & **Supabase** dengan Desain Modern, Clean, dan Premium.

---

## 📖 Tentang Projek

**UMKM Maps App** adalah solusi digital inovatif yang dirancang untuk membantu memperluas jangkauan pemasaran Usaha Mikro, Kecil, dan Menengah (UMKM) lokal. Aplikasi ini memetakan lokasi fisik warung/toko UMKM secara presisi menggunakan koordinat GPS, memudahkan pengunjung (Visitor) mencari produk/layanan terdekat secara real-time, serta menyediakan portal khusus bagi pemilik toko (Merchant) dan Administrator untuk mengelola ekosistem secara tertib.

---

## ⚡ Fitur Utama

### 🗺️ 1. Peta Interaktif & Navigasi (In-App Maps)
- **Visualisasi GPS Real-Time**: Pemetaan otomatis toko UMKM terverifikasi di atas peta interaktif berbasis `flutter_map` (OpenStreetMap).
- **Sinkronisasi Slider Toko**: Sentuh penanda (*marker*) pada peta untuk menggeser info kartu toko di bagian bawah secara otomatis, atau sebaliknya.
- **Navigasi Google Maps**: Kemudahan membuka koordinat presisi toko langsung di Google Maps untuk panduan arah rute jalan.

### 🔍 2. Eksplorasi & Pencarian Pengunjung (Visitor Portal)
- **Pencarian Produk Instan**: Kolom pencarian teks reaktif yang menyaring produk secara real-time.
- **Filter Kategori Dinamis**: Mengelompokkan produk berdasarkan kategori yang dikelola langsung dari database (seperti Makanan, Minuman, Cemilan, dll.).
- **Etalase Promo & Reguler**: Pemisahan visual produk promo (harga diskon) dengan produk reguler agar menarik minat beli.
- **Rating & Ulasan Pembeli**: Pengunjung dapat memberikan rating (1-5 bintang) beserta ulasan tertulis pada detail produk.

### 🔑 3. Portal Mitra UMKM (Merchant Portal)
- **Pendaftaran Berbasis GPS**: Integrasi pengambilan koordinat lintang (*latitude*) & bujur (*longitude*) saat pendaftaran melalui GPS HP.
- **Unggah Berkas Izin**: Sistem unggahan surat izin usaha dari kecamatan ke server Supabase Storage privat untuk proses verifikasi keabsahan warung.
- **Kelola Info & Foto Profil**: Merchant dapat mengunggah foto profil toko (dengan kompresi resolusi optimal) dan memperbarui deskripsi atau koordinat GPS terbaru.
- **Manajemen Produk (CRUD Inventory)**: Tambah, edit, dan hapus barang dagangan lengkap dengan harga, kategori dinamis, status promo, dan foto produk.
- **Moderasi Ulasan**: Memantau ulasan yang masuk pada produk warung dan menghapus ulasan yang kurang sesuai.

### 🛡️ 4. Panel Kontrol Administrator (Admin Console)
- **Dashboard Statistik**: Memantau grafik pertumbuhan/total toko UMKM terdaftar.
- **Verifikasi Berkas**: Menginspeksi surat izin legalitas milik merchant pendaftar baru dan melakukan aksi verifikasi (*Approve* / *Reject*).
- **CRUD Kategori Dinamis**: Mengelola kategori produk global yang akan ter-update secara otomatis di sisi merchant maupun halaman pencarian pengunjung dengan cascading update aman.

---

## 🎨 Sistem Desain & Estetika (Design System)

Aplikasi dibangun mengikuti panduan visual terpadu pada [DESIGN.md](file:///c:/Users/pendi/Repository/umkm_maps_app/DESIGN.md) untuk menciptakan antarmuka premium:
*   **Warna Utama**: Teal 600 (`#0D9488`) melambangkan profesionalitas dan kebersihan.
*   **Warna Aksen**: Amber 500 (`#F59E0B`) digunakan untuk tanda promo, harga menarik, dan rating bintang.
*   **Warna Latar**: Slate 50 (`#F8FAFC`) untuk kesan minimalis, dipadukan dengan Card putih berbayangan lembut (`BoxShadow` premium).
*   **Tipografi**: Menggunakan font modern `Plus Jakarta Sans` dari Google Fonts dengan hierarki ukuran yang proporsional.
*   **Konsistensi Radius**: Sudut melengkung halus pada komponen (`radiusMd: 12.0`, `radiusLg: 16.0`) untuk visual yang bersahabat dan modern.

---

## 🛠️ Stack Teknologi & Pustaka

- **Framework**: [Flutter SDK](https://flutter.dev/) (Dart)
- **State Management & Routing**: [GetX](https://pub.dev/packages/get)
- **Backend-as-a-Service (BaaS)**: [Supabase](https://supabase.com/)
  - Supabase Auth (Autentikasi & Registrasi User)
  - Supabase Database (Penyimpanan data relasional PostgreSQL)
  - Supabase Storage (Penyimpanan foto produk & dokumen perizinan)
- **Pemetaan & Geolocation**:
  - `flutter_map` & `latlong2` (Render visual peta OSM)
  - `geolocator` (Penguncian koordinat GPS HP secara akurat)
  - `geocoding` (Reverse geocoding koordinat GPS menjadi alamat tertulis)
- **Penanganan Gambar**:
  - `image_picker` (Pengambilan foto lewat galeri HP dengan penyesuaian resolusi dan kompresi kualitas).

---

## 🗄️ Referensi Skema Database Supabase

Untuk menjalankan aplikasi ini dengan baik, berikut adalah rancangan tabel database PostgreSQL pada Supabase Anda:

### 1. Tabel `profiles`
Menyimpan hak akses (role) pengguna.
```sql
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text not null,
  role text not null check (role in ('admin', 'umkm')) default 'umkm',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
```

### 2. Tabel `umkm`
Menyimpan informasi profil toko dan lokasi GPS.
```sql
create table public.umkm (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  nama_toko text not null,
  deskripsi text,
  no_telepon text,
  foto_profil text,
  status_verifikasi text check (status_verifikasi in ('pending', 'approved', 'rejected')) default 'pending' not null,
  surat_izin_url text,
  latitude double precision,
  longitude double precision,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
```

### 3. Tabel `categories`
Menyimpan daftar kategori produk secara dinamis.
```sql
create table public.categories (
  id uuid default gen_random_uuid() primary key,
  name text unique not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
```

### 4. Tabel `products`
Menyimpan etalase produk dari masing-masing UMKM.
```sql
create table public.products (
  id uuid default gen_random_uuid() primary key,
  umkm_id uuid references public.umkm(id) on delete cascade not null,
  nama_produk text not null,
  harga integer not null,
  deskripsi text,
  foto_produk text,
  is_promo boolean default false not null,
  kategori text default 'Lainnya' not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
```

### 5. Tabel `product_reviews`
Menyimpan ulasan dan bintang rating dari pembeli.
```sql
create table public.product_reviews (
  id bigint generated by default as identity primary key,
  product_id uuid references public.products(id) on delete cascade not null,
  nama_pembeli text default 'Pengunjung'::text not null,
  rating numeric check (rating >= 1 and rating <= 5) not null,
  review text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
```

### 📁 Konfigurasi Storage Buckets
Pastikan Anda membuat dua bucket di Supabase Storage:
1.  **`dokumen-legal`** (Disarankan: Private) - Untuk menampung berkas/foto surat izin usaha UMKM.
2.  **`umkm-assets`** (Disarankan: Public) - Untuk menampung foto profil toko dan foto barang dagangan produk.

---

## 🚀 Panduan Instalasi & Menjalankan Projek

### 1. Persiapan
Pastikan komputer Anda sudah terinstal:
- Flutter SDK terbaru (versi >= 3.11.0)
- Android Studio / VS Code lengkap dengan ekstensi Dart & Flutter
- Emulator Android / HP Android fisik terhubung (dengan fitur lokasi/GPS aktif)

### 2. Kloning Repositori
```bash
git clone https://github.com/FendiAndryto/umkm-maps-app.git
cd umkm-maps-app
```

### 3. Instalasi Packages
Unduh pustaka dependensi yang dibutuhkan projek:
```bash
flutter pub get
```

### 4. Konfigurasi Kredensial Supabase
Buka berkas konstanta aplikasi di [constants.dart](file:///c:/Users/pendi/Repository/umkm_maps_app/lib/core/constants.dart) dan sesuaikan URL serta Anon Key Supabase Anda:
```dart
class AppConstants {
  static const String supabaseUrl = 'https://<PROJECT_ID>.supabase.co';
  static const String supabaseAnonKey = '<YOUR_SUPABASE_ANON_KEY>';
}
```

### 5. Jalankan Aplikasi
Jalankan aplikasi pada emulator atau perangkat fisik Anda:
```bash
flutter run
```

---

## 📝 Lisensi
Projek ini dilisensikan di bawah **MIT License** - Lihat berkas [LICENSE](LICENSE) untuk detail lebih lanjut.

