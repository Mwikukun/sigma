import 'package:flutter/material.dart';
import 'dokumen/document_screen_dosen.dart';
import 'list_mahasiswa/list_mahasiswa.dart';
import 'jadwal/main_counselling.dart';
import 'akun/profile_screen_dosen.dart';

class DashboardDosenScreen extends StatefulWidget {
  const DashboardDosenScreen({super.key});

  @override
  State<DashboardDosenScreen> createState() => _DashboardDosenScreenState();
}

class _DashboardDosenScreenState extends State<DashboardDosenScreen> {
  int currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardDosenHome(),
    MainCounsellingPage(),
    DocumentScreen(),
    ListMahasiswaScreen(),
    ProfileScreenDosen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: SafeArea(child: _pages[currentIndex]),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(
              icon: Icons.home,
              label: "Home",
              isActive: currentIndex == 0,
              onTap: () => setState(() => currentIndex = 0),
            ),
            _NavIcon(
              icon: Icons.calendar_today,
              label: "Jadwal",
              isActive: currentIndex == 1,
              onTap: () => setState(() => currentIndex = 1),
            ),
            _NavIcon(
              icon: Icons.folder,
              label: "Dokumen",
              isActive: currentIndex == 2,
              onTap: () => setState(() => currentIndex = 2),
            ),
            _NavIcon(
              icon: Icons.group,
              label: "Mahasiswa",
              isActive: currentIndex == 3,
              onTap: () => setState(() => currentIndex = 3),
            ),
            _NavIcon(
              icon: Icons.person,
              label: "Akun",
              isActive: currentIndex == 4,
              onTap: () => setState(() => currentIndex = 4),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// HOME DASHBOARD
// ===============================
class _DashboardDosenHome extends StatelessWidget {
  const _DashboardDosenHome();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 16 : 40,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selamat datang, Dosen!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xff2E3A87),
            ),
          ),
          const SizedBox(height: 16),

          // Statistik 3 box
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _StatCard(title: "Mahasiswa", value: "12"),
              _StatCard(title: "Pengajuan", value: "3"),
              _StatCard(title: "Jadwal", value: "5"),
            ],
          ),
          const SizedBox(height: 30),

          const Text(
            "Aktivitas Terbaru",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff2E3A87),
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Card biru lembut berisi daftar aktivitas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffE8EAF6),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: const [
                _ActivityItem(
                  title: "Revisi laporan oleh Budi",
                  time: "2 jam yang lalu",
                ),
                Divider(color: Colors.white70, thickness: 1),
                _ActivityItem(
                  title: "Pengajuan jadwal oleh Sinta",
                  time: "5 jam yang lalu",
                ),
                Divider(color: Colors.white70, thickness: 1),
                _ActivityItem(
                  title: "Upload dokumen baru oleh Andi",
                  time: "Kemarin",
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ===============================
// KOTAK STATISTIK
// ===============================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xffE6E8F9),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff2E3A87),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// ITEM AKTIVITAS
// ===============================
class _ActivityItem extends StatelessWidget {
  final String title;
  final String time;
  const _ActivityItem({required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.notifications, color: Color(0xff2E3A87)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===============================
// NAVIGASI BAWAH
// ===============================
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xff2E3A87) : Colors.black54,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? const Color(0xff2E3A87) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
