class BarangKeluar {
  final int id;
  final String nomorFaktur;
  final DateTime tanggalFaktur;
  //final int createdBy; // Sama seperti BarangMasuk
  final String createdByUsername;

  BarangKeluar({
    required this.id,
    required this.nomorFaktur,
    required this.tanggalFaktur,
    //required this.createdBy,
    required this.createdByUsername,
  });

  factory BarangKeluar.fromJson(Map<String, dynamic> json) {
    return BarangKeluar(
      id: json['id'],
      nomorFaktur: json['nomor_faktur'] ?? '',
      tanggalFaktur: DateTime.parse(json['tanggal_faktur']),
      //createdBy: json['created_by'], // jika hanya berupa ID
      createdByUsername: json['created_by_username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_faktur': nomorFaktur,
      'tanggal_faktur': tanggalFaktur.toIso8601String(),
      //'created_by': createdBy,
      'created_by_username': createdByUsername,
    };
  }
}
