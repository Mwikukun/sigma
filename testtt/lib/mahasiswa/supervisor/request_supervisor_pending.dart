import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testtt/login_screen.dart';

class PendingSupervisorPage extends StatelessWidget {
  final String selectedSupervisor;

  const PendingSupervisorPage({super.key, required this.selectedSupervisor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_polibatam.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay
          Container(color: const Color.fromARGB(45, 110, 208, 246)),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // ================= LOGO & JUDUL (LUAR CARD) =================
                  Image.asset('assets/images/logo_polibatam.png', width: 120),
                  const SizedBox(height: 12),
                  const Text(
                    'SIGMA',
                    style: TextStyle(
                      color: Color(0xFF2E3A87),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sistem Informasi Guidance\nfor Mahasiswa Akhir',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ================= CARD PUTIH =================
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.hourglass_empty,
                          size: 48,
                          color: Color(0xFF2E3A87),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Menunggu Persetujuan',
                          style: TextStyle(
                            color: Color(0xFF2E3A87),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Jika disetujui anda akan dialihkan ke Dashboard.\n'
                          'Jika ditolak atau 7 hari tanpa respon,\n'
                          'silahkan ajukan kembali.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13),
                        ),

                        const SizedBox(height: 20),

                        // Label dosen
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Dosen Pembimbing pilihan',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Field dosen
                        TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: selectedSupervisor,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                        // Logout
                        const SizedBox(height: 20),

                        SizedBox(
                          width: 170,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Hapus semua data sesi login
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.clear();

                              // Kembali ke halaman login dan hapus semua riwayat halaman
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E3A87),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
