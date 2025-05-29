import 'package:flutter/material.dart';
import './barang_masuk_list_screen.dart';
import './barang_keluar_list_screen.dart';
import './laporan_stok_real_time.dart';
import './change_password_screen.dart';
import './login_screen.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class TeknisiDashboardScreen extends StatefulWidget {
  final String token;

  const TeknisiDashboardScreen({super.key, required this.token});

  @override
  State<TeknisiDashboardScreen> createState() => _TeknisiDashboardScreenState();
}

class _TeknisiDashboardScreenState extends State<TeknisiDashboardScreen> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    print(
        'Loaded username from prefs: $savedUsername'); // Cek ini di debug console
    setState(() {
      _username = savedUsername ?? 'User';
    });
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access');
    await prefs.remove('refresh');
    await prefs.remove('user_id');
    await prefs.remove('username');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
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
      _MenuItem('Laporan Stok Real Time', Icons.bar_chart, () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LaporanStokRScreen(token: widget.token)),
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
                color: Colors.teal,
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
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChangePasswordScreen()),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.person, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  _username,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
                splashColor: Colors.teal,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal,
                        Colors.tealAccent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 4),
        child: Text(
          'Powered by ISafuloh',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _MenuItem(this.title, this.icon, this.onTap);
}
