import 'package:flutter/material.dart';

class LogoutCard extends StatelessWidget {
  const LogoutCard({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Arahkan ke halaman login
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Anda telah logout.')),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.redAccent),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Keluar dari akun Anda'),
        onTap: () => _showLogoutDialog(context),
      ),
    );
  }
}
