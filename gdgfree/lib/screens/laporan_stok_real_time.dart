import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/laporan_stok_real_time.dart';
import '../services/api_service.dart';

import 'package:path/path.dart' as p;

class LaporanStokRScreen extends StatefulWidget {
  final String token;
  LaporanStokRScreen({required this.token});

  @override
  _LaporanStokRScreenState createState() => _LaporanStokRScreenState();
}

class _LaporanStokRScreenState extends State<LaporanStokRScreen> {
  List<LaporanStokR> laporan = [];
  List<LaporanStokR> filteredLaporan = [];
  bool isLoading = true;
  String searchQuery = '';
  DateTimeRange? selectedDateRange;
  bool isFilteredStokAkhir = true; // Default filter saat buka screen

  @override
  void initState() {
    super.initState();
    fetchAllData(); // Ambil semua data saat init
  }

  Future<void> fetchAllData() async {
    setState(() {
      isLoading = true;
      selectedDateRange = null;
      searchQuery = '';
    });

    try {
      final result = await ApiService().fetchLaporanStokRealtime(
        widget.token,
        '',
        '',
      );

      setState(() {
        laporan = isFilteredStokAkhir
            ? result.where((item) => item.stokAkhir > 0).toList()
            : result;
        applySearch();
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  void applySearch() {
    setState(() {
      filteredLaporan = laporan
          .where((item) =>
              item.kode.toLowerCase().contains(searchQuery.toLowerCase()) ||
              item.nama.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  Future<void> selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange ??
          DateTimeRange(start: DateTime.now(), end: DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
        isFilteredStokAkhir = true;
      });
      fetchData();
    }
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    final now = DateTime.now();
    final start = selectedDateRange?.start ?? now;
    final end = selectedDateRange?.end ?? now;

    final tanggalAwal = DateFormat('yyyy-MM-dd').format(start);
    final tanggalAkhir = DateFormat('yyyy-MM-dd').format(end);

    try {
      final result = await ApiService().fetchLaporanStokRealtime(
        widget.token,
        tanggalAwal,
        tanggalAkhir,
      );

      setState(() {
        laporan = result
            .where((item) =>
                (item.stokMasuk != 0 || item.stokKeluar != 0) &&
                (!isFilteredStokAkhir || item.stokAkhir > 0))
            .toList();
        applySearch();
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      var status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> exportToExcel() async {
    final granted = await requestPermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izin penyimpanan ditolak')),
      );
      return;
    }

    var excel = Excel.createExcel();
    Sheet sheet = excel['Laporan Stok'];

    sheet.appendRow([
      'Kode',
      'Nama',
      'Stok Awal',
      'Stok Masuk',
      'Stok Keluar',
      'Stok Akhir'
    ]);

    for (var item in filteredLaporan) {
      sheet.appendRow([
        item.kode,
        item.nama,
        item.stokAwal,
        item.stokMasuk,
        item.stokKeluar,
        item.stokAkhir,
      ]);
    }

    // Path ke folder Download manual
    final downloadDir = Directory('/storage/emulated/0/Download');

    if (!await downloadDir.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Folder Download tidak ditemukan')),
      );
      return;
    }

    String fileName =
        'Laporan_Stok_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    String filePath = p.join(downloadDir.path, fileName);

    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Berhasil export ke Excel: $filePath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = selectedDateRange == null
        ? 'Hari ini'
        : '${DateFormat('dd MMM yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(selectedDateRange!.end)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan Stok',
          style: TextStyle(color: Colors.white), // Warna teks
        ),
        backgroundColor: Colors.teal, // Warna latar belakang AppBar
        iconTheme: IconThemeData(color: Colors.white), // Untuk icon back dll
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Tanggal & Search
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: Colors.teal),
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: selectDateRange,
                      child: Text(
                        dateLabel,
                        style: TextStyle(fontSize: 16, color: Colors.teal),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari kode atau nama...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                    applySearch();
                  },
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.filter_alt),
                        label: Text('Stok Ready'),
                        style: ElevatedButton.styleFrom(
                            //backgroundColor: Colors.green,
                            ),
                        onPressed: () {
                          setState(() => isFilteredStokAkhir = true);
                          fetchAllData();
                        },
                      ),
                      //child: ElevatedButton.icon(
                      //  icon: Icon(Icons.download),
                      //  label: Text('Export to Excel'),
                      //  onPressed:
                      //      filteredLaporan.isEmpty ? null : exportToExcel,
                      //),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.list),
                        label: Text('Show All'),
                        onPressed: () {
                          setState(() => isFilteredStokAkhir = false);
                          fetchAllData();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: Icon(Icons.download),
                  label: Text('Export to Excel'),
                  onPressed: filteredLaporan.isEmpty ? null : exportToExcel,
                ),
                //ElevatedButton.icon(
                //  icon: Icon(Icons.filter_alt),
                //  label: Text('Filter Stok > 0'),
                //  style: ElevatedButton.styleFrom(
                //    backgroundColor: Colors.green,
                //  ),
                //  onPressed: () {
                //    setState(() => isFilteredStokAkhir = true);
                //    fetchAllData();
                //  },
                //),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredLaporan.isEmpty
                    ? Center(child: Text('Tidak ada data'))
                    : ListView.builder(
                        itemCount: filteredLaporan.length,
                        itemBuilder: (context, index) {
                          final item = filteredLaporan[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item.kode} - ${item.nama}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal)),
                                  SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _infoText('Awal', item.stokAwal),
                                      _infoText('Masuk', item.stokMasuk),
                                      _infoText('Keluar', item.stokKeluar),
                                      _infoText('Akhir', item.stokAkhir),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _infoText(String label, int value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
