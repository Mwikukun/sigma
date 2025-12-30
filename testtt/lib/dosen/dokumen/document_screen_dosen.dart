import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:testtt/config.dart';
import 'package:http/http.dart' as http;
import 'detail_document_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? lecturerId;
  bool isLoading = true;
  List mahasiswaApproved = [];

  @override
  void initState() {
    super.initState();
    _loadLecturerId();
  }

  Future<void> _loadLecturerId() async {
    final prefs = await SharedPreferences.getInstance();
    lecturerId = prefs.getInt('lecturer_id');

    if (lecturerId != null) {
      fetchApprovedStudents();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchApprovedStudents() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse("${Config.baseUrl}get_approved_guidances.php"),
      body: {"lecturer_id": lecturerId.toString()},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        mahasiswaApproved = jsonData['data'];
      }
    }

    setState(() => isLoading = false);
  }

  // =====================================================
  // STATUS BADGE
  // =====================================================
  Widget _statusBadge(String status) {
    Color bg;
    String text;

    switch (status) {
      case "approved":
        bg = Colors.green;
        text = "Approved";
        break;
      case "revision":
        bg = Colors.purple;
        text = "Revisi";
        break;
      default:
        bg = Colors.orange;
        text = "Pending";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = mahasiswaApproved.where((m) {
      final name = m["student_name"]?.toString().toLowerCase() ?? "";
      return name.contains(_searchController.text.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Document",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff2E3A87),
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _searchBar(),
                    const SizedBox(height: 20),
                    ..._buildList(filtered),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: "Cari mahasiswa...",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  List<Widget> _buildList(List filtered) {
    if (filtered.isEmpty) {
      return const [
        Text(
          "Belum ada mahasiswa yang disetujui.",
          style: TextStyle(color: Colors.black54),
        ),
      ];
    }

    return List.generate(filtered.length, (i) {
      final mhs = filtered[i];
      final nama = mhs["student_name"]?.toString() ?? "-";
      final nim = mhs["student_number"]?.toString() ?? "-";
      final thesis = mhs["thesis_title"]?.toString() ?? "-";
      final studentId = mhs["student_id"]?.toString() ?? "";
      final status = mhs["last_document_status"] ?? "pending";

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailDocumentScreen(
                studentId: studentId,
                nama: nama,
                nim: nim,
                judul: thesis,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xff2E3A87),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xffD9D9D9),
                child: Icon(Icons.person, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAMA
                    Text(
                      nama,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // NIM
                    Text(nim, style: const TextStyle(color: Colors.white70)),

                    // JUDUL
                    Text(
                      "Judul: $thesis",
                      style: const TextStyle(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // STATUS (DI BAWAH JUDUL)
                    _statusBadge(status),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      );
    });
  }
}
