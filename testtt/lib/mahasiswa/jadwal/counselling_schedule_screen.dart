import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'counselling_request_popup.dart';
import 'counselling_confirm_popup.dart';

class CounsellingScheduleScreen extends StatefulWidget {
  const CounsellingScheduleScreen({super.key});

  @override
  State<CounsellingScheduleScreen> createState() =>
      _CounsellingScheduleScreenState();
}

class _CounsellingScheduleScreenState extends State<CounsellingScheduleScreen> {
  int _selectedTab = 0;
  String? studentId;
  final String baseUrl = "http://127.0.0.1/SIGMA/api";

  final Color primaryColor = const Color(0xFF283593);
  final Color accentColor = const Color(0xFF6ED8F8);

  @override
  void initState() {
    super.initState();
    _loadStudentId();
  }

  Future<void> _loadStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('student_number');
    if (id != null) {
      setState(() {
        studentId = id.toString();
      });
    }
  }

  // ===================== API CALLS ===================== //

  Future<List<dynamic>> fetchApprovedSchedules() async {
    if (studentId == null) return [];
    final response = await http.get(
      Uri.parse('$baseUrl/get_student_schedules.php?student_id=$studentId'),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == 'success') {
        return body['data'];
      }
    }
    return [];
  }

  Future<List<dynamic>> fetchAttendances() async {
    if (studentId == null) return [];
    final response = await http.get(
      Uri.parse('$baseUrl/get_attendances.php?student_id=$studentId'),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == 'success') {
        return body['data'];
      }
    }
    return [];
  }

  Future<List<dynamic>> fetchPendingSchedules() async {
    if (studentId == null) return [];
    final response = await http.get(
      Uri.parse(
        '$baseUrl/get_student_pending_schedules.php?student_id=$studentId',
      ),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == 'success') {
        return body['data'];
      }
    }
    return [];
  }

  // ===================== UI START ===================== //

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          "Counselling",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontSize: 22,
          ),
        ),
      ),
      body: studentId == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 600 ? 20 : 40,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Jadwal Bimbingan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildTab("Utama", 0),
                      const SizedBox(width: 20),
                      _buildTab("Pengajuan", 1),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _selectedTab == 0
                        ? _mainTabContent()
                        : _pendingTabContent(),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const CounsellingRequestPopup(),
          ).then((_) => setState(() {}));
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ===================== TAB BUTTON ===================== //

  Widget _buildTab(String title, int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
              fontSize: 16,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 70,
              color: primaryColor,
            ),
        ],
      ),
    );
  }

  // ===================== CARD REUSABLE ===================== //

  Widget buildScheduleCard({
    required String title,
    required String session,
    required String datetime,
    required String? description,
    required String location,
    required bool isOnline,
    required String statusLabel,
    required Color statusColor,
    VoidCallback? onConfirm,
    bool showConfirmButton = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          _infoRow(Icons.forum, session),
          _infoRow(Icons.calendar_month, datetime),

          if (description != null && description.isNotEmpty)
            _infoRow(Icons.notes, description),

          const SizedBox(height: 4),

          Row(
            children: [
              Icon(
                isOnline ? Icons.link : Icons.location_on,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              isOnline
                  ? Expanded(
                      child: InkWell(
                        onTap: () async {
                          final url = Uri.parse(location);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: Text(
                          location,
                          style: const TextStyle(
                            color: Colors.lightBlueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    )
                  : Text(location, style: const TextStyle(color: Colors.white)),
            ],
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: showConfirmButton
                ? ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Konfirmasi Hadir",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ===================== TAB UTAMA ===================== //

  Widget _mainTabContent() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([fetchApprovedSchedules(), fetchAttendances()]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final schedules = snapshot.data?[0] ?? [];
        final attendances = snapshot.data?[1] ?? [];
        final confirmedIds = attendances
            .map((a) => a['schedule_id'].toString())
            .toSet();

        if (schedules.isEmpty) {
          return const Text(
            "Belum ada jadwal bimbingan dari dosen pembimbing.",
            style: TextStyle(color: Colors.black54),
          );
        }

        return Column(
          children: schedules.map<Widget>((s) {
            final isOnline =
                (s['session'] ?? '').toString().toLowerCase() == 'online';
            final isConfirmed = confirmedIds.contains(s['id'].toString());

            return buildScheduleCard(
              title: s['title'] ?? '-',
              session: s['session'] ?? '-',
              datetime: s['datetime'] ?? '-',
              description: s['description'],
              location: s['location'] ?? '-',
              isOnline: isOnline,
              statusLabel: isConfirmed ? "Sudah Konfirmasi" : "",
              statusColor: Colors.black.withOpacity(0.2),
              showConfirmButton: !isConfirmed,
              onConfirm: isConfirmed
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (_) => CounsellingConfirmPopup(
                          scheduleId: s['id'].toString(),
                          studentId: studentId!,
                        ),
                      ).then((_) => setState(() {}));
                    },
            );
          }).toList(),
        );
      },
    );
  }

  // ===================== TAB PENGAJUAN ===================== //

  Widget _pendingTabContent() {
    return FutureBuilder(
      future: fetchPendingSchedules(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return const Text(
            "Belum ada pengajuan bimbingan.",
            style: TextStyle(color: Colors.black54),
          );
        }

        return Column(
          children: data.map<Widget>((item) {
            return buildScheduleCard(
              title: item['title'] ?? '-',
              session: item['session'] ?? '-',
              datetime: item['datetime'] ?? '-',
              description: item['description'] ?? '-',
              location: item['location'] ?? '-',
              isOnline: (item['session'] ?? '').toLowerCase() == 'online',
              statusLabel: "Menunggu Konfirmasi",
              statusColor: Colors.black.withOpacity(0.25),
              showConfirmButton: false,
            );
          }).toList(),
        );
      },
    );
  }

  // ===================== REUSABLE TEXT ROW ===================== //

  Widget _infoRow(IconData icon, String? text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text ?? '-',
              style: const TextStyle(color: Colors.white, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
