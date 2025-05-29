import 'package:flutter/material.dart';
import '../models/custom_user.dart';
import '../services/api_service.dart';

class AddEditUserScreen extends StatefulWidget {
  final UserModel? user;

  const AddEditUserScreen({super.key, this.user});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  String _role = 'teknisi';

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.user?.username ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _firstNameController =
        TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.user?.lastName ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _role = widget.user?.role ?? 'teknisi';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final data = {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'role': _role,
      };

      // Kalau tambah user baru, wajib kirim password
      if (widget.user == null) {
        data['password'] = _passwordController.text.trim();
      } else {
        // Kalau edit user, password dikirim hanya kalau user isi password baru
        if (_passwordController.text.trim().isNotEmpty) {
          data['password'] = _passwordController.text.trim();
        }
      }

      bool success = false;
      if (widget.user == null) {
        success = await ApiService().createUser(data);
      } else {
        success = await ApiService().updateUser(widget.user!.id, data);
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
    final isEdit = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white), // icon back putih
        title: Text(
          isEdit ? 'Edit User' : 'Tambah User',
          style: const TextStyle(color: Colors.white), // teks putih
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Username wajib diisi'
                    : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Email wajib diisi';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) return 'Email tidak valid';
                  return null;
                },
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'it', child: Text('IT')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'teknisi', child: Text('Teknisi')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _role = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: isEdit
                      ? 'Password (kosongkan jika tidak diubah)'
                      : 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (!isEdit && (value == null || value.isEmpty)) {
                    return 'Password wajib diisi';
                  }
                  if (isEdit &&
                      value != null &&
                      value.isNotEmpty &&
                      value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText:
                      isEdit ? 'Konfirmasi Password' : 'Konfirmasi Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (!isEdit && (value == null || value.isEmpty)) {
                    return 'Konfirmasi password wajib diisi';
                  }
                  if (value != _passwordController.text) {
                    return 'Password tidak sama';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(isEdit ? 'Update' : 'Simpan'),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
