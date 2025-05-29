import 'dart:ui';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../models/master_barang.dart';
import '../services/api_service.dart';

class TambahBarangMasukScreen extends StatefulWidget {
  const TambahBarangMasukScreen({super.key});

  @override
  State<TambahBarangMasukScreen> createState() =>
      _TambahBarangMasukScreenState();
}

class _TambahBarangMasukScreenState extends State<TambahBarangMasukScreen> {
  MasterBarang? _selectedBarang;
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _nomorRefController =
      TextEditingController(); // controller nomor_ref
  List<Map<String, dynamic>> _keranjang = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _addToKeranjang() {
    if (_selectedBarang == null || _qtyController.text.isEmpty) {
      _showMessage('Pilih barang dan isi jumlah terlebih dahulu.');
      return;
    }

    final qty = int.tryParse(_qtyController.text);
    if (qty == null || qty <= 0) {
      _showMessage('Jumlah tidak valid.');
      return;
    }

    // Cek apakah barang sudah ada di keranjang
    final alreadyExists =
        _keranjang.any((item) => item['barang'] == _selectedBarang!.id);
    if (alreadyExists) {
      _showMessage('Barang sudah ada di keranjang.');
      return;
    }

    setState(() {
      _keranjang.add({
        'barang': _selectedBarang!.id,
        'nama': _selectedBarang!.nama,
        'qty': qty,
      });
      _qtyController.clear();
      _selectedBarang = null;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _keranjang.removeAt(index);
    });
  }

  Future<void> _simpanTransaksi() async {
    if (_keranjang.isEmpty) {
      _showMessage('Keranjang kosong.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final barangMasukId = await ApiService().createBarangMasuk(
        nomorRef: _nomorRefController.text.isNotEmpty
            ? _nomorRefController.text
            : null,
      );

      if (barangMasukId == null) throw Exception("ID tidak ditemukan");

      for (var item in _keranjang) {
        await ApiService().createBarangMasukDetail(
          barangMasukId: barangMasukId,
          barangId: item['barang'],
          qty: item['qty'],
        );
      }

      _showMessage('Barang masuk berhasil disimpan.');
      Navigator.pop(context, true);
    } catch (e) {
      _showMessage('Gagal menyimpan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _nomorRefController.dispose();
    super.dispose();
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
                      const Expanded(
                        child: Text(
                          'Tambah Barang Masuk',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Input nomor_ref
                  TextField(
                    controller: _nomorRefController,
                    decoration: InputDecoration(
                      labelText: 'No.Referensi / No.Faktur',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dropdown barang
                  DropdownSearch<MasterBarang>(
                    popupProps: PopupProps.dialog(
                      showSearchBox: true,
                      showSelectedItems: true,
                      itemBuilder: (context, item, isSelected) => ListTile(
                        title: Text(item.nama),
                      ),
                    ),
                    asyncItems: (String filter) async {
                      return await ApiService().getMasterBarang(search: filter);
                    },
                    itemAsString: (item) => item.nama,
                    onChanged: (value) {
                      setState(() {
                        _selectedBarang = value;
                      });
                    },
                    selectedItem: _selectedBarang,
                    compareFn: (a, b) => a.id == b.id,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Pilih Barang",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Input jumlah
                  TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Jumlah',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tombol tambah ke keranjang
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addToKeranjang,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Tambah ke Keranjang'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Daftar Barang Masuk',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // List keranjang
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _keranjang.length,
                    itemBuilder: (context, index) {
                      final item = _keranjang[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: ListTile(
                          title: Text(
                            item['nama'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('Qty: ${item['qty']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeItem(index),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tombol simpan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _simpanTransaksi,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Transaksi'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
