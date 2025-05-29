import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/barang_keluar.dart';

class BarangKeluarService {
  static const String apiUrl =
      "http://127.0.0.1:8000/app_gudang/api/barangkeluar/";

  // Method untuk fetch data Barang Keluar
  Future<List<BarangKeluar>> fetchBarangKeluar() async {
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
      return data.map((e) => BarangKeluar.fromJson(e)).toList();
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Gagal memuat data Barang Keluar');
    }
  }

  // Method untuk membuat data Barang Keluar
  Future<bool> createBarangKeluar(Map<String, dynamic> data) async {
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
