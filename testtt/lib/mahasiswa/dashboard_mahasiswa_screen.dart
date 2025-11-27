import 'package:flutter/material.dart';
import 'package:testtt/mahasiswa/jadwal/counselling_schedule_screen.dart';
import 'package:testtt/mahasiswa/dokumen/document_screen.dart';
import 'package:testtt/mahasiswa/kanban/kanban_screen.dart';
import 'package:testtt/mahasiswa/akun/profile_screen.dart';

class DashboardMahasiswaScreen extends StatefulWidget {
  const DashboardMahasiswaScreen({super.key});

  @override
  State<DashboardMahasiswaScreen> createState() =>
      _DashboardMahasiswaScreenState();
}

class _DashboardMahasiswaScreenState extends State<DashboardMahasiswaScreen> {
  int currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardHome(),
    CounsellingScheduleScreen(),
    DocumentPage(),
    KanbanScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0.1, 0), // geser dikit dari kanan
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offsetAnimation, child: child),
            );
          },
          child: _pages[currentIndex],
        ),
      ),

      // 🔹 Bottom Navigation Bar
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(
              icon: Icons.home_rounded,
              label: "Home",
              isActive: currentIndex == 0,
              onTap: () => setState(() => currentIndex = 0),
            ),
            _NavIcon(
              icon: Icons.schedule_rounded,
              label: "Jadwal",
              isActive: currentIndex == 1,
              onTap: () => setState(() => currentIndex = 1),
            ),
            _NavIcon(
              icon: Icons.folder_copy_rounded,
              label: "Dokumen",
              isActive: currentIndex == 2,
              onTap: () => setState(() => currentIndex = 2),
            ),
            _NavIcon(
              icon: Icons.checklist_rounded,
              label: "Kanban",
              isActive: currentIndex == 3,
              onTap: () => setState(() => currentIndex = 3),
            ),
            _NavIcon(
              icon: Icons.person_rounded,
              label: "Profil",
              isActive: currentIndex == 4,
              onTap: () => setState(() => currentIndex = 4),
            ),
          ],
        ),
      ),
    );
  }
}

// 🏠 Dashboard Home
class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Color(0xFF2E3A87),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF2E3A87),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 Profil Mahasiswa
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF2E3A87),
                    child: Icon(Icons.person, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Muhammad Aditya Rifa'i",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "4212384778",
                          style: TextStyle(
                            color: Colors.black54,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "D3 Teknik Instrumentasi",
                          style: TextStyle(
                            color: Colors.black54,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 📊 Progress TA
            const Text(
              "Progress TA",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A87),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.5,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                color: const Color(0xFFFF8A4C),
              ),
            ),
            const SizedBox(height: 20),

            // 📢 Pengumuman
            const Text(
              "Pengumuman",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A87),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _announcementCard(
                    "Pendaftaran sidang TA I dibuka, silahkan daftar pada link yang tertera di discord",
                    "PanduanTugasAkhir2025.pdf",
                  ),
                  const SizedBox(width: 10),
                  _announcementCard(
                    "Jadwal bimbingan minggu depan sudah tersedia di sistem.",
                    "Lihat Jadwal Bimbingan.pdf",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 🗓 Upcoming
            const Text(
              "Upcoming",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A87),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),

            _upcomingCard(),
            const SizedBox(height: 10),
            _upcomingCard(),
          ],
        ),
      ),
    );
  }

  // 📄 Kartu Pengumuman
  static Widget _announcementCard(String title, String fileName) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.black87,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.link, size: 16, color: Color(0xFF2E3A87)),
              const SizedBox(width: 6),
              Text(
                fileName,
                style: const TextStyle(
                  color: Color(0xFF2E3A87),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🗓 Kartu Upcoming
  static Widget _upcomingCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A87),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bimbingan Bab I - Offline",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "10 Desember 2025, 16.00\nTA 12.4",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 13,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6ECFF6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
              child: const Text(
                "Lihat Jadwal",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Widget ikon navigasi bawah
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF2E3A87) : Colors.black54,
              size: isActive ? 28 : 25,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? const Color(0xFF2E3A87) : Colors.black54,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
