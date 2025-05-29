import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/master_barang.dart';
import '../models/barang_masuk.dart';
import '../models/barang_masuk_detail.dart';
import '../models/barang_keluar.dart';
import '../models/barang_keluar_detail.dart';
import '../models/laporan_stok.dart';
import '../models/laporan_stok_real_time.dart';
import '../models/custom_user.dart';

class ApiService {
  static const String baseUrl = 'https://kidz.pythonanywhere.com/app_gudang';
  //static const String baseUrl = 'http://192.168.5.104:8000/app_gudang';
  //static const String baseUrl = 'http://127.0.0.1:8000/app_gudang';

  // ======================= AUTH ==========================
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/jwt/create/');
    final response = await http.post(
      url,
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final access = data['access'];
      final refresh = data['refresh'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access', access);
      await prefs.setString('refresh', refresh);

      Map<String, dynamic> decodedToken = JwtDecoder.decode(access);
      print('Decoded token: $decodedToken');
      int userId = decodedToken['user_id'];
      String role = decodedToken['role'];
      String usernameFromToken =
          decodedToken['username'] ?? 'User'; // <--- ambil username dari token

      print('Role: $role'); // ambil role dari token

      await prefs.setInt('user_id', userId);
      await prefs.setString('role', role);
      await prefs.setString(
          'username', usernameFromToken); // simpan username juga di prefs

      return {
        'token': access,
        'role': role,
        'username': usernameFromToken, // return username juga
      };
    } else {
      return null;
    }
  }

