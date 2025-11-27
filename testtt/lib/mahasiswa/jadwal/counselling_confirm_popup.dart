import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CounsellingConfirmPopup extends StatefulWidget {
  final String scheduleId;
  final String studentId;

  const CounsellingConfirmPopup({
    super.key,
    required this.scheduleId,
    required this.studentId,
  });

  @override
  State<CounsellingConfirmPopup> createState() =>
      _CounsellingConfirmPopupState();
}

class _CounsellingConfirmPopupState extends State<CounsellingConfirmPopup> {
  String? _status; // hadir / tidak_hadir
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitAttendance() async {
    if (_status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih status kehadiran.")),
      );
      return;
    }

    // 🔹 Konversi ke format database
    final apiStatus = _status == "hadir" ? "attend" : "absent";
    final reason = _status == "hadir" ? "hadir" : _reasonController.text.trim();

    if (_status == "tidak_hadir" && reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi alasan ketidakhadiran.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse("http://127.0.0.1/SIGMA/api/attendance_add.php");
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_id": widget.studentId,
          "schedule_id": widget.scheduleId,
          "status": apiStatus, // 🔥 sesuai enum di DB: attend / absent
          "reason": reason, // 🔥 otomatis isi “hadir” kalau hadir
        }),
      );

      setState(() => _isLoading = false);
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Konfirmasi berhasil"),
            backgroundColor: res['status'] == true
                ? Colors.green
                : Colors.redAccent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mengirim data ke server"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 24 : 100,
      ),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff64C9EE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: Colors.black,
                size: 60,
              ),
              const SizedBox(height: 12),
              const Text(
                "Konfirmasi Kehadiran",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // 🔹 Pilihan hadir / tidak hadir
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(
                    label: const Text("✅ Hadir"),
                    selected: _status == "hadir",
                    onSelected: (v) => setState(() => _status = "hadir"),
                    selectedColor: Colors.green.shade300,
                  ),
                  ChoiceChip(
                    label: const Text("❌ Tidak Hadir"),
                    selected: _status == "tidak_hadir",
                    onSelected: (v) => setState(() => _status = "tidak_hadir"),
                    selectedColor: Colors.red.shade300,
                  ),
                ],
              ),

              // 🔹 Muncul alasan kalau tidak hadir
              if (_status == "tidak_hadir") ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _reasonController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Alasan ketidakhadiran",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 25),

              _isLoading
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          child: const Text("Kembali"),
                        ),
                        ElevatedButton(
                          onPressed: _submitAttendance,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2E3A87),
                          ),
                          child: const Text("Konfirmasi"),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
