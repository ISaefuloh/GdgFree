import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/laporan_stok.dart';

class LaporanStokService {
  static const String apiUrl =
      "http://127.0.0.1:8000/app_gudang/api/laporanstok/";

  Future<List<LaporanStok>> fetchLaporanStok() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print("Token tidak ditemukan. Pengguna belum login.");
      throw Exception('Token tidak ditemukan. Pengguna belum login.');
    }

    // Debugging token untuk memastikan token ada
    print("Token yang digunakan: $token");

    // Membuat request HTTP dengan header authorization
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Menggunakan format Bearer
      },
    );

    // Debugging status code dan response body untuk error
    print('STATUS CODE: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => LaporanStok.fromJson(e)).toList();
    } else {
      // Menampilkan error yang lebih spesifik
      print('Gagal memuat data laporan stok: ${response.body}');
      throw Exception('Failed to load LaporanStok');
    }
  }
}
