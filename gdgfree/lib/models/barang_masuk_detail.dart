import 'master_barang.dart';

class BarangMasukDetail {
  final int id;
  final int barangMasukId; // relasi ke BarangMasuk
  final MasterBarang barang;
  final int qty;

  BarangMasukDetail({
    required this.id,
    required this.barangMasukId,
    required this.barang,
    required this.qty,
  });

  factory BarangMasukDetail.fromJson(Map<String, dynamic> json) {
    return BarangMasukDetail(
      id: json['id'],
      barangMasukId: json['barang_masuk'], // asumsi berupa ID
      barang: MasterBarang.fromJson(json['barang']),
      qty: json['qty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barang_masuk': barangMasukId,
      'barang_id': barang.id, // kirim 'barang' bukan 'barang_id'
      'qty': qty,
    };
  }
}
