class ProductModel {
  final String id;
  final String umkmId;
  final String namaProduk;
  final int harga;
  final String? deskripsi;
  final String? fotoProduk;
  final bool isPromo;
  final String? kategori;
  final double averageRating; // Rata-rata bintang ulasan bos!
  final int totalReviews;     // Total ulasan terkumpul bos!

  ProductModel({
    required this.id,
    required this.umkmId,
    required this.namaProduk,
    required this.harga,
    this.deskripsi,
    this.fotoProduk,
    required this.isPromo,
    this.kategori,
    required this.averageRating,
    required this.totalReviews,
  });

  // Ini fungsi sakti buat nerjemahin data dari Supabase
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Proses rating dari joined relation 'product_reviews'
    final reviews = json['product_reviews'] as List? ?? [];
    double avgRating = 0.0;
    if (reviews.isNotEmpty) {
      double total = 0.0;
      for (var r in reviews) {
        total += (r['rating'] as num).toDouble();
      }
      avgRating = total / reviews.length;
    }

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
      kategori: json['kategori'] ?? 'Lainnya',
      averageRating: double.parse(avgRating.toStringAsFixed(1)), // 1 desimal aja biar cakep
      totalReviews: reviews.length,
    );
  }
}
