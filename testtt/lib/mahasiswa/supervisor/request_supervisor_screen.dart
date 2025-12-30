import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:testtt/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'request_supervisor_pending.dart';

class RequestSupervisorPage extends StatefulWidget {
  const RequestSupervisorPage({super.key});

  @override
  State<RequestSupervisorPage> createState() => _RequestSupervisorPageState();
}

class _RequestSupervisorPageState extends State<RequestSupervisorPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> supervisors = [];
  bool isLoading = true;
  bool prefsLoaded = false;

  List<String> majors = [];
  List<String> studyPrograms = [];
  List<String> expertises = [];

  String? selectedMajor;
  String? selectedStudyProgram;
  String? selectedExpertise;

  int? loggedInStudentNumber;

  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _initAll();
  }

  Future<void> _initAll() async {
    await loadStudentNumber();
    await Future.wait([fetchLecturers(), fetchFilters()]);
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> loadStudentNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      loggedInStudentNumber = prefs.getInt('student_number');
      loggedInStudentNumber ??= 21010001; // fallback untuk testing
    } catch (_) {}
    if (mounted) setState(() => prefsLoaded = true);
  }

  Future<void> fetchLecturers() async {
    try {
      final res = await http.get(
        Uri.parse("${Config.baseUrl}get_lecturers.php"),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true) {
          supervisors = List<Map<String, dynamic>>.from(data["data"]);
        }
      }
    } catch (_) {}
  }

  Future<void> fetchFilters() async {
    try {
      final majorRes = await http.get(
        Uri.parse("${Config.baseUrl}supervisor/get_majors.php"),
      );
      final progRes = await http.get(
        Uri.parse("${Config.baseUrl}supervisor/get_study_programs.php"),
      );
      final expRes = await http.get(
        Uri.parse("${Config.baseUrl}supervisor/get_expertise.php"),
      );

      if (majorRes.statusCode == 200) {
        final data = jsonDecode(majorRes.body);
        if (data["success"]) {
          majors = List<String>.from(
            (data["data"] as List).map((e) => e["title"].toString()),
          );
        }
      }

      if (progRes.statusCode == 200) {
        final data = jsonDecode(progRes.body);
        if (data["success"]) {
          studyPrograms = List<String>.from(
            (data["data"] as List).map((e) => e["title"].toString()),
          );
        }
      }

      if (expRes.statusCode == 200) {
        final data = jsonDecode(expRes.body);
        if (data["success"]) {
          expertises = List<String>.from(
            (data["data"] as List).map((e) => e["expertise"].toString()),
          );
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!prefsLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (loggedInStudentNumber == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Pemilihan Dosen")),
        body: const Center(
          child: Text("Silakan login ulang untuk mengajukan pembimbing."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : supervisors.isEmpty
            ? const Center(child: Text("Tidak ada data dosen."))
            : FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pemilihan Dosen Pembimbing',
                          style: TextStyle(
                            color: Color(0xFF2E3A87),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(height: 2, color: const Color(0xFF2E3A87)),
                        const SizedBox(height: 16),
                        _buildSearch(),
                        const SizedBox(height: 20),
                        _buildFilterRow(),
                        const SizedBox(height: 10),
                        _buildResetButton(),
                        const SizedBox(height: 24),
                        Column(
                          children: supervisors
                              .where(_filter)
                              .map(_buildCard)
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSearch() => TextField(
    controller: searchController,
    onChanged: (v) => setState(() {}),
    decoration: InputDecoration(
      hintText: 'Cari berdasarkan Nama Dosen',
      prefixIcon: const Icon(Icons.search),
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    ),
  );

  Widget _buildFilterRow() => Row(
    children: [
      Expanded(
        child: _buildDropdown(
          "Major",
          majors,
          selectedMajor,
          (v) => setState(() => selectedMajor = v),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _buildDropdown(
          "Study Program",
          studyPrograms,
          selectedStudyProgram,
          (v) => setState(() => selectedStudyProgram = v),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _buildDropdown(
          "Expertise",
          expertises,
          selectedExpertise,
          (v) => setState(() => selectedExpertise = v),
        ),
      ),
    ],
  );

  Widget _buildResetButton() => Align(
    alignment: Alignment.centerLeft,
    child: ElevatedButton.icon(
      onPressed: () => setState(() {
        selectedMajor = null;
        selectedStudyProgram = null;
        selectedExpertise = null;
        searchController.clear();
      }),
      icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
      label: const Text(
        "Reset Filter",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E3A87),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
  );

  bool _filter(Map<String, dynamic> sup) {
    final name = sup['lecturer_name']?.toString() ?? '';
    final major = sup['major']?.toString() ?? '';
    final program = sup['study_program']?.toString() ?? '';
    final expertise = sup['expertise']?.toString() ?? '';

    final s = searchController.text.toLowerCase();
    return (s.isEmpty || name.toLowerCase().contains(s)) &&
        (selectedMajor == null || major == selectedMajor) &&
        (selectedStudyProgram == null || program == selectedStudyProgram) &&
        (selectedExpertise == null || expertise == selectedExpertise);
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    String? selected,
    Function(String?) onChanged,
  ) {
    final isSel = selected != null;
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: selected,
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.arrow_drop_down,
          color: isSel ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          filled: true,
          fillColor: isSel ? const Color(0xFF2E3A87) : Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isSel ? const Color(0xFF2E3A87) : Colors.black54,
            ),
          ),
        ),
        hint: Text(
          hint,
          style: TextStyle(
            color: isSel ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        onChanged: (v) {
          FocusScope.of(context).unfocus();
          onChanged(v);
        },
        items: items
            .map(
              (val) => DropdownMenuItem(
                value: val,
                child: Text(val, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> sup) {
    final name = sup['lecturer_name']?.toString() ?? '-';
    final nik = sup['employee_number']?.toString() ?? '-';
    final jurusan = sup['major']?.toString() ?? '-';
    final prodi = sup['study_program']?.toString() ?? '-';
    final expertise = sup['expertise']?.toString() ?? '-';
    final current = int.tryParse(sup['current_students'].toString()) ?? 0;
    final max = int.tryParse(sup['max_students'].toString()) ?? 10;
    final isFull = current >= max;

    Color slotColor;
    double ratio = max == 0 ? 0 : current / max;
    if (ratio < 0.7) {
      slotColor = const Color(0xFF78E08F);
    } else if (ratio < 1) {
      slotColor = Colors.orangeAccent;
    } else {
      slotColor = Colors.redAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A87),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundImage: AssetImage('assets/images/profile.png'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow("Nama", name, "NIK", nik),
                const SizedBox(height: 6),
                _infoRow("Jurusan", jurusan, "Program Studi", prodi),
                const SizedBox(height: 6),
                const Text(
                  "Bidang Keahlian",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                Text(
                  expertise,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$current/$max mahasiswa",
                      style: TextStyle(
                        color: slotColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isFull
                          ? null
                          : () => _showConfirmationPopup(context, sup),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6ECFF6),
                        disabledBackgroundColor: Colors.grey.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Pilih",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String leftLabel,
    String leftValue,
    String rightLabel,
    String rightValue,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leftLabel,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                leftValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rightLabel,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                rightValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showConfirmationPopup(BuildContext context, Map<String, dynamic> sup) {
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF6ECFF6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 56, color: Colors.black),
                  const SizedBox(height: 10),
                  const Text(
                    "Konfirmasi Pilihan",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Apakah Anda yakin dengan\npilihan dosen pembimbing anda?\nMasukkan judul Tugas Akhir anda.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: titleController,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Judul wajib diisi' : null,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Input judul Tugas Akhir',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: const Color(0xFFAAE7FF),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Kembali',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final ok = await _submitSupervisorRequest(
                                  studentId: loggedInStudentNumber!,
                                  lecturerId: int.parse(
                                    sup['employee_number'].toString(),
                                  ),
                                  thesisTitle: titleController.text,
                                );

                                if (ok && mounted) {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PendingSupervisorPage(
                                        selectedSupervisor: sup['lecturer_name']
                                            .toString(),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E3A87),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Konfirmasi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _submitSupervisorRequest({
    required int studentId,
    required int lecturerId,
    required String thesisTitle,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("${Config.baseUrl}request_supervisor.php"),
        body: {
          "student_id": studentId.toString(),
          "lecturer_id": lecturerId.toString(),
          "thesis_title": thesisTitle,
        },
      );
      final data = jsonDecode(res.body);
      return data["success"] == true;
    } catch (_) {
      return false;
    }
  }
}
