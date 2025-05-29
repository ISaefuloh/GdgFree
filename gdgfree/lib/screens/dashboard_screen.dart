import 'package:flutter/material.dart';
import 'package:gdgfree/screens/users_list_screen.dart';
import './master_barang_list_screen.dart';
import './barang_masuk_list_screen.dart';
import './barang_keluar_list_screen.dart';
import './laporan_stok_screen.dart';
import './laporan_stok_real_time.dart';
import './change_password_screen.dart';
import './login_screen.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatelessWidget {
  final String token;

  const DashboardScreen({super.key, required this.token});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token'); // Hapus token
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false, // Hapus semua halaman sebelumnya
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem('Master Barang', Icons.inventory_2, () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MasterBarangListScreen()),
        );
      }),
      _MenuItem('Transaksi Masuk', Icons.login, () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const BarangMasukListScreen()),
        );
      }),
      _MenuItem('Transaksi Keluar', Icons.logout, () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const BarangKeluarListScreen()),
        );
      }),
      _MenuItem('Laporan Stok', Icons.bar_chart, () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LaporanStokScreen(token: token)),
        );
      }),
      _MenuItem('Laporan Stok Real Time', Icons.bar_chart, () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LaporanStokRScreen(token: token)),
        );
      }),
      _MenuItem('Laporan Stok Real Time', Icons.bar_chart, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserListScreen()),
        );
      }),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade700,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChangePasswordScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child:
                                  const Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.logout),
                            color: Colors.red.shade700,
                            onPressed: () => logout(context),
                            tooltip: 'Logout',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: GridView.builder(
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return Material(
              color: Colors.white,
              elevation: 4,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: item.onTap,
                splashColor: Colors.blueAccent.withOpacity(0.3),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade700,
                        Colors.blue.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withOpacity(0.6),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 56, color: Colors.white),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _MenuItem(this.title, this.icon, this.onTap);
}
