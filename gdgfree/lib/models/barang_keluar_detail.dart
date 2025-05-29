import 'master_barang.dart';

class BarangKeluarDetail {
  final int id;
  final int barangKeluarId; // relasi ke BarangKeluar
  final MasterBarang barang;
  final int qty;

  BarangKeluarDetail({
    required this.id,
    required this.barangKeluarId,
    required this.barang,
    required this.qty,
  });

  factory BarangKeluarDetail.fromJson(Map<String, dynamic> json) {
    return BarangKeluarDetail(
      id: json['id'],
      barangKeluarId: json['barang_keluar'], // asumsi berupa ID
      barang: MasterBarang.fromJson(json['barang']),
      qty: json['qty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barang_keluar': barangKeluarId,
      'barang_id': barang.id,
      'qty': qty,
    };
  }
}
