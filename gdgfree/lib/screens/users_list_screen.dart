import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/custom_user.dart';
import '../services/api_service.dart';
import './users_add_screen.dart'; // Pastikan file ini ada

PreferredSizeWidget modernAppBar(
  BuildContext context, {
  required String title,
  required VoidCallback onRefresh,
  required VoidCallback onAdd,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: ClipRect(
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
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: true,
            iconTheme:
                const IconThemeData(color: Colors.white), // Icon back putih
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: onRefresh,
                tooltip: 'Refresh',
                splashRadius: 24,
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: onAdd,
                tooltip: 'Tambah User',
                splashRadius: 24,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    ),
  );
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<UserModel>> _futureUserList;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  Future<void> _refreshList() async {
    setState(() {
      _futureUserList = ApiService().fetchUsers();
    });
  }

  void _navigateToAddEdit({UserModel? user}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditUserScreen(user: user),
      ),
    );

    if (result == true) {
      _refreshList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: modernAppBar(
        context,
        title: 'Daftar User',
        onRefresh: _refreshList,
        onAdd: () => _navigateToAddEdit(),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _futureUserList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final userList = snapshot.data ?? [];

          if (userList.isEmpty) {
            return const Center(
              child: Text(
                'Data user kosong.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshList,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: userList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = userList[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.teal,
                      child: Text(
                        user.username.isNotEmpty
                            ? user.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      user.username,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      '${(user.firstName.isNotEmpty || user.lastName.isNotEmpty) ? '${user.firstName} ${user.lastName}' : user.email}\nRole: ${user.role}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black),
                      tooltip: 'Edit User',
                      onPressed: () => _navigateToAddEdit(user: user),
                    ),
                    onTap: () => _navigateToAddEdit(user: user),
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
