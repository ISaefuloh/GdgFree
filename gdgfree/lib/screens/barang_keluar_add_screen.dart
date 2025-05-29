import 'dart:ui';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../models/master_barang.dart';
import '../services/api_service.dart';
import '../models/laporan_stok_real_time.dart';

class TambahBarangKeluarScreen extends StatefulWidget {
  const TambahBarangKeluarScreen({super.key});

  @override
  State<TambahBarangKeluarScreen> createState() =>
      _TambahBarangKeluarScreenState();
}

class _TambahBarangKeluarScreenState extends State<TambahBarangKeluarScreen> {
  MasterBarang? _selectedBarang;
  final TextEditingController _qtyController = TextEditingController();
  List<Map<String, dynamic>> _keranjang = [];
  bool _isLoading = false;

  void _addToKeranjang() async {
    if (_selectedBarang == null || _qtyController.text.isEmpty) {
      _showMessage('Pilih barang dan isi jumlah terlebih dahulu.');
      return;
    }

    final qty = int.tryParse(_qtyController.text);
    if (qty == null || qty <= 0) {
      _showMessage('Jumlah tidak valid.');
      return;
    }

    final exists =
        _keranjang.any((item) => item['barang'] == _selectedBarang!.id);
    if (exists) {
      _showMessage('Barang sudah ada di keranjang.');
      return;
    }

    try {
      final now = DateTime.now();
      final tanggal =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final token = await ApiService()
          .getToken(); // Ganti ini jika cara ambil token berbeda

      //final token = await ApiService().getToken();
      final stokList =
          await ApiService().fetchLaporanStokRealtime(token!, tanggal, tanggal);

      final laporan = stokList.firstWhere(
        (item) => item.kode == _selectedBarang!.kode,
        orElse: () => LaporanStokR(
          kode: _selectedBarang!.kode,
          nama: _selectedBarang!.nama,
          stokAwal: 0,
          stokMasuk: 0,
          stokKeluar: 0,
          stokAkhir: 0,
        ),
      );

      final stokTersedia = laporan.stokAkhir;

      if (qty > stokTersedia) {
        _showMessage('Stok tidak mencukupi. Stok tersedia: $stokTersedia');
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
    } catch (e) {
      _showMessage('Gagal memeriksa stok: $e');
    }
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
      final barangKeluarId = await ApiService().createBarangKeluar();
      if (barangKeluarId == null) throw Exception("ID tidak ditemukan");

      for (var item in _keranjang) {
        await ApiService().createBarangKeluarDetail(
          barangKeluarId: barangKeluarId,
          barangId: item['barang'],
          qty: item['qty'],
        );
      }

      _showMessage('Barang keluar berhasil disimpan.');
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
                      Expanded(
                        child: Text(
                          'Tambah Barang Keluar',
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _addToKeranjang,
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
                      'Daftar Barang Keluar',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _keranjang.length,
                    itemBuilder: (context, index) {
                      final item = _keranjang[index];
                      final qtyController = TextEditingController(
                        text: item['qty'].toString(),
                      );

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
                          subtitle: Row(
                            children: [
                              const Text("Qty: "),
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  controller: qtyController,
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      const InputDecoration(isDense: true),
                                  onSubmitted: (value) {
                                    final newQty = int.tryParse(value);
                                    if (newQty != null && newQty > 0) {
                                      setState(() {
                                        _keranjang[index]['qty'] = newQty;
                                      });
                                    } else {
                                      _showMessage('Jumlah tidak valid.');
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeItem(index),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _simpanTransaksi,
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
