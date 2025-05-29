import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import '../models/barang_masuk.dart';
import 'barang_masuk_detail_screen.dart';
import 'barang_masuk_add_screen.dart';

class BarangMasukListScreen extends StatefulWidget {
  const BarangMasukListScreen({super.key});

  @override
  State<BarangMasukListScreen> createState() => _BarangMasukListScreenState();
}

class _BarangMasukListScreenState extends State<BarangMasukListScreen> {
  List<BarangMasuk> _barangMasukList = [];
  List<BarangMasuk> _filteredBarangMasukList = [];
  TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchDataForToday();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchData({String? startDate, String? endDate}) async {
    final list = await ApiService().getBarangMasuk();
    setState(() {
      _barangMasukList = list.where((item) {
        final tanggal = item.tanggalBtb;
        if (startDate != null && endDate != null) {
          final start = DateTime.parse(startDate);
          final end = DateTime.parse(endDate)
              .add(const Duration(days: 1))
              .subtract(const Duration(seconds: 1));
          return tanggal.isAfter(start.subtract(const Duration(seconds: 1))) &&
              tanggal.isBefore(end.add(const Duration(seconds: 1)));
        }
        return true;
      }).toList();
      _filterData();
    });
  }

  Future<void> _fetchDataForToday() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));
    final list = await ApiService().getBarangMasuk();
    setState(() {
      _selectedDateRange = DateTimeRange(start: todayStart, end: todayStart);
      _barangMasukList = list.where((item) {
        final tanggal = item.tanggalBtb;
        return tanggal
                .isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
            tanggal.isBefore(todayEnd.add(const Duration(seconds: 1)));
      }).toList();
      _filterData();
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBarangMasukList = _barangMasukList.where((item) {
        return item.nomorBtb.toLowerCase().contains(query) ||
            item.createdByUsername.toLowerCase().contains(query) ||
            item.nomorRef.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();
    _filteredBarangMasukList = _barangMasukList.where((item) {
      return item.nomorBtb.toLowerCase().contains(query) ||
          item.createdByUsername.toLowerCase().contains(query) ||
          item.nomorRef.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _refreshList() async {
    if (_selectedDateRange != null) {
      final tanggalAwal =
          DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start);
      final tanggalAkhir =
          DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end);
      await _fetchData(startDate: tanggalAwal, endDate: tanggalAkhir);
    } else {
      await _fetchDataForToday();
    }
    _searchController.clear();
  }

  void _navigateToDetail(int barangMasukId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BarangMasukDetailScreen(barangMasukId: barangMasukId),
      ),
    );
    if (result != null) {
      _refreshList();
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange ??
          DateTimeRange(start: DateTime.now(), end: DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      final tanggalAwal = DateFormat('yyyy-MM-dd').format(picked.start);
      final tanggalAkhir = DateFormat('yyyy-MM-dd').format(picked.end);
      await _fetchData(startDate: tanggalAwal, endDate: tanggalAkhir);
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _selectedDateRange == null
        ? 'Hari ini'
        : '${DateFormat('dd MMM yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}';

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
                          'Daftar Barang Masuk',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      //IconButton(
                      //  icon: const Icon(Icons.refresh, color: Colors.white),
                      //  onPressed: _refreshList,
                      //  tooltip: 'Refresh',
                      //),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.teal),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _selectDateRange,
                  child: Text(
                    dateLabel,
                    style: const TextStyle(fontSize: 16, color: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari No.BTB / No.Ref',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filteredBarangMasukList.isEmpty
                ? const Center(child: Text('Tidak ada data barang masuk.'))
                : RefreshIndicator(
                    onRefresh: _refreshList,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredBarangMasukList.length,
                      itemBuilder: (context, index) {
                        final barangMasuk = _filteredBarangMasukList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _navigateToDetail(barangMasuk.id),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.teal,
                                    width: 6,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 20),
                              child: Row(
                                children: [
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          barangMasuk.nomorBtb,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'No Ref: ${barangMasuk.nomorRef}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tanggal: ${DateFormat('yyyy-MM-dd').format(barangMasuk.tanggalBtb)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Dibuat oleh: ${barangMasuk.createdByUsername}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahBarangMasukScreen(),
            ),
          );
          if (result == true) {
            _refreshList();
          }
        },
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 6,
        child: const Icon(Icons.add),
      ),
    );
  }
}
