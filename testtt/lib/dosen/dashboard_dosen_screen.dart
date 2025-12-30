import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testtt/config.dart';
import 'dart:async';

import 'dokumen/document_screen_dosen.dart';
import 'list_mahasiswa/list_mahasiswa.dart';
import 'jadwal/main_counselling.dart';
import 'akun/profile_screen_dosen.dart';
import 'notification/notification_page_dosen.dart';

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
              icon: Icons.group,
              label: "Mahasiswa",
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

// ===============================
// HOME DASHBOARD DOSEN (STATEFUL)
// ===============================
class _DashboardDosenHome extends StatefulWidget {
  const _DashboardDosenHome();

  @override
  State<_DashboardDosenHome> createState() => _DashboardDosenHomeState();
}

class _DashboardDosenHomeState extends State<_DashboardDosenHome> {
  List<Map<String, dynamic>> activities = [];
  bool isLoading = true;

  String lecturerName = '';
  String lecturerNip = '';
  String lecturerProdi = '';

  int totalStudents = 0;
  int pendingStudents = 0;
  int pendingSchedules = 0;
  int pendingDocuments = 0;

  @override
  void initState() {
    super.initState();
    fetchActivities();
    loadLecturerProfile();
    fetchDashboardStats();

    // refresh waktu tiap 1 menit
    Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> loadLecturerProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final lecturerId = prefs.getInt('lecturer_id');

    if (lecturerId == null) return;

    try {
      final res = await http.get(
        Uri.parse(
          '${Config.baseUrl}get_lecturer_profile.php?lecturer_id=$lecturerId',
        ),
      );

      final json = jsonDecode(res.body);

      if (json['success'] == true) {
        setState(() {
          lecturerName = json['data']['name'] ?? "-";
          lecturerNip = json['data']['nip']?.toString() ?? "-";
          lecturerProdi = json['data']['study_program'] ?? "-";
        });
      }
    } catch (e) {
      debugPrint("❌ loadLecturerProfile error: $e");
    }
  }

  Future<void> fetchDashboardStats() async {
    final prefs = await SharedPreferences.getInstance();
    final lecturerId = prefs.getInt('lecturer_id');

    if (lecturerId == null) return;

    try {
      final res = await http.get(
        Uri.parse(
          '${Config.baseUrl}get_dashboard_stats.php?lecturer_id=$lecturerId',
        ),
      );

      final json = jsonDecode(res.body);

      if (json['success'] == true) {
        setState(() {
          totalStudents = json['data']['total_students'];
          pendingStudents = json['data']['pending_students'];
          pendingSchedules = json['data']['pending_schedules'];
          pendingDocuments = json['data']['pending_documents'];
        });
      }
    } catch (e) {
      debugPrint("❌ fetchDashboardStats error: $e");
    }
  }

  Future<void> fetchActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final lecturerId = prefs.getInt('lecturer_id');

    if (lecturerId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final res = await http.get(
        Uri.parse(
          '${Config.baseUrl}get_dashboard_activity.php?lecturer_id=$lecturerId',
        ),
      );

      final json = jsonDecode(res.body);

      if (json['success'] == true) {
        activities = List<Map<String, dynamic>>.from(json['data']);
      }
    } catch (e) {
      debugPrint("❌ fetchActivities error: $e");
    }

    setState(() => isLoading = false);
  }

  Widget _profileCardDosen() {
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
                  lecturerName.isEmpty ? "Loading..." : lecturerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lecturerNip,
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 2),
                Text(
                  lecturerProdi,
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff2E3A87),
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xff2E3A87),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationPageDosen(),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth < 600 ? 16 : 40,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileCardDosen(),
            const SizedBox(height: 20),

            Row(
              children: [
                _StatCard(
                  title: "Total Mahasiswa",
                  value: totalStudents.toString(),
                  color: Color(0xff6ECFF6),
                ),
                _StatCard(
                  title: "Persetujuan Mahasiswa",
                  value: pendingStudents.toString(),
                  color: Color(0xffFF8A4C),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  title: "Jadwal Konsultasi",
                  value: pendingSchedules.toString(),
                  color: Color(0xff7D83FF),
                ),
                _StatCard(
                  title: "Dokumen Pending",
                  value: pendingDocuments.toString(),
                  color: Color(0xffFF5E5E),
                ),
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

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff2E3A87),
                borderRadius: BorderRadius.circular(16),
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : activities.isEmpty
                  ? const Text(
                      "Belum ada aktivitas",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    )
                  : Column(
                      children: activities.map((item) {
                        return Column(
                          children: [
                            _ActivityItem(
                              title: item['description'],
                              time: timeAgo(item['created_at']),
                            ),
                            const Divider(color: Colors.white70),
                          ],
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

String timeAgo(String dateTimeString) {
  final dateTime = DateTime.parse(dateTimeString);
  final now = DateTime.now();

  final diff = now.difference(dateTime);

  if (diff.inSeconds < 60) {
    return "baru saja";
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes} menit lalu";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} jam lalu";
  } else if (diff.inDays < 7) {
    return "${diff.inDays} hari lalu";
  } else {
    return "${dateTime.day.toString().padLeft(2, '0')}-"
        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.year}";
  }
}

// ===============================
// Kartu Statistik
// ===============================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// Item Aktivitas
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
        const Icon(Icons.notifications, color: Colors.white, size: 30),
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
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white70,
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
// Bottom Navigation Icon
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
            color: isActive
                ? const Color.fromARGB(255, 255, 255, 255)
                : const Color.fromARGB(255, 255, 255, 255),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ],
      ),
    );
  }
}
