import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/barang_masuk_detail.dart';

class BarangMasukDetailScreen extends StatefulWidget {
  final int barangMasukId;

  const BarangMasukDetailScreen({Key? key, required this.barangMasukId})
      : super(key: key);

  @override
  State<BarangMasukDetailScreen> createState() =>
      _BarangMasukDetailScreenState();
}

class _BarangMasukDetailScreenState extends State<BarangMasukDetailScreen> {
  late Future<List<BarangMasukDetail>> _futureBarangMasukDetail;

  @override
  void initState() {
    super.initState();
    _futureBarangMasukDetail =
        ApiService().getBarangMasukDetail(widget.barangMasukId);
  }

  Future<void> _refreshList() async {
    setState(() {
      _futureBarangMasukDetail =
          ApiService().getBarangMasukDetail(widget.barangMasukId);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    children: [
                      BackButton(color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Detail Barang Masuk',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white),
                        onPressed: _refreshList,
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<BarangMasukDetail>>(
        future: _futureBarangMasukDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text(
              'Terjadi kesalahan: ${snapshot.error}',
              style: TextStyle(color: Colors.red.shade700),
            ));
          }

          final barangMasukDetailList = snapshot.data ?? [];

          if (barangMasukDetailList.isEmpty) {
            return const Center(child: Text('Tidak ada detail barang masuk.'));
          }

          return RefreshIndicator(
            onRefresh: _refreshList,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: barangMasukDetailList.length,
              itemBuilder: (context, index) {
                final detail = barangMasukDetailList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            detail.barang.kode,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Text(
                            'Qty: ${detail.qty}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
