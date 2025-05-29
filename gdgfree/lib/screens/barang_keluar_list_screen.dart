import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import '../models/barang_keluar.dart';
import 'barang_keluar_add_screen.dart';
import 'barang_keluar_detail_screen.dart';

class BarangKeluarListScreen extends StatefulWidget {
  const BarangKeluarListScreen({super.key});

  @override
  State<BarangKeluarListScreen> createState() => _BarangKeluarListScreenState();
}

class _BarangKeluarListScreenState extends State<BarangKeluarListScreen> {
  List<BarangKeluar> _barangKeluarList = [];
  List<BarangKeluar> _filteredBarangKeluarList = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchDataForToday();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _filterData();
      });
    });
  }

  Future<void> _fetchData({String? startDate, String? endDate}) async {
    final list = await ApiService().getBarangKeluarList();
    setState(() {
      _barangKeluarList = list.where((item) {
        final tanggal = item.tanggalFaktur;
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
    final list = await ApiService().getBarangKeluarList();
    setState(() {
      _selectedDateRange = DateTimeRange(start: todayStart, end: todayStart);
      _barangKeluarList = list.where((item) {
        final tanggal = item.tanggalFaktur;
        return tanggal
                .isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
            tanggal.isBefore(todayEnd.add(const Duration(seconds: 1)));
      }).toList();
      _filterData();
    });
  }

  void _filterData() {
    _filteredBarangKeluarList = _barangKeluarList.where((barang) {
      return barang.nomorFaktur.toLowerCase().contains(_searchQuery) ||
          barang.createdByUsername.toLowerCase().contains(_searchQuery) ||
          barang.tanggalFaktur.toString().toLowerCase().contains(_searchQuery);
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
  }

  void _navigateToDetail(int barangKeluarId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BarangKeluarDetailScreen(barangKeluarId: barangKeluarId),
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
                          'Daftar Barang Keluar',
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
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 20, color: Colors.teal),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _selectDateRange,
                      child: Text(
                        dateLabel,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.teal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari faktur, username, atau tanggal...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshList,
              child: _filteredBarangKeluarList.isEmpty
                  ? const Center(child: Text('Tidak ada data barang keluar.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredBarangKeluarList.length,
                      itemBuilder: (context, index) {
                        final barangKeluar = _filteredBarangKeluarList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _navigateToDetail(barangKeluar.id),
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  left:
                                      BorderSide(color: Colors.teal, width: 6),
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
                                          barangKeluar.nomorFaktur,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Tanggal: ${DateFormat('yyyy-MM-dd').format(barangKeluar.tanggalFaktur)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Dibuat oleh: ${barangKeluar.createdByUsername}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 18, color: Colors.grey),
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
              builder: (context) => const TambahBarangKeluarScreen(),
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
