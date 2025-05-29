class BarangMasuk {
  final int id;
  final String nomorRef;
  final String nomorBtb;
  final DateTime tanggalBtb;
  //final int createdBy; // bisa diganti dengan model User kalau kamu ingin detail user
  final String createdByUsername;

  BarangMasuk({
    required this.id,
    required this.nomorRef,
    required this.nomorBtb,
    required this.tanggalBtb,
    //required this.createdBy,
    required this.createdByUsername,
  });

  factory BarangMasuk.fromJson(Map<String, dynamic> json) {
    return BarangMasuk(
      id: json['id'],
      nomorRef: json['nomor_ref'] ?? '',
      nomorBtb: json['nomor_btb'] ?? '',
      tanggalBtb: DateTime.parse(json['tanggal_btb']),
      //createdBy: json['created_by'],
      createdByUsername: json['created_by_username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_ref': nomorRef,
      'nomor_btb': nomorBtb,
      'tanggal_btb': tanggalBtb.toIso8601String(),
      //'created_by': createdBy,
      'created_by_username': createdByUsername,
    };
  }
}
