import 'package:flutter/material.dart';

class KanbanScreenDosen extends StatefulWidget {
  final String nama;
  final String nim;
  final String jurusan;
  final String judulTugasAkhir;

  const KanbanScreenDosen({
    super.key,
    this.nama = 'Steven Situmorang',
    this.nim = '3312301074',
    this.jurusan = 'D3 - Teknik Informatika',
    this.judulTugasAkhir = 'Membuat Aplikasi Fitness',
  });

  @override
  State<KanbanScreenDosen> createState() => _KanbanScreenDosenState();
}

class _KanbanScreenDosenState extends State<KanbanScreenDosen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔵 Header Title
              const Center(
                child: Text(
                  "Kanban",
                  style: TextStyle(
                    color: Color(0xff2E3A87),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 👤 Card Profil Mahasiswa + Tombol Kembali di BAWAH
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff7EC9F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris foto + biodata
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xff2E3A87),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xff2E3A87),
                                ),
                              ),
                              Text(
                                widget.nim,
                                style: const TextStyle(
                                  color: Color(0xff2E3A87),
                                ),
                              ),
                              Text(
                                widget.jurusan,
                                style: const TextStyle(
                                  color: Color(0xff2E3A87),
                                ),
                              ),
                              Text(
                                widget.judulTugasAkhir,
                                style: const TextStyle(
                                  color: Color(0xff2E3A87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 🔘 Tombol Kembali (bawah kiri)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2E3A87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Kembali",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🧩 Title Papan Kanban
              const Text(
                "Papan Kanban",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xff2E3A87),
                ),
              ),
              const SizedBox(height: 12),

              // 🟦 Tab Bar Kanban
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xff2E3A87),
                  indicator: BoxDecoration(
                    color: const Color(0xff2E3A87),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  tabs: const [
                    Tab(text: "To-Do"),
                    Tab(text: "In-Progress"),
                    Tab(text: "Done"),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 📋 Isi Kanban
              SizedBox(
                height: 450,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildKanbanList("To-Do"),
                    _buildKanbanList("In-Progress"),
                    _buildKanbanList("Done"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKanbanList(String kategori) {
    final List<Map<String, String>> tugas = [
      {
        "judul": "Bab IV",
        "deskripsi":
            "Revisi Bab IV - Metode dijabarkan + perbaikan struktur paragraf",
        "deadline": "2025-10-05",
      },
    ];

    return ListView.builder(
      itemCount: tugas.length,
      itemBuilder: (context, index) {
        final item = tugas[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xff2E3A87),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item["judul"]!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item["deskripsi"]!,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Due Date: ${item["deadline"]!}",
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
