import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PengajuanCounsellingTab extends StatefulWidget {
  const PengajuanCounsellingTab({super.key});

  @override
  State<PengajuanCounsellingTab> createState() =>
      _PengajuanCounsellingTabState();
}

class _PengajuanCounsellingTabState extends State<PengajuanCounsellingTab> {
  final String baseUrl = "http://127.0.0.1/SIGMA/api/schedules";
  int? lecturerId;

  @override
  void initState() {
    super.initState();
    _loadLecturerId();
  }

  Future<void> _loadLecturerId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lecturerId = prefs.getInt("lecturer_id");
    });
  }

  // -----------------------------------------------------
  // FETCH DATA DARI API
  // -----------------------------------------------------
  Future<List<dynamic>> fetchData() async {
    if (lecturerId == null) return [];

    final res = await http.get(
      Uri.parse(
        "$baseUrl/get_pending_schedules_lecturer.php?lecturer_id=$lecturerId",
      ),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['success'] == true) return body['data'];
    }

    return [];
  }

  // -----------------------------------------------------
  // UPDATE STATUS
  // -----------------------------------------------------
  Future<void> _updateScheduleStatus(String scheduleId, bool isApprove) async {
    final res = await http.post(
      Uri.parse("$baseUrl/update_schedule_status.php"),
      body: {
        "schedule_id": scheduleId,
        "status": isApprove ? "approved" : "rejected",
      },
    );

    Navigator.pop(context);

    final body = jsonDecode(res.body);

    if (body['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApprove ? "Jadwal berhasil disetujui" : "Jadwal telah ditolak",
          ),
          backgroundColor: isApprove ? Colors.green : Colors.redAccent,
        ),
      );

      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memperbarui status.")),
      );
    }
  }

  // -----------------------------------------------------
  // UI
  // -----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (lecturerId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                "Belum ada pengajuan bimbingan.",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final p = data[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3593),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      Text(
                        p["title"] ?? "-",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // SESSION TYPE
                      Row(
                        children: [
                          const Icon(Icons.chat, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            p["session"] ?? "-",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // DATETIME
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            p["datetime"] ?? "-",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // LOCATION
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            p["location"] ?? "-",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ACTION BUTTONS
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // REJECT
                            ElevatedButton.icon(
                              onPressed: () => _showConfirmDialog(
                                context,
                                false,
                                p['id'].toString(),
                              ),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: const Text("Tolak"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // APPROVE
                            ElevatedButton.icon(
                              onPressed: () => _showConfirmDialog(
                                context,
                                true,
                                p['id'].toString(),
                              ),
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: const Text("Setujui"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // -----------------------------------------------------
  // BOTTOM SHEET CONFIRMATION
  // -----------------------------------------------------
  void _showConfirmDialog(
    BuildContext context,
    bool isApprove,
    String scheduleId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFB3E5FC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_available, size: 60, color: Colors.black),
              const SizedBox(height: 12),
              Text(
                isApprove ? "Konfirmasi Persetujuan" : "Konfirmasi Penolakan",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isApprove
                    ? "Yakin ingin menyetujui jadwal ini?"
                    : "Yakin ingin menolak pengajuan ini?",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A3593),
                    ),
                    child: const Text("Kembali"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateScheduleStatus(scheduleId, isApprove);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApprove
                          ? Colors.green
                          : Colors.redAccent,
                    ),
                    child: const Text("Konfirmasi"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
