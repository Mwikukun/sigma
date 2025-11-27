import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'upload_file_popup.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  List documents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDocuments();
  }

  Future<void> getDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('student_number');

    if (studentId == null) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse("http://127.0.0.1/SIGMA/api/get_documents.php");

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
        title: const Text(
          "Document",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF2E3A87),
            ),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
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
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Feedback Dosen",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      ...feedbacks.map<Widget>((fb) {
                                        final lecturer =
                                            fb['lecturer_name'] ?? "Dosen";
                                        final comment = fb['comment'] ?? "-";
                                        final attachment =
                                            fb['attachment'] ?? "";
                                        final url = fb['attachment_url'];

                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.person,
                                                    color: Colors.blueGrey,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    lecturer,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),

                                              Text(
                                                comment,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),

                                              // FILE REVISI (OPEN DIRECT)
                                              if (attachment.isNotEmpty)
                                                GestureDetector(
                                                  onTap: () async {
                                                    final uri = Uri.parse(url);
                                                    if (await canLaunchUrl(
                                                      uri,
                                                    )) {
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
                                                        color: Colors.blue,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        attachment,
                                                        style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
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

      floatingActionButton: FloatingActionButton(
        onPressed: _openUploadPopup,
        backgroundColor: const Color(0xff2E3A87),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
