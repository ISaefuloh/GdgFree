import './master_barang.dart';

class LaporanStok {
  final int id;
  final MasterBarang barang;
  final int stokAwal;
  final int stokMasuk;
  final int stokKeluar;
  final int stokAkhir;
  final String tanggal;

  LaporanStok({
    required this.id,
    required this.barang,
    required this.stokAwal,
    required this.stokMasuk,
    required this.stokKeluar,
    required this.stokAkhir,
    required this.tanggal,
  });

  factory LaporanStok.fromJson(Map<String, dynamic> json) {
    return LaporanStok(
      id: json['id'],
      barang: MasterBarang.fromJson(json['barang']),
      stokAwal: json['stok_awal'],
      stokMasuk: json['stok_masuk'],
      stokKeluar: json['stok_keluar'],
      stokAkhir: json['stok_akhir'],
      tanggal: json['tanggal'],
    );
  }
}


//class LaporanStokModel {
//  final String kode;
//  final String nama;
//  final int stokAwal;
//  final int stokMasuk;
//  final int stokKeluar;
//  final int stokAkhir;
//  final String tanggal;
//
//  LaporanStokModel({
//    required this.kode,
//    required this.nama,
//    required this.stokAwal,
//    required this.stokMasuk,
//    required this.stokKeluar,
//    required this.stokAkhir,
//    required this.tanggal,
//  });
//
//  factory LaporanStokModel.fromJson(Map<String, dynamic> json) {
//    final barangDetail = json['barang_detail'] ?? {};
//
//    return LaporanStokModel(
//      kode: barangDetail['kode'] ?? '',
//      nama: barangDetail['nama'] ?? '',
//      stokAwal: json['stok_awal'] ?? 0,
//      stokMasuk: json['stok_masuk'] ?? 0,
//      stokKeluar: json['stok_keluar'] ?? 0,
//      stokAkhir: json['stok_akhir'] ?? 0,
//      tanggal: json['tanggal'] ?? '',
//    );
//  }
//}
//