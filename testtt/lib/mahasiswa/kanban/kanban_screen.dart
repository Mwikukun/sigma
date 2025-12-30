import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _tasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchTasks();
  }

  // ================= SECTION AUTO =================
  String _sectionFromProgress(String percent) {
    final p = int.tryParse(percent) ?? 0;
    if (p >= 100) return "done";
    if (p > 0) return "in-progress";
    return "to-do";
  }

  // ================= FETCH =================
  Future<void> _fetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('student_number') ?? 0;

    final res = await http.post(
      Uri.parse("${Config.baseUrl}get_activities.php"),
      body: {"student_id": studentId.toString()},
    );

    final data = jsonDecode(res.body);
    if (data["success"] == true) {
      setState(() => _tasks = data["data"]);
    }
  }

  // ================= ADD TASK =================
  Future<void> _addTask(
    String title,
    String desc,
    String startDate,
    String percentage,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('student_number') ?? 0;

    final section = _sectionFromProgress(percentage);

    await http.post(
      Uri.parse("${Config.baseUrl}add_activity.php"),
      body: {
        "student_id": studentId.toString(),
        "title": title,
        "description": desc,
        "start_date": startDate,
        "percentage": percentage,
        "section": section,
      },
    );
  }

  // ================= ADD POPUP =================
  void _showAddTaskDialog() {
    String title = "";
    String desc = "";
    String percentage = "0";
    String startDate = "";

    final startDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent, // ✅ PENTING
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF6ECFF6), // ✅ WARNA POPUP
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Tambah Aktivitas",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2E3A87),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const Text("Judul"),
              TextField(
                onChanged: (v) => title = v,
                decoration: _inputDecoration(hint: "Judul aktivitas"),
              ),

              const SizedBox(height: 10),
              const Text("Keterangan"),
              TextField(
                onChanged: (v) => desc = v,
                decoration: _inputDecoration(hint: "Keterangan"),
              ),

              const SizedBox(height: 10),
              const Text("Start Date"),
              TextField(
                controller: startDateController,
                readOnly: true,
                decoration: _inputDecoration(hint: "Pilih tanggal"),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    startDate =
                        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    startDateController.text = startDate;
                  }
                },
              ),

              const SizedBox(height: 10),
              const Text("Progress (%)"),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (v) => percentage = v,
                decoration: _inputDecoration(hint: "0 - 100"),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2E3A87),
                  ),
                  onPressed: () async {
                    if (startDate.isEmpty) {
                      final now = DateTime.now();
                      startDate =
                          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                    }

                    await _addTask(title, desc, startDate, percentage);
                    Navigator.pop(context);
                    _fetchTasks();
                  },
                  child: const Text(
                    "Simpan",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= EDIT POPUP =================
  void _showEditTaskDialog(Map task) {
    final titleController = TextEditingController(text: task["title"] ?? "");

    final descController = TextEditingController(
      text: task["description"] ?? "",
    );
    final percentController = TextEditingController(
      text: task["percentage"].toString(),
    );

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent, // ✅
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF6ECFF6), // ✅ POPUP
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Progress",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2E3A87),
                ),
              ),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Judul",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),

              TextField(
                controller: titleController,
                readOnly: true, // 🔒 biar ga bisa diedit
                decoration: _inputDecoration(hint: "Judul aktivitas"),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: descController,
                decoration: _inputDecoration(hint: "Keterangan"),
              ),

              const SizedBox(height: 10),
              TextField(
                controller: percentController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(hint: "Progress (%)"),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2E3A87),
                  ),
                  onPressed: () async {
                    final section = _sectionFromProgress(
                      percentController.text,
                    );

                    await http.post(
                      Uri.parse("${Config.baseUrl}update_activity.php"),
                      body: {
                        "id": task["id"].toString(),
                        "description": descController.text,
                        "percentage": percentController.text,
                        "section": section,
                      },
                    );

                    Navigator.pop(context);
                    _fetchTasks();
                  },
                  child: const Text(
                    "Update",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Kanban",
          style: TextStyle(
            color: Color(0xff2E3A87),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xff2E3A87),
              labelColor: const Color(0xff2E3A87),
              unselectedLabelColor: Colors.grey,
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
                _buildTaskList("to-do"),
                _buildTaskList("in-progress"),
                _buildTaskList("done"),
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

  // ================= CARD =================
  Widget _buildTaskList(String section) {
    final filtered = _tasks.where((t) => t["section"] == section).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("Belum ada tugas"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final task = filtered[i];
        final percent =
            (double.tryParse(task["percentage"].toString()) ?? 0) / 100;

        return InkWell(
          onTap: () => _showEditTaskDialog(task),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xff2E3A87),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task["title"] ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task["description"] ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.orangeAccent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Progress: ${task["percentage"]}%",
                  style: const TextStyle(color: Colors.white),
                ),
                if (task["start_date"] != null)
                  Text(
                    "Start: ${task["start_date"]}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFAAE7FF), // 🟦 FIELD
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );
}