  //Future<String?> login(String username, String password) async {
  //  final url = Uri.parse('$baseUrl/auth/jwt/create/');
  //  final response = await http.post(
  //    url,
  //    body: {'username': username, 'password': password},
  //  );
//
  //  if (response.statusCode == 200) {
  //    final data = jsonDecode(response.body);
  //    final access = data['access'];
  //    final refresh = data['refresh'];
//
  //    final prefs = await SharedPreferences.getInstance();
  //    await prefs.setString('access', access);
  //    await prefs.setString('refresh', refresh);
//
  //    // Decode token untuk dapatkan user ID
  //    Map<String, dynamic> decodedToken = JwtDecoder.decode(access);
  //    int userId = decodedToken['user_id'];
//
  //    // Simpan user ID
  //    await prefs.setInt('user_id', userId);
//
  //    return access; // Return token akses
  //  } else {
  //    return null; // Return null jika gagal login
  //  }
  //}

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access');
  }

  // =============== MASTER BARANG =========================
  Future<List<MasterBarang>> getMasterBarang({String? search}) async {
    final token = await getToken();
    final Map<String, String> queryParameters =
        search != null && search.isNotEmpty
            ? {'search': search}
            : <String, String>{};
    final url = Uri.parse('$baseUrl/api/masterbarang/')
        .replace(queryParameters: queryParameters);

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => MasterBarang.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil master barang');
    }
  }

  Future<bool> createMasterBarang(Map<String, dynamic> data) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/masterbarang/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // Mengecek apakah server merespon dengan status 201 (created)
    return response.statusCode == 201;
  }

  Future<bool> updateMasterBarang(int id, Map<String, dynamic> data) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/masterbarang/$id/');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  // ============== BARANG MASUK ============================
  Future<List<BarangMasuk>> getBarangMasuk() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/barangmasuk/');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => BarangMasuk.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data barang masuk');
    }
  }

  Future<int?> createBarangMasuk({String? nomorRef}) async {
    final token = await getToken();
    final userId = await getUserId();

    if (userId == null) {
      throw Exception(
          'User ID tidak ditemukan. Pastikan Anda login terlebih dahulu.');
    }

    final url = Uri.parse('$baseUrl/api/barangmasuk/');

    // Siapkan body request
    final Map<String, dynamic> body = {
      'created_by': userId,
    };

    // Tambahkan nomor_ref jika diisi
    if (nomorRef != null && nomorRef.isNotEmpty) {
      body['nomor_ref'] = nomorRef;
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception('Gagal membuat Barang Masuk: ${response.body}');
    }
  }

  // ============== BARANG MASUK DETAIL ======================
  Future<List<BarangMasukDetail>> getBarangMasukDetail(
      int barangMasukId) async {
    final token = await getToken();
    final url = Uri.parse(
        '$baseUrl/api/barangmasukdetail/?barang_masuk=$barangMasukId');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => BarangMasukDetail.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data barang masuk detail');
    }
  }

  Future<bool> createBarangMasukDetail({
    required int barangMasukId,
    required int barangId,
    required int qty,
  }) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/barangmasukdetail/');
    final body = jsonEncode({
      'barang_masuk': barangMasukId,
      'barang_id': barangId,
      'qty': qty,
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    return response.statusCode == 201;
  }

  // ============== BARANG KELUAR ============================
  Future<List<BarangKeluar>> getBarangKeluarList() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/barangkeluar/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BarangKeluar.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data barang keluar');
    }
  }

  Future<int?> createBarangKeluar() async {
    final token = await getToken(); // pastikan ada method ini untuk ambil JWT
    final url = Uri.parse('$baseUrl/api/barangkeluar/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({}), // body kosong, backend akan isi created_by
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id']; // pastikan serializer mengembalikan ID
    } else {
      print('Gagal create barang keluar: ${response.body}');
      throw Exception('Gagal create barang keluar: ${response.body}');
    }
  }

  // ============ BARANG KELUAR DETAIL =======================
  Future<List<BarangKeluarDetail>> getBarangKeluarDetail(
      int barangKeluarId) async {
    final token = await getToken();
    final url = Uri.parse(
        '$baseUrl/api/barangkeluardetail/?barang_keluar=$barangKeluarId');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => BarangKeluarDetail.fromJson(item)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Token tidak valid atau sudah expired');
    } else {
      throw Exception('Gagal mengambil data barang keluar detail');
    }
  }

  Future<void> createBarangKeluarDetail({
    required int barangKeluarId,
    required int barangId,
    required int qty,
  }) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/barangkeluardetail/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'barang_keluar': barangKeluarId,
        'barang_id': barangId,
        'qty': qty,
      }),
    );

    if (response.statusCode != 201) {
      print('Gagal tambah detail barang keluar: ${response.body}');
      throw Exception('Gagal tambah detail barang keluar: ${response.body}');
    }
  }

  // =================== LAPORAN STOK ========================
  Future<List<LaporanStok>> fetchLaporanStok(
      String token, String tanggalMulai, String tanggalAkhir) async {
    final url = Uri.parse(
        '$baseUrl/api/laporanstok/?tanggal_mulai=$tanggalMulai&tanggal_akhir=$tanggalAkhir');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => LaporanStok.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data laporan stok');
    }
  }

  Future<List<LaporanStokR>> fetchLaporanStokRealtime(
      String token, String tanggalMulai, String tanggalAkhir) async {
    final url = Uri.parse(
        '$baseUrl/api/laporanstok-realtime/?tanggal_mulai=$tanggalMulai&tanggal_akhir=$tanggalAkhir');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => LaporanStokR.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data laporan stok realtime');
    }
  }

  Future<void> generateLaporanStok(
      String token, String tanggalMulai, String tanggalAkhir) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/laporanstok/generate/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tanggal_mulai': tanggalMulai,
        'tanggal_akhir': tanggalAkhir,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal generate laporan: ${response.body}');
    }
  }

  // =================== CUSTOM USER ========================
  Future<List<UserModel>> fetchUsers() async {
    final token = await getToken();
    if (token == null) throw Exception("Token tidak ditemukan");

    final response = await http.get(
      Uri.parse('$baseUrl/api/users/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print(jsonDecode(response.body));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data user (code: ${response.statusCode})');
    }
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );
    return response.statusCode == 200;
  }

  Future<bool> changePassword(String currentPassword, String newPassword,
      String confirmPassword) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/auth/users/set_password/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'current_password': currentPassword,
        'new_password': newPassword,
        're_new_password': confirmPassword,
      }),
    );

    return response.statusCode == 204;
  }
}
