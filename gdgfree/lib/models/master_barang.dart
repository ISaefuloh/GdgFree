class MasterBarang {
  final int id;
  final String kode;
  final String nama;
  final String merek;
  final bool status;
  final DateTime tanggalInput;
  final DateTime tanggalUpdate;

  MasterBarang({
    required this.id,
    required this.kode,
    required this.nama,
    required this.merek,
    required this.status,
    required this.tanggalInput,
    required this.tanggalUpdate,
  });

  factory MasterBarang.fromJson(Map<String, dynamic> json) {
    return MasterBarang(
      id: json['id'],
      kode: json['kode'],
      nama: json['nama'],
      merek: json['merek'] ?? '',
      status: json['status'],
      tanggalInput: DateTime.parse(json['tanggal_input']),
      tanggalUpdate: DateTime.parse(json['tanggal_update']),
    );
  }
}
