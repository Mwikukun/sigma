import 'package:flutter/material.dart';

class LogoutCard extends StatelessWidget {
  const LogoutCard({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(
            color: Color(0xff2E3A87),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xff2E3A87)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2E3A87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Anda telah logout.'),
                  backgroundColor: Color(0xff2E3A87),
                ),
              );
              // TODO: Arahkan ke halaman login di sini
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xffDCE3FF),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Color(0xff2E3A87)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff2E3A87),
          ),
        ),
        subtitle: const Text(
          'Keluar dari akun Anda',
          style: TextStyle(color: Colors.black54),
        ),
        onTap: () => _showLogoutDialog(context),
      ),
    );
  }
}
