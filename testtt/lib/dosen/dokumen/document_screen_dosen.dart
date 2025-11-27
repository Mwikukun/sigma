import 'dart:convert';
import 'package:flutter/material.dart';
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lecturerId = prefs.getInt('lecturer_id');
    if (lecturerId != null) {
      fetchApprovedStudents();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchApprovedStudents() async {
    setState(() => isLoading = true);

    var url = Uri.parse(
      "http://127.0.0.1/SIGMA/api/get_approved_guidances.php",
    );

    var response = await http.post(
      url,
      body: {"lecturer_id": lecturerId.toString()},
    );

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        setState(() {
          mahasiswaApproved = jsonData['data'];
        });
      } else {
        print("API Success = false → ${jsonData['message']}");
      }
    } else {
      print("Server Error: ${response.statusCode}");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = mahasiswaApproved.where((m) {
      final name = m["student_name"]?.toString().toLowerCase() ?? "";
      return name.contains(_searchController.text.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Document",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff2E3A87),
                      ),
                    ),
                    const SizedBox(height: 10),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  List<Widget> _buildList(List filtered) {
    if (filtered.isEmpty) {
      return [const Text("Belum ada mahasiswa yang disetujui.")];
    }

    return List.generate(filtered.length, (i) {
      final mhs = filtered[i];

      final nama = mhs["student_name"]?.toString() ?? "-";
      final nim = mhs["student_number"]?.toString() ?? "-";
      final thesis = mhs["thesis_title"]?.toString() ?? "-";
      final studentId = mhs["student_id"].toString();

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
                    Text(
                      nama,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(nim, style: const TextStyle(color: Colors.white70)),
                    Text(
                      "Judul: $thesis",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      );
    });
  }
}
