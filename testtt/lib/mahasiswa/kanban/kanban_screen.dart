import 'package:flutter/material.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> _tasks = [
    {
      "section": "To-Do",
      "title": "Bab IV",
      "desc": "Metode dilaporkan + perbaikan struktur proposal",
      "due": "2025-08-25",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _showAddTaskDialog() {
    String section = "To-Do";
    String bab = "";
    String desc = "";
    String due = "";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xffA8E6FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                    child: Text(
                      "Tambah Papan Kanban",
                      style: TextStyle(
                        color: Color(0xff2E3A87),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Section",
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: section,
                    items: const [
                      DropdownMenuItem(value: "To-Do", child: Text("To-Do")),
                      DropdownMenuItem(
                        value: "In-Progress",
                        child: Text("In-Progress"),
                      ),
                      DropdownMenuItem(value: "Done", child: Text("Done")),
                    ],
                    onChanged: (v) => section = v!,
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 10),
                  const Text("Bab", style: TextStyle(color: Colors.black87)),
                  TextField(
                    onChanged: (v) => bab = v,
                    decoration: _inputDecoration(hint: "Masukan Judul Dokumen"),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Keterangan",
                    style: TextStyle(color: Colors.black87),
                  ),
                  TextField(
                    onChanged: (v) => desc = v,
                    decoration: _inputDecoration(hint: "Masukan Keterangan"),
                  ),
                  const SizedBox(height: 10),
                  const Text("Due", style: TextStyle(color: Colors.black87)),
                  TextField(
                    onChanged: (v) => due = v,
                    decoration: _inputDecoration(hint: "Masukan Tanggal Waktu"),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2E3A87),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _tasks.add({
                            "section": section,
                            "title": bab,
                            "desc": desc,
                            "due": due,
                          });
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Simpan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        automaticallyImplyLeading: false, // biar icon back ilang
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Kanban",
          style: TextStyle(
            color: Color(0xff2E3A87),
            fontWeight: FontWeight.w800,
          ),
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
      ),
      body: Column(
        children: [
          // 🧩 Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              indicator: BoxDecoration(
                color: const Color(0xff2E3A87),
                borderRadius: BorderRadius.circular(8),
              ),
              tabs: const [
                Tab(text: "To-Do"),
                Tab(text: "In-Progress"),
                Tab(text: "Done"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList("To-Do"),
                _buildTaskList("In-Progress"),
                _buildTaskList("Done"),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff2E3A87),
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskList(String section) {
    final filtered = _tasks.where((t) => t["section"] == section).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("Belum ada tugas di sini"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final task = filtered[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xff2E3A87),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task["title"] ?? "",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                task["desc"] ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(
                "Due: ${task["due"] ?? "-"}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
