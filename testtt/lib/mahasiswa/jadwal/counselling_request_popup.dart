import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CounsellingRequestPopup extends StatefulWidget {
  const CounsellingRequestPopup({super.key});

  @override
  State<CounsellingRequestPopup> createState() =>
      _CounsellingRequestPopupState();
}

class _CounsellingRequestPopupState extends State<CounsellingRequestPopup> {
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final locationC = TextEditingController();

  String? sesi;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final String baseUrl = "http://127.0.0.1/SIGMA/api";

  // =====================================================
  // 🔥 Ambil lecturer_id (employee_number) dari API
  // =====================================================
  Future<int?> getLecturerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getInt("student_number");

      if (studentId == null) return null;

      final res = await http.post(
        Uri.parse("$baseUrl/get_lecturer_by_student.php"),
        body: {"student_id": studentId.toString()},
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        return int.tryParse(data["lecturer_id"].toString());
      }

      return null;
    } catch (e) {
      print("Error getLecturerId: $e");
      return null;
    }
  }

  // =====================================================
  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white.withOpacity(0.9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );

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

  // =====================================================
  // 🔥 SUBMIT SCHEDULE (pending)
  // =====================================================
  Future<void> submitSchedule() async {
    if (sesi == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi semua field!")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt("student_number");

    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mahasiswa tidak ditemukan")),
      );
      return;
    }

    // 🔥 Ambil lecturer ID dari DB
    final lecturerId = await getLecturerId();
    if (lecturerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dosen pembimbing tidak ditemukan")),
      );
      return;
    }

    // Format datetime
    final dt = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    ).toString();

    // 🔥 Kirim ke PHP
    final res = await http.post(
      Uri.parse("$baseUrl/create_student_schedule.php"),
      body: {
        "student_id": studentId.toString(),
        "lecture_id": lecturerId.toString(), // ✔ FIX PENTING!!
        "title": titleC.text,
        "session": sesi!,
        "datetime": dt,
        "location": locationC.text,
        "description": descC.text,
      },
    );

    final data = jsonDecode(res.body);

    if (data["status"] == "success") {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pengajuan berhasil dikirim!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Gagal mengajukan jadwal.")),
      );
    }
  }

  // =====================================================
  // UI POPUP
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade100.withOpacity(0.97),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                    child: Text(
                      "Ajukan Jadwal Bimbingan",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // JUDUL
                  const Text("Judul Bimbingan"),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleC,
                    decoration: _inputDecoration("Masukan Judul Bimbingan"),
                  ),
                  const SizedBox(height: 14),

                  // SESI
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
                  const SizedBox(height: 14),

                  // TANGGAL
                  const Text("Tanggal"),
                  const SizedBox(height: 6),
                  TextField(
                    readOnly: true,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (d != null) setState(() => selectedDate = d);
                    },
                    decoration: _inputDecoration(
                      selectedDate == null
                          ? "Pilih Tanggal"
                          : _formatDate(selectedDate!),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // WAKTU
                  const Text("Waktu"),
                  const SizedBox(height: 6),
                  TextField(
                    readOnly: true,
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t != null) setState(() => selectedTime = t);
                    },
                    decoration: _inputDecoration(
                      selectedTime == null
                          ? "Pilih Waktu"
                          : selectedTime!.format(context),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // DESKRIPSI
                  const Text("Deskripsi"),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descC,
                    maxLines: 2,
                    decoration: _inputDecoration("Tambahkan deskripsi"),
                  ),
                  const SizedBox(height: 14),

                  // LOKASI / LINK
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

                  Center(
                    child: ElevatedButton(
                      onPressed: submitSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF283593),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Ajukan",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
