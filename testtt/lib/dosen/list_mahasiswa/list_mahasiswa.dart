import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:testtt/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ListMahasiswaScreen extends StatefulWidget {
  const ListMahasiswaScreen({super.key});

  @override
  State<ListMahasiswaScreen> createState() => _ListMahasiswaScreenState();
}

class _ListMahasiswaScreenState extends State<ListMahasiswaScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? lecturerId;
  bool isLoading = true;
  List mahasiswaList = [];

  @override
  void initState() {
    super.initState();
    _loadLecturerId();
  }

  Future<void> _loadLecturerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lecturerId = prefs.getInt('lecturer_id');

    if (lecturerId != null) {
      fetchMahasiswa();
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID dosen tidak ditemukan.")),
      );
    }
  }

  Future<void> fetchMahasiswa() async {
    setState(() => isLoading = true);
    try {
      var url = Uri.parse('${Config.baseUrl}get_pending_guidances.php');
      var response = await http.post(
        url,
        body: {'lecturer_id': lecturerId.toString()},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            mahasiswaList = data['data'];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ fetchMahasiswa error: $e");
    }
  }

  Future<void> updateApproval(
    int guidanceId,
    int status,
    Map<String, dynamic> mhs,
  ) async {
    try {
      var url = Uri.parse('${Config.baseUrl}approve_guidances.php');
      var response = await http.post(
        url,
        body: {
          'guidance_id': guidanceId.toString(),
          'is_approved': status.toString(),
        },
      );

      var res = json.decode(response.body);

      if (res['success'] == true) {
        setState(() {
          mahasiswaList.removeWhere(
            (item) => item["guidance_id"] == guidanceId,
          );
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']),
          backgroundColor: status == 1 ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// 🔹 POPUP KONFIRMASI
  Future<void> _showConfirmDialog({
    required int status,
    required Map<String, dynamic> mhs,
  }) async {
    String actionText = status == 1
        ? "menyetujui mahasiswa ini sebagai bimbingan Anda?"
        : "menolak mahasiswa ini?";

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff8fd3fe),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, size: 50, color: Colors.black87),
            const SizedBox(height: 10),
            const Text(
              "Konfirmasi Pilihan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Apakah Anda ingin $actionText",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 20),
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
                  onPressed: () {
                    Navigator.pop(context);
                    updateApproval(mhs["guidance_id"], status, mhs);
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

  @override
  Widget build(BuildContext context) {
    final filtered = mahasiswaList
        .where(
          (mhs) => mhs["student_name"].toString().toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Student List",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff2E3A87),
            fontSize: 22,
          ),
        ),
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(backgroundColor: Colors.white),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _searchBar(),
                    const SizedBox(height: 20),
                    ..._buildStudentList(filtered),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          hintText: "Cari Mahasiswa...",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  List<Widget> _buildStudentList(List filtered) {
    if (filtered.isEmpty) {
      return const [
        Center(
          child: Text(
            "Belum ada pengajuan mahasiswa.",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ];
    }

    return List.generate(filtered.length, (index) {
      final mhs = filtered[index];

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff2E3A87),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== DATA MAHASISWA (SATU BARIS UTAMA) =====
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xffD9D9D9),
                  child: Icon(Icons.person, color: Color(0xff2E3A87), size: 40),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mhs["student_name"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        "${mhs["student_number"]?.toString() ?? ""} ",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${mhs["thesis_title"]?.toString() ?? ""}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      // === TOMBOL PERSIS DI BAWAH NAMA ===
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            iconSize: 30,
                            onPressed: () =>
                                _showConfirmDialog(status: 1, mhs: mhs),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            iconSize: 30,
                            onPressed: () =>
                                _showConfirmDialog(status: 2, mhs: mhs),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  String _statusText(int status) {
    if (status == 0) return "Menunggu Persetujuan";
    if (status == 1) return "Disetujui";
    if (status == 2) return "Ditolak";
    return "Tidak Diketahui";
  }
}
