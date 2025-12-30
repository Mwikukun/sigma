import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:testtt/mahasiswa/jadwal/counselling_schedule_screen.dart';
import 'package:testtt/mahasiswa/dokumen/document_screen.dart';
import 'package:testtt/mahasiswa/kanban/kanban_screen.dart';
import 'package:testtt/mahasiswa/akun/profile_screen.dart';
import 'package:testtt/mahasiswa/notification/notification_page.dart';

import '../../config.dart';

class DashboardMahasiswaScreen extends StatefulWidget {
  const DashboardMahasiswaScreen({super.key});

  @override
  State<DashboardMahasiswaScreen> createState() =>
      _DashboardMahasiswaScreenState();
}

class _DashboardMahasiswaScreenState extends State<DashboardMahasiswaScreen> {
  int currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _DashboardHome(
        onGoToJadwal: () {
          setState(() {
            currentIndex = 1;
          });
        },
      ),
      const CounsellingScheduleScreen(),
      const DocumentPage(),
      const KanbanScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0.1, 0),
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

      bottomNavigationBar: Container(
        color: const Color(0xFF2E3A87),
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
              icon: Icons.calendar_month_rounded,
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

//
// ============================ DASHBOARD HOME ============================
//

class _DashboardHome extends StatefulWidget {
  final VoidCallback onGoToJadwal;

  const _DashboardHome({super.key, required this.onGoToJadwal});

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  double progressTA = 0.0;
  bool loading = true;

  List<dynamic> announcements = [];
  bool loadingAnnouncements = true;

  String _cleanFileName(String file) {
    String name = file.split('/').last;
    name = name.replaceFirst(RegExp(r'^[0-9\-_\.]+'), '');
    return name;
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadProgressTA();
    _loadAnnouncements();
    _loadUpcoming();
  }

  // ================= PROFILE =================
  String name = "";
  String nim = "";
  String judulThesis = "";

  // ================= UPCOMING =================
  List upcoming = [];
  bool loadingUpcoming = true;

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('student_number') ?? 0;

    final res = await http.post(
      Uri.parse("${Config.baseUrl}get_student_profile.php"),
      body: {"student_id": studentId.toString()},
    );

    final data = jsonDecode(res.body);

    if (data["success"] == true) {
      setState(() {
        name = data["data"]["name"];
        nim = data["data"]["student_number"].toString();
        judulThesis =
            (data["data"]["thesis"] == null ||
                data["data"]["thesis"].toString().isEmpty)
            ? "Belum ada judul TA"
            : data["data"]["thesis"];
      });
    }
  }

  Future<void> _loadProgressTA() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getInt('student_number') ?? 0;

      final response = await http.post(
        Uri.parse("${Config.baseUrl}get_activities.php"),
        body: {"student_id": studentId.toString()},
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        List tasks = data["data"];

        double total = 0;
        for (var t in tasks) {
          total += double.tryParse(t["percentage"].toString()) ?? 0;
        }

        setState(() {
          progressTA = tasks.isEmpty ? 0 : (total / tasks.length) / 100;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> _loadAnnouncements() async {
    try {
      final res = await http.get(
        Uri.parse("${Config.baseUrl}get_announcements.php"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data["success"] == true) {
          setState(() {
            announcements = data["data"] ?? [];
            loadingAnnouncements = false;
          });
          return;
        }
      }

      setState(() {
        announcements = [];
        loadingAnnouncements = false;
      });
    } catch (_) {
      setState(() {
        announcements = [];
        loadingAnnouncements = false;
      });
    }
  }

  Future<void> _loadUpcoming() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('student_number') ?? 0;

    final res = await http.post(
      Uri.parse("${Config.baseUrl}get_upcoming_schedule.php"),
      body: {"student_id": studentId.toString()},
    );

    final data = jsonDecode(res.body);

    setState(() {
      upcoming = data["success"] == true ? data["data"] : [];
      loadingUpcoming = false;
    });
  }

  // File loader path: admin/uploads/<file>
  String _fileUrl(String? fileName) {
    if (fileName?.isEmpty ?? true) return "";

    String base = Config.baseUrl;
    base = base.replaceAll("/api/", "/admin/uploads/");

    return base + fileName!;
  }

  Future<void> _openFile(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Tidak dapat membuka file")));
    }
  }

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
          ),
        ],
      ),

      //
      // ============================ BODY ============================
      //
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileCard(),

            const SizedBox(height: 20),

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
                value: loading ? 0 : progressTA,
                minHeight: 12,
                backgroundColor: const Color(0x80FF8A4C),
                color: const Color(0xFFFF8A4C),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              loading
                  ? "Loading..."
                  : "${(progressTA * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A87),
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 20),

            //
            // ======================= Pengumuman =======================
            //
            const Text(
              "Pengumuman",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A87),
              ),
            ),

            const SizedBox(height: 10),

            loadingAnnouncements
                ? const Center(child: CircularProgressIndicator())
                : announcements.isEmpty
                ? const Text("Belum ada pengumuman")
                : SingleChildScrollView(
                    child: Column(
                      children: announcements.map((a) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _announcementCard(
                            title: a["title"] ?? "",
                            description: a["description"] ?? "",
                            startDate: a["start_date"] ?? "",
                            endDate: a["end_date"] ?? "",
                            link: a["link"] ?? "",
                            onOpen: () => _openFile(_fileUrl(a["link"])),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

            const SizedBox(height: 25),

            const Text(
              "Upcoming",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A87),
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 10),

            loadingUpcoming
                ? const Center(child: CircularProgressIndicator())
                : upcoming.isEmpty
                ? const Text("Tidak ada jadwal terdekat")
                : Column(
                    children: upcoming.map((u) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _upcomingCardDynamic(u, widget.onGoToJadwal),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  //
  // ======================= Widgets =======================
  //

  Widget _profileCard() {
    return Container(
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
              children: [
                Text(
                  name.isEmpty ? "Loading..." : name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(nim, style: const TextStyle(fontFamily: 'Poppins')),
                const SizedBox(height: 2),
                Text(
                  judulThesis,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  //                    ANNOUNCEMENT CARD
  // ----------------------------------------------------------

  Widget _announcementCard({
    required String title,
    required String description,
    required String startDate,
    required String endDate,
    required String link,
    VoidCallback? onOpen,
  }) {
    return Container(
      width: double.infinity, // FULL WIDTH
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFF2E3A87), // BIRU
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TANGGAL
          Text(
            "$startDate → $endDate",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontFamily: 'Poppins',
            ),
          ),

          const SizedBox(height: 6),

          // JUDUL
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),

          const SizedBox(height: 6),

          // DESKRIPSI
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),

          const SizedBox(height: 10),

          // LINK (KALO ADA)
          if (link.isNotEmpty)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onOpen,
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_file,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        _cleanFileName(link),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          decoration: TextDecoration.none,
                        ),
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

  // ----------------------------------------------------------
  //                    UPCOMING CARD
  // ----------------------------------------------------------
  Widget _upcomingCardDynamic(Map u, VoidCallback onGoToJadwal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A87),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${u['title']} - ${u['session']}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "${u['datetime']}\n${u['location'] ?? '-'}",
            style: const TextStyle(
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
              onPressed: onGoToJadwal,
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

//
// ========================= BOTTOM NAV ICON =========================
//

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
              color: isActive
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : const Color.fromARGB(255, 255, 255, 255),
              size: isActive ? 28 : 25,
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive
                    ? const Color.fromARGB(255, 245, 245, 245)
                    : const Color.fromARGB(255, 245, 245, 245),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
