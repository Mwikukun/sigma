import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main_counselling.dart';

class ListMahasiswaPage extends StatefulWidget {
  final Schedule schedule;

  const ListMahasiswaPage({super.key, required this.schedule});

  @override
  State<ListMahasiswaPage> createState() => _ListMahasiswaPageState();
}

class _ListMahasiswaPageState extends State<ListMahasiswaPage> {
  final String baseUrl = "http://127.0.0.1/SIGMA/api/schedules";
  List<dynamic> students = [];
  bool isLoading = true;

  int? lecturerId;

  @override
  void initState() {
    super.initState();
    loadLecturerId();
  }

  // 🔹 Ambil lecturer_id dari SharedPreferences
  Future<void> loadLecturerId() async {
    final prefs = await SharedPreferences.getInstance();
    lecturerId = prefs.getInt('lecturer_id');

    if (lecturerId != null) {
      fetchStudents();
    } else {
      debugPrint("❌ lecturer_id tidak ditemukan di SharedPreferences");
      setState(() => isLoading = false);
    }
  }

  // 🔹 Ambil daftar mahasiswa + status kehadiran
  Future<void> fetchStudents() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse(
        "$baseUrl/get_attendances_by_schedule.php"
        "?schedule_id=${widget.schedule.id}"
        "&lecturer_id=$lecturerId",
      );

      debugPrint("🔍 CALL API: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("📥 Response: $data");

        if (data['status'] == 'success') {
          setState(() {
            students = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("❌ fetchStudents error: $e");
    }

    setState(() => isLoading = false);
  }

  // 🔹 Warna status
  Color getStatusColor(String status) {
    switch (status) {
      case "hadir":
        return Colors.green.shade400;
      case "tidak_hadir":
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  // 🔹 Format status
  String formatStatus(String status) {
    switch (status) {
      case "hadir":
        return "Hadir";
      case "tidak_hadir":
        return "Tidak Hadir";
      default:
        return "Belum Konfirmasi";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWideScreen ? 80 : 16,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.indigo),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Student List",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🔹 Info Jadwal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Judul: ${widget.schedule.title}"),
                    Text("Sesi: ${widget.schedule.sesi}"),
                    Text(
                      "Tanggal: ${widget.schedule.date.day}-"
                      "${widget.schedule.date.month}-"
                      "${widget.schedule.date.year}",
                    ),
                    Text("Waktu: ${widget.schedule.time.format(context)}"),
                    Text("Lokasi: ${widget.schedule.location}"),
                    if (widget.schedule.description.isNotEmpty)
                      Text("Deskripsi: ${widget.schedule.description}"),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 Daftar mahasiswa
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : students.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada mahasiswa bimbingan.",
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final s = students[index];
                          final color = getStatusColor(s['status']);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
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
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // 🔹 Info Mahasiswa
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          s['nim'] ?? '-',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          s['major'] ?? '-',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          s['project'] ?? '-',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            formatStatus(s['status']),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        if (s['status'] == "tidak_hadir" &&
                                            s['reason'] != null &&
                                            s['reason'].toString().isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              "Alasan: ${s['reason']}",
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
