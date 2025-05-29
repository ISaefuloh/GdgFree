import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/laporan_stok.dart';

class LaporanStokScreen extends StatefulWidget {
  final String token;

  const LaporanStokScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<LaporanStokScreen> createState() => _LaporanStokScreenState();
}

class _LaporanStokScreenState extends State<LaporanStokScreen> {
  List<LaporanStok> laporanStokList = [];
  List<LaporanStok> filteredList = [];
  bool isLoading = false;
  String searchQuery = '';

  DateTime tanggalMulai = DateTime.now();
  DateTime tanggalAkhir = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    try {
      final data = await ApiService().fetchLaporanStok(
        widget.token,
        tanggalMulai.toIso8601String().substring(0, 10),
        tanggalAkhir.toIso8601String().substring(0, 10),
      );

      setState(() {
        laporanStokList = data;
        filteredList = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredList = laporanStokList.where((item) {
        return item.barang.nama.toLowerCase().contains(searchQuery) ||
            item.barang.kode.toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  Future<void> selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: tanggalMulai, end: tanggalAkhir),
    );

    if (picked != null) {
      setState(() {
        tanggalMulai = picked.start;
        tanggalAkhir = picked.end;
      });
      fetchData();
    }
  }

  Future<void> updateLaporan() async {
    setState(() => isLoading = true);
    try {
      await ApiService().generateLaporanStok(
        widget.token,
        tanggalMulai.toIso8601String().substring(0, 10),
        tanggalAkhir.toIso8601String().substring(0, 10),
      );
      await fetchData(); // refresh data setelah update
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update laporan: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseFontSize = MediaQuery.of(context).size.width < 360 ? 12.0 : 14.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Laporan Stok',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: updateLaporan,
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: selectDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari berdasarkan kode/nama barang...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                //fillColor: Colors.white,
                //filled: true,
              ),
              onChanged: filterSearch,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? const Center(child: Text('Tidak ada data laporan stok'))
                    : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            elevation: 2,
                            child: ListTile(
                              title: Text(
                                '${item.barang.kode} - ${item.barang.nama}',
                                style: TextStyle(
                                  fontSize: baseFontSize + 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tanggal: ${item.tanggal}',
                                      style: TextStyle(fontSize: baseFontSize)),
                                  Text('Stok Awal: ${item.stokAwal}',
                                      style: TextStyle(fontSize: baseFontSize)),
                                  Text('Masuk: ${item.stokMasuk}',
                                      style: TextStyle(fontSize: baseFontSize)),
                                  Text('Keluar: ${item.stokKeluar}',
                                      style: TextStyle(fontSize: baseFontSize)),
                                  Text('Stok Akhir: ${item.stokAkhir}',
                                      style: TextStyle(fontSize: baseFontSize)),
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
}
