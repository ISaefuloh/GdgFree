import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  String? _token;

  String? get token => _token;

  bool get isAuthenticated => _token != null;

  // Method untuk login
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      //Uri.parse("http://127.0.0.1:8000/app_gudang/auth/token/"),
      Uri.parse("http://127.0.0.1:8000/app_gudang/auth/jwt/create/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Pastikan data['access'] ada dalam response
      if (data['access'] != null) {
        _token = data['access']; // Ambil token 'access' dari response

        // Simpan token di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        notifyListeners();
        return true;
      } else {
        // Jika tidak ada access token dalam response
        print("Token tidak ditemukan dalam response");
        return false;
      }
    } else {
      // Cek jika status bukan 200 dan tampilkan error dari body
      print("Error: ${response.statusCode} - ${response.body}");
      return false;
    }
  }

  // Method untuk logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('auth_token'); // Hapus token dari SharedPreferences
    _token = null; // Set token menjadi null
    notifyListeners();
  }

  // Ambil token dari SharedPreferences
  Future<String?> getTokenFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Mengambil token yang tersimpan
  }
}
