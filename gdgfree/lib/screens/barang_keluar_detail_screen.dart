import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/barang_keluar_detail.dart';

class BarangKeluarDetailScreen extends StatefulWidget {
  final int barangKeluarId;

  const BarangKeluarDetailScreen({Key? key, required this.barangKeluarId})
      : super(key: key);

  @override
  State<BarangKeluarDetailScreen> createState() =>
      _BarangKeluarDetailScreenState();
}

class _BarangKeluarDetailScreenState extends State<BarangKeluarDetailScreen> {
  late Future<List<BarangKeluarDetail>> _futureBarangKeluarDetail;

  @override
  void initState() {
    super.initState();
    _futureBarangKeluarDetail =
        ApiService().getBarangKeluarDetail(widget.barangKeluarId);
  }

  Future<void> _refreshList() async {
    setState(() {
      _futureBarangKeluarDetail =
          ApiService().getBarangKeluarDetail(widget.barangKeluarId);
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
                          'Detail Barang Keluar',
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
      body: FutureBuilder<List<BarangKeluarDetail>>(
        future: _futureBarangKeluarDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: TextStyle(color: Colors.red.shade700),
              ),
            );
          }

          final barangKeluarDetailList = snapshot.data ?? [];

          if (barangKeluarDetailList.isEmpty) {
            return const Center(child: Text('Tidak ada detail barang keluar.'));
          }

          return RefreshIndicator(
            onRefresh: _refreshList,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: barangKeluarDetailList.length,
              itemBuilder: (context, index) {
                final detail = barangKeluarDetailList[index];
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
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Text(
                            'Qty: ${detail.qty}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
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
