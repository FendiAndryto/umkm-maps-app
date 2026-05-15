class ProductModel {
  final String id;
  final String umkmId;
  final String namaProduk;
  final int harga;
  final String? deskripsi;
  final String? fotoProduk;
  final bool isPromo;

  ProductModel({
    required this.id,
    required this.umkmId,
    required this.namaProduk,
    required this.harga,
    this.deskripsi,
    this.fotoProduk,
    required this.isPromo,
  });

  // Ini fungsi sakti buat nerjemahin data dari Supabase
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      umkmId: json['umkm_id'],
      namaProduk: json['nama_produk'],
      // Jaga-jaga kalau tipe datanya kebaca string dari database
      harga: json['harga'] is int 
          ? json['harga'] 
          : int.tryParse(json['harga'].toString()) ?? 0,
      deskripsi: json['deskripsi'],
      fotoProduk: json['foto_produk'],
      isPromo: json['is_promo'] ?? false,
    );
  }
}