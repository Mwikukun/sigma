import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testtt/config.dart';

class SupervisorInformationScreen extends StatefulWidget {
  const SupervisorInformationScreen({super.key});

  @override
  State<SupervisorInformationScreen> createState() =>
      _SupervisorInformationScreenState();
}

class _SupervisorInformationScreenState
    extends State<SupervisorInformationScreen> {
  bool isLoading = true;

  String name = "-";
  String nik = "-";
  String major = "-";
  String studyProgram = "-";
  String expertise = "-";
  String phone = "-";

  @override
  void initState() {
    super.initState();
    _loadSupervisor();
  }

  Future<void> _loadSupervisor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentNumber = prefs.getInt('student_number');

      if (studentNumber == null) {
        setState(() => isLoading = false);
        return;
      }

      final res = await http.post(
        Uri.parse("${Config.baseUrl}get_supervisor_by_student.php"),
        body: {"student_id": studentNumber.toString()},
      );

      debugPrint("STATUS: ${res.statusCode}");
      debugPrint("BODY: ${res.body}");

      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        setState(() {
          name = data['data']['lecturer_name']?.toString() ?? "-";
          nik = data['data']['nik']?.toString() ?? "-";
          major = data['data']['major']?.toString() ?? "-";
          studyProgram = data['data']['study_program']?.toString() ?? "-";
          expertise = data['data']['expertise']?.toString() ?? "-";
          phone = data['data']['phone_number']?.toString() ?? "-";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  Widget infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xff2E3A87), // 🟣 LABEL BIRU TUA
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFAAE7FF), // 🟦 FIELD
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87, // ✍️ ISI TEKS
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF6ECFF6), // 🔵 POPUP
          borderRadius: BorderRadius.circular(20),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Informasi Dosen Pembimbing",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2E3A87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  infoItem("Nama Dosen Pembimbing", name),
                  infoItem("NIK", nik),
                  infoItem("Jurusan", major),
                  infoItem("Program Studi", studyProgram),
                  infoItem("Keahlian", expertise),
                  infoItem("No. Telpon", phone),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2E3A87),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Kembali",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
