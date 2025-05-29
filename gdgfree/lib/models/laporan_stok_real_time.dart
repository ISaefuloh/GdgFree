class LaporanStokR {
  final String kode;
  final String nama;
  final int stokAwal;
  final int stokMasuk;
  final int stokKeluar;
  final int stokAkhir;

  LaporanStokR({
    required this.kode,
    required this.nama,
    required this.stokAwal,
    required this.stokMasuk,
    required this.stokKeluar,
    required this.stokAkhir,
  });

  factory LaporanStokR.fromJson(Map<String, dynamic> json) {
    return LaporanStokR(
      kode: json['kode'],
      nama: json['nama'],
      stokAwal: json['stok_awal'],
      stokMasuk: json['stok_masuk'],
      stokKeluar: json['stok_keluar'],
      stokAkhir: json['stok_akhir'],
    );
  }
}
