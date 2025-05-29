import 'package:flutter/material.dart';
import '../models/master_barang.dart';
import '../services/api_service.dart';

class AddEditMasterBarangScreen extends StatefulWidget {
  final MasterBarang? barang;

  const AddEditMasterBarangScreen({super.key, this.barang});

  @override
  State<AddEditMasterBarangScreen> createState() =>
      _AddEditMasterBarangScreenState();
}

class _AddEditMasterBarangScreenState extends State<AddEditMasterBarangScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kodeController;
  late TextEditingController _namaController;
  late TextEditingController _merekController;
  bool _status = true;

  @override
  void initState() {
    super.initState();
    _kodeController = TextEditingController(text: widget.barang?.kode ?? '');
    _namaController = TextEditingController(text: widget.barang?.nama ?? '');
    _merekController = TextEditingController(text: widget.barang?.merek ?? '');
    _status = widget.barang?.status ?? true;
  }

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
    _merekController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final data = {
        'kode': _kodeController.text.trim(),
        'nama': _namaController.text.trim(),
        'merek': _merekController.text.trim(),
        'status': _status,
      };

      bool success = false;

      if (widget.barang == null) {
        success = await ApiService().createMasterBarang(data);
      } else {
        success =
            await ApiService().updateMasterBarang(widget.barang!.id, data);
      }

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.barang != null;

    return Scaffold(
      // Dihapus: extendBodyBehindAppBar: true
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit Master Barang' : 'Tambah Master Barang',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _kodeController,
                  decoration: const InputDecoration(
                    labelText: 'Kode Barang',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Barang',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _merekController,
                  decoration: const InputDecoration(
                    labelText: 'Merek',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Status Aktif'),
                  value: _status,
                  onChanged: (val) => setState(() => _status = val),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(isEdit ? 'Update' : 'Simpan'),
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
