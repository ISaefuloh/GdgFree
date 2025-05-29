import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/barang_masuk.dart';

class BarangMasukService {
  static const String apiUrl =
      "http://127.0.0.1:8000/app_gudang/api/barangmasuk/";

  // Method untuk fetch data Barang Masuk
  Future<List<BarangMasuk>> fetchBarangMasuk() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pengguna belum login.');
    }

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Menambahkan token JWT pada header
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => BarangMasuk.fromJson(e)).toList();
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Gagal memuat data Barang Masuk');
    }
  }

  // Method untuk membuat data Barang Masuk
  Future<bool> createBarangMasuk(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pengguna belum login.');
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Menambahkan token JWT pada header
      },
      body: jsonEncode(data),
    );

    return response.statusCode == 201;
  }
}
