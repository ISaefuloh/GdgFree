import 'package:flutter/material.dart';
import '../models/master_barang.dart';
import '../services/api_service.dart';
import 'master_barang_add_screen.dart';
import 'dart:ui';

class MasterBarangListScreen extends StatefulWidget {
  const MasterBarangListScreen({super.key});

  @override
  State<MasterBarangListScreen> createState() => _MasterBarangListScreenState();
}

class _MasterBarangListScreenState extends State<MasterBarangListScreen> {
  //late Future<List<MasterBarang>> _futureMasterBarangList;
  List<MasterBarang> _allBarang = [];
  List<MasterBarang> _filteredBarang = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshList();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshList() async {
    final data = await ApiService().getMasterBarang();
    setState(() {
      _allBarang = data;
      _filteredBarang = data;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBarang = _allBarang.where((barang) {
        return barang.kode.toLowerCase().contains(query) ||
            barang.nama.toLowerCase().contains(query) ||
            barang.merek.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _navigateToAddEdit({MasterBarang? barang}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMasterBarangScreen(barang: barang),
      ),
    );

    if (result == true) {
      _refreshList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dihapus: extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 4,
        title: const Text(
          'Master Barang',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshList,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _navigateToAddEdit(),
            tooltip: 'Tambah',
          ),
        ],
      ),
      body: Column(
        children: [
          // Dihapus: SizedBox(height: kToolbarHeight + 10),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kode, nama, atau merek...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredBarang.isEmpty
                ? const Center(child: Text('Data barang tidak ditemukan.'))
                : RefreshIndicator(
                    onRefresh: _refreshList,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _filteredBarang.length,
                      itemBuilder: (context, index) {
                        final barang = _filteredBarang[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text('${barang.kode} - ${barang.nama}'),
                            subtitle: Text(
                              'Merek: ${barang.merek.isEmpty ? '-' : barang.merek}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  barang.status
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color:
                                      barang.status ? Colors.green : Colors.red,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _navigateToAddEdit(barang: barang),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
