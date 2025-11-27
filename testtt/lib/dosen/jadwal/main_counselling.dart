// ... (import tetap sama)
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'list_mahasiswa_page.dart';
import 'pengajuan_counselling_tab.dart';

// ==================== MODEL ====================
class Schedule {
  final int id;
  final String title;
  final String sesi;
  final DateTime date;
  final TimeOfDay time;
  final String location;
  final String description;
  final bool isDefault;

  Schedule({
    required this.id,
    required this.title,
    required this.sesi,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    this.isDefault = false,
  });
}

// ==================== HALAMAN UTAMA ====================
class MainCounsellingPage extends StatefulWidget {
  const MainCounsellingPage({super.key});

  @override
  State<MainCounsellingPage> createState() => _MainCounsellingPageState();
}

class _MainCounsellingPageState extends State<MainCounsellingPage>
    with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF283593);
  final Color accentColor = const Color(0xFF6ED8F8);

  late TabController _tabController;
  final List<Schedule> schedules = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? lecturerId = prefs.getInt('lecturer_id'); // employee_number

      if (lecturerId == null) {
        debugPrint("❌ lecturer_id tidak ditemukan");
        return;
      }

      debugPrint("📌 Fetch schedules for lecturer_id = $lecturerId");

      final uri = Uri.parse("http://127.0.0.1/SIGMA/api/schedules/list.php");
      final response = await http.post(
        uri,
        body: {"lecturer_id": lecturerId.toString()},
      );

      debugPrint("📌 Response: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);

        if (res['status'] == true && res['data'] != null) {
          setState(() {
            schedules.clear();
            for (var item in res['data']) {
              final dateTime = DateTime.parse(item['datetime']);
              schedules.add(
                Schedule(
                  id: int.parse(item['id'].toString()),
                  title: item['title'] ?? '-',
                  sesi: (item['session'] ?? '').toString(),
                  date: dateTime,
                  time: TimeOfDay.fromDateTime(dateTime),
                  location: item['location'] ?? '-',
                  description: item['description'] ?? '-',
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetchSchedules: $e");
    }
  }

  String _formatDateTime(DateTime date, TimeOfDay time) {
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    final day = date.day;
    final month = monthNames[date.month - 1];
    final year = date.year;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$day $month $year, $hour:$minute";
  }

  Future<void> _openAddSheet() async {
    final Schedule? result = await showModalBottomSheet<Schedule>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddCounsellingSheet(),
    );

    if (result != null) {
      setState(() {
        schedules.insert(0, result);
      });
      _tabController.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  "Jadwal Bimbingan",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const Spacer(),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _openAddSheet,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: primaryColor,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Utama"),
                Tab(text: "Pengajuan"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: schedules.isEmpty
                      ? const Center(child: Text("Belum Ada Bimbingan"))
                      : ListView.separated(
                          itemCount: schedules.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final s = schedules[index];
                            return _buildScheduleCard(s);
                          },
                        ),
                ),
                const PengajuanCounsellingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== KARTU JADWAL ====================
  Widget _buildScheduleCard(Schedule s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.forum, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(s.sesi, style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                _formatDateTime(s.date, s.time),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(s.description, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: s.sesi.toLowerCase() == "online"
                    ? MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
                            final url = Uri.parse(s.location);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          child: Text(
                            s.location,
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      )
                    : Text(
                        s.location,
                        style: const TextStyle(color: Colors.white),
                        softWrap: true,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListMahasiswaPage(schedule: s),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Lihat Mahasiswa",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== BOTTOM SHEET TAMBAH JADWAL ====================
class AddCounsellingSheet extends StatefulWidget {
  const AddCounsellingSheet({super.key});

  @override
  State<AddCounsellingSheet> createState() => _AddCounsellingSheetState();
}

class _AddCounsellingSheetState extends State<AddCounsellingSheet> {
  final TextEditingController titleC = TextEditingController();
  final TextEditingController descriptionC = TextEditingController();
  final TextEditingController locationC = TextEditingController();
  String? sesi;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String _formatDate(DateTime d) {
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return "${d.day} ${monthNames[d.month - 1]} ${d.year}";
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );

  Future<void> _submitSchedule() async {
    if (titleC.text.trim().isEmpty ||
        sesi == null ||
        selectedDate == null ||
        selectedTime == null ||
        locationC.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi semua field")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      int? lecturerId = prefs.getInt('lecturer_id') ?? prefs.getInt('user_id');
      if (lecturerId == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal: ID dosen tidak ditemukan")),
        );
        return;
      }

      final datetime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      ).toIso8601String();

      final uri = Uri.parse("http://127.0.0.1/SIGMA/api/schedules/add.php");
      final body = {
        "lecturer_id": lecturerId,
        "title": titleC.text.trim(),
        "session": sesi!.toLowerCase(),
        "datetime": datetime,
        "description": descriptionC.text.trim(),
        "location": locationC.text.trim(),
      };

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      Navigator.of(context).pop();

      final res = jsonDecode(response.body);
      if (response.statusCode == 200 && res['status'] == true) {
        final newSchedule = Schedule(
          id: 0, // 🔥 dummy sementara
          title: titleC.text.trim(),
          sesi: sesi!,
          date: selectedDate!,
          time: selectedTime!,
          location: locationC.text.trim(),
          description: descriptionC.text.trim(),
        );
        Navigator.of(context).pop(newSchedule);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal: ${res['message']}")));
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.lightBlue.shade100.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Text(
                "Tambah Jadwal Bimbingan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text("Judul Bimbingan"),
              const SizedBox(height: 6),
              TextField(
                controller: titleC,
                decoration: _inputDecoration("Masukan Judul Bimbingan"),
              ),
              const SizedBox(height: 12),
              const Text("Sesi"),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: sesi,
                items: ["Online", "Offline"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => sesi = v),
                decoration: _inputDecoration("Pilih Sesi"),
              ),
              const SizedBox(height: 12),
              const Text("Tanggal"),
              const SizedBox(height: 6),
              TextField(
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (date != null) setState(() => selectedDate = date);
                },
                decoration: _inputDecoration(
                  selectedDate == null
                      ? "Pilih Tanggal"
                      : _formatDate(selectedDate!),
                ),
              ),
              const SizedBox(height: 12),
              const Text("Waktu"),
              const SizedBox(height: 6),
              TextField(
                readOnly: true,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) setState(() => selectedTime = time);
                },
                decoration: _inputDecoration(
                  selectedTime == null
                      ? "Pilih Waktu"
                      : selectedTime!.format(context),
                ),
              ),
              const SizedBox(height: 12),
              const Text("Deskripsi"),
              const SizedBox(height: 6),
              TextField(
                controller: descriptionC,
                maxLines: 3,
                decoration: _inputDecoration("Masukan Deskripsi Bimbingan"),
              ),
              const SizedBox(height: 12),
              Text(sesi == "Online" ? "Link Zoom" : "Lokasi"),
              const SizedBox(height: 6),
              TextField(
                controller: locationC,
                keyboardType: sesi == "Online"
                    ? TextInputType.url
                    : TextInputType.text,
                decoration: _inputDecoration(
                  sesi == "Online" ? "Masukan Link Zoom" : "Masukan Lokasi",
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF283593),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _submitSchedule,
                  child: const Text(
                    "Tambah",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleC.dispose();
    descriptionC.dispose();
    locationC.dispose();
    super.dispose();
  }
}
