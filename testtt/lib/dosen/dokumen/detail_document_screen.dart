import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:testtt/config.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'kanban_screen_dosen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailDocumentScreen extends StatefulWidget {
  final String studentId;
  final String nama;
  final String nim;
  final String judul;

  const DetailDocumentScreen({
    super.key,
    required this.studentId,
    required this.nama,
    required this.nim,
    required this.judul,
  });

  @override
  State<DetailDocumentScreen> createState() => _DetailDocumentScreenState();
}

class _DetailDocumentScreenState extends State<DetailDocumentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List documents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchDocuments();
  }

  // FETCH DOCUMENTS
  Future<void> fetchDocuments() async {
    try {
      var url = Uri.parse("${Config.baseUrl}get_documents_by_student.php");

      var response = await http
          .post(url, body: {"student_id": widget.studentId})
          .timeout(const Duration(seconds: 8));

      var data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          documents = data["data"];
          isLoading = false;
        });
      }
    } catch (e) {
      print("fetchDocuments ERROR: $e");
    }
  }

  // GET LAST FEEDBACK
  Future<Map<String, dynamic>?> fetchLastFeedback(String docId) async {
    try {
      final url = Uri.parse(
        "${Config.baseUrl}get_last_feedback.php?document_id=$docId",
      );

      final res = await http.get(url).timeout(const Duration(seconds: 8));

      final data = jsonDecode(res.body);
      return data["data"];
    } catch (e) {
      print("fetchLastFeedback ERROR: $e");
      return null;
    }
  }

  // FILTER BY STATUS
  List getDocumentsByStatus(String status) {
    switch (status) {
      case "Pending":
        return documents.where((d) => d["status"] == "pending").toList();
      case "Revisi":
        return documents.where((d) => d["status"] == "revision").toList();
      case "Disetujui":
        return documents.where((d) => d["status"] == "approved").toList();
    }
    return [];
  }

  // PICK FILE
  Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf", "docx"],
      withData: true,
    );
    return result?.files.first;
  }

  // SUBMIT FEEDBACK
  Future<void> submitFeedback({
    required String docId,
    required String comment,
    required String newStatus,
    PlatformFile? file,
  }) async {
    try {
      final uri = Uri.parse("${Config.baseUrl}add_feedback.php");
      final request = http.MultipartRequest("POST", uri);

      request.fields["document_id"] = docId;
      request.fields["comment"] = comment;

      if (file != null) {
        if (kIsWeb) {
          request.files.add(
            http.MultipartFile.fromBytes(
              "attachment",
              file.bytes!,
              filename: file.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath("attachment", file.path!),
          );
        }
      }

      await request.send();

      // UPDATE STATUS
      await http.post(
        Uri.parse("${Config.baseUrl}update_status.php"),
        body: {"document_id": docId, "status": newStatus},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status berhasil diubah menjadi $newStatus")),
      );

      fetchDocuments();
    } catch (e) {
      print("submitFeedback ERROR: $e");
    }
  }

  // ================== TANDAI SELESAI MAHASISWA ==================
  Future<void> _confirmFinishStudent() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff8FD3FE), // konsisten
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ICON ORANG
            const Icon(Icons.person, size: 50, color: Colors.black87),

            const SizedBox(height: 10),

            // TITLE
            const Text(
              "Konfirmasi Pilihan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            // DESCRIPTION
            const Text(
              "Apakah Anda yakin ingin menandai mahasiswa ini selesai bimbingan?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),

            const SizedBox(height: 20),

            // BUTTONS (KONSISTEN)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Kembali"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2E3A87),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _markStudentFinished();
                  },
                  child: const Text("Konfirmasi"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markStudentFinished() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lecturerId = prefs.getInt('lecturer_id');

      if (lecturerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lecturer ID tidak ditemukan")),
        );
        return;
      }

      final res = await http.post(
        Uri.parse("${Config.baseUrl}mark_student_finished.php"),
        body: {
          "student_id": widget.studentId,
          "lecturer_id": lecturerId.toString(),
        },
      );

      final data = jsonDecode(res.body);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['message'] ?? "Berhasil")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menandai mahasiswa")));
    }
  }

  // ================================================================
  // UI START
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: SafeArea(
        child: Column(
          children: [_header(), _studentInfo(), _tabs(), _tabView()],
        ),
      ),
    );
  }

  // HEADER
  Widget _header() => Container(
    width: double.infinity,
    color: Colors.white,
    padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xff2E3A87),
          ),
        ),
        const Text(
          "Mahasiswa",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff2E3A87),
          ),
        ),
      ],
    ),
  );

  // STUDENT INFO BOX
  Widget _studentInfo() => Container(
    width: double.infinity,
    color: const Color(0xff7EC9F5),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xff2E3A87)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nama,
                    style: const TextStyle(
                      color: Color(0xff2E3A87),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.nim,
                    style: const TextStyle(color: Color(0xff2E3A87)),
                  ),
                  Text(
                    widget.judul,
                    style: const TextStyle(color: Color(0xff2E3A87)),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 🔵 TOMBOL LIHAT KANBAN
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KanbanScreenDosen(
                      nama: widget.nama,
                      nim: widget.nim,
                      judulTugasAkhir: widget.judul,
                      studentId: int.parse(widget.studentId),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2E3A87),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                elevation: 0,
              ),
              child: const Text(
                "Lihat Kanban",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),

            const SizedBox(width: 10),

            ElevatedButton(
              onPressed: _confirmFinishStudent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                elevation: 0,
              ),
              child: const Text(
                "Tandai Selesai",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // TABS
  Widget _tabs() => Container(
    color: Colors.white,
    child: TabBar(
      controller: _tabController,
      labelColor: const Color(0xff2E3A87),
      unselectedLabelColor: Colors.grey,
      indicatorColor: const Color(0xff2E3A87),
      tabs: const [
        Tab(text: "Pending"),
        Tab(text: "Disetujui"),
        Tab(text: "Revisi"),
      ],
    ),
  );

  // TAB VIEW
  Widget _tabView() => Expanded(
    child: isLoading
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildDocumentList("Pending"),
              _buildDocumentList("Disetujui"),
              _buildDocumentList("Revisi"),
            ],
          ),
  );

  // DOCUMENT LIST BUILDER
  Widget _buildDocumentList(String status) {
    final docs = getDocumentsByStatus(status);

    if (docs.isEmpty) {
      return const Center(child: Text("Tidak ada dokumen"));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: docs.map((doc) => _documentCard(doc)).toList()),
    );
  }

  // DOCUMENT CARD
  Widget _documentCard(Map doc) {
    final docId = doc["id"].toString();
    final fileUrl = doc["attachment_url"];
    final status = doc["status"];

    return FutureBuilder(
      future: fetchLastFeedback(docId),
      builder: (context, snap) {
        final feedback = snap.data;

        return Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xff2E3A87),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // OPEN FILE
              GestureDetector(
                onTap: () async {
                  if (await canLaunchUrl(Uri.parse(fileUrl))) {
                    await launchUrl(
                      Uri.parse(fileUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        doc["attachment"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ================= FEEDBACK SELALU MUNCUL =================
              if (feedback != null) ...[
                const Text(
                  "Komentar:",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feedback["comment"] ?? "-",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 14),

                // FILE REVISI (kalau dosen upload)
                if (feedback["attachment_url"] != null &&
                    feedback["attachment_url"] != "")
                  GestureDetector(
                    onTap: () async {
                      if (await canLaunchUrl(
                        Uri.parse(feedback["attachment_url"]),
                      )) {
                        await launchUrl(
                          Uri.parse(feedback["attachment_url"]),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.insert_drive_file, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "File Revisi Dosen",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],

              // ================= PENDING ACTIONS =================
              if (status == "pending") _pendingActions(docId),
            ],
          ),
        );
      },
    );
  }

  // PENDING ACTIONS
  Widget _pendingActions(String docId) {
    final commentCtrl = TextEditingController();
    PlatformFile? pickedFile;

    return StatefulBuilder(
      builder: (context, setSB) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () async {
                pickedFile = await pickFile();
                setSB(() {});
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text(
                "Choose File",
                style: TextStyle(color: Colors.black),
              ),
            ),

            if (pickedFile != null)
              Text(
                "Dipilih: ${pickedFile!.name}",
                style: const TextStyle(color: Colors.white),
              ),

            const SizedBox(height: 12),

            TextField(
              controller: commentCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Berikan komentar",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    submitFeedback(
                      docId: docId,
                      comment: commentCtrl.text,
                      newStatus: "revision",
                      file: pickedFile,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF4C2C2),
                  ),
                  child: const Text("Revisi"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    submitFeedback(
                      docId: docId,
                      comment: commentCtrl.text,
                      newStatus: "approved",
                      file: pickedFile,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffC4F0B0),
                  ),
                  child: const Text("Setuju"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
