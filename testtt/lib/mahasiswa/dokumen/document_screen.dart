import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:testtt/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'upload_file_popup.dart';
import 'upload_final_thesis_popup.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  List documents = [];
  bool isLoading = true;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    getDocuments();
    checkGuidanceFinished();
  }

  Future<void> getDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('student_number');

    if (studentId == null) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse("${Config.baseUrl}get_documents.php");

    final res = await http.post(
      url,
      body: {"student_id": studentId.toString()},
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        setState(() {
          documents = body['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> checkGuidanceFinished() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('student_number');

    if (studentId == null) return;

    final res = await http.post(
      Uri.parse("${Config.baseUrl}get_guidance_status.php"),
      body: {"student_id": studentId.toString()},
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);

      if (body['success'] == true &&
          body['data'] != null &&
          body['data']['is_approved'] == 3) {
        setState(() => isFinished = true);
      }
    }
  }

  void _openUploadPopup() {
    showDialog(
      context: context,
      builder: (_) => const UploadFilePopup(),
    ).then((value) => getDocuments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF4F6F8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Document",
          style: TextStyle(
            color: Color(0xFF2E3A87),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Berkas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xff2E3A87),
              ),
            ),
            const SizedBox(height: 14),

            if (isFinished) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Final Tugas Akhir",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Dosen telah menandai bimbingan selesai.\nSilakan upload file final.",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const UploadFinalThesisPopup(),
                        ).then((_) => getDocuments());
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload Final File"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : documents.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff2E3A87),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Belum ada file yang diupload",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, i) {
                        final doc = documents[i];
                        final status = (doc['status'] ?? '')
                            .toString()
                            .toLowerCase();

                        Color statusColor = Colors.grey;
                        if (status == "pending") statusColor = Colors.orange;
                        if (status == "revision" || status == "revisi") {
                          statusColor = Colors.red;
                        }
                        if (status == "approved") statusColor = Colors.green;

                        final fileUrl = doc["attachment_url"];
                        final feedbacks = doc['feedbacks'] ?? [];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xff2E3A87),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ---------------- FILE CARD ----------------
                              GestureDetector(
                                onTap: () async {
                                  final url = Uri.parse(fileUrl);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.insert_drive_file_rounded,
                                        size: 34,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc['title'] ?? '-',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            doc['chapter'] ?? '-',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Text(
                                            doc['note'] ?? '-',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              // ------------ FEEDBACK SECTION --------------
                              if (feedbacks.isNotEmpty) ...[
                                const SizedBox(height: 14),

                                const Text(
                                  "Feedback dosen",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                ...feedbacks.map<Widget>((fb) {
                                  final lecturer =
                                      fb['lecturer_name'] ?? "Dosen";
                                  final comment = fb['comment'] ?? "-";
                                  final attachment = fb['attachment'] ?? "";
                                  final url = fb['attachment_url'];

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ===== ROW UTAMA =====
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // FOTO PROFIL (KIRI)
                                          const CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              Icons.person,
                                              size: 20,
                                              color: Color(0xff2E3A87),
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          // FIELD PUTIH (KANAN)
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // NAMA DOSEN
                                                  Text(
                                                    lecturer,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                      color: Colors.black,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 6),

                                                  // KOMENTAR
                                                  Text(
                                                    comment,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                      height: 1.4,
                                                    ),
                                                    softWrap: true,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // ===== FILE DOSEN (TANPA FIELD PUTIH) =====
                                      if (attachment.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 42,
                                          ),
                                          child: GestureDetector(
                                            onTap: () async {
                                              final uri = Uri.parse(url);
                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(
                                                  uri,
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .insert_drive_file_rounded,
                                                  color: Colors.lightBlueAccent,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    attachment,
                                                    style: const TextStyle(
                                                      color: Colors
                                                          .lightBlueAccent,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 12),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: isFinished
          ? null
          : FloatingActionButton(
              onPressed: _openUploadPopup,
              backgroundColor: const Color(0xff2E3A87),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}
