import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testtt/config.dart';

class KanbanScreenDosen extends StatefulWidget {
  final String nama;
  final String nim;
  final String judulTugasAkhir;
  final int studentId;

  const KanbanScreenDosen({
    super.key,
    required this.nama,
    required this.nim,
    required this.judulTugasAkhir,
    required this.studentId,
  });

  @override
  State<KanbanScreenDosen> createState() => _KanbanScreenDosenState();
}

class _KanbanScreenDosenState extends State<KanbanScreenDosen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isLoading = true;
  bool loadingProgress = true;
  double progressTA = 0.0;

  List<dynamic> todo = [];
  List<dynamic> inProgress = [];
  List<dynamic> done = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchKanban();
    fetchProgressTA();
  }

  // ===================== FETCH KANBAN ======================
  Future<void> fetchKanban() async {
    try {
      final res = await http.post(
        Uri.parse("${Config.baseUrl}get_activities.php"),
        body: {"student_id": widget.studentId.toString()},
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        final list = data["data"];

        setState(() {
          todo = list.where((x) => x["section"] == "to-do").toList();
          inProgress = list
              .where((x) => x["section"] == "in-progress")
              .toList();
          done = list.where((x) => x["section"] == "done").toList();
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    } catch (_) {
      isLoading = false;
    }
  }

  // ===================== FETCH PROGRESS ======================
  Future<void> fetchProgressTA() async {
    try {
      final res = await http.post(
        Uri.parse("${Config.baseUrl}get_activities.php"),
        body: {"student_id": widget.studentId.toString()},
      );

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        List tasks = data["data"];
        double total = 0;

        for (var t in tasks) {
          total += double.tryParse(t["percentage"].toString()) ?? 0;
        }

        setState(() {
          progressTA = tasks.isEmpty ? 0 : (total / tasks.length) / 100;
          loadingProgress = false;
        });
      } else {
        loadingProgress = false;
      }
    } catch (_) {
      loadingProgress = false;
    }
  }

  // ===================== SET DUE DATE ======================
  void _showSetDueDialog(int taskId) {
    String? pickedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: const Color(0xFF6ECFF6),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ICON
                    const Icon(
                      Icons.calendar_month,
                      size: 48,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 8),

                    // TITLE
                    const Text(
                      "Set Due Date",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // DATE FIELD
                    GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2035),
                        );

                        if (d != null) {
                          setStateDialog(() {
                            pickedDate =
                                "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFAAE7FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                pickedDate ?? "yyyy/mm/dd",
                                style: TextStyle(
                                  color: pickedDate == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BUTTONS
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
                          onPressed: pickedDate == null
                              ? null
                              : () async {
                                  await http.post(
                                    Uri.parse(
                                      "${Config.baseUrl}set_due_date.php",
                                    ),
                                    body: {
                                      "task_id": taskId.toString(),
                                      "due_date": pickedDate!,
                                    },
                                  );

                                  setState(() {
                                    for (var list in [todo, inProgress, done]) {
                                      for (var t in list) {
                                        if (t["id"] == taskId) {
                                          t["due_date"] = pickedDate;
                                        }
                                      }
                                    }
                                  });

                                  Navigator.pop(context);
                                  fetchProgressTA();
                                },
                          child: const Text("Konfirmasi"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===================== BUILD ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),

      // ✅ TOMBOL KEMBALI FIX
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff2E3A87)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Kanban Mahasiswa",
          style: TextStyle(
            color: Color(0xff2E3A87),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildProgressTA(),
            const SizedBox(height: 24),

            const Text(
              "Papan Kanban",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xff2E3A87),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xffEAEAF4), // abu soft
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xff2E3A87),
                indicatorWeight: 3,
                labelColor: const Color(0xff2E3A87),
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                tabs: const [
                  Tab(text: "To-Do"),
                  Tab(text: "In-Progress"),
                  Tab(text: "Done"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 520,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(todo),
                  _buildTaskList(inProgress),
                  _buildTaskList(done),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== PROGRESS CARD ======================
  Widget _buildProgressTA() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Progress TA",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff2E3A87),
            ),
          ),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: loadingProgress ? 0 : progressTA,
              minHeight: 12,
              backgroundColor: const Color(0x80FF8A4C),
              color: const Color(0xFFFF8A4C),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            loadingProgress
                ? "Loading..."
                : "${(progressTA * 100).toStringAsFixed(0)}%",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff2E3A87),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== TASK LIST ======================
  Widget _buildTaskList(List list) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada aktivitas",
          style: TextStyle(color: Color(0xff2E3A87)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final task = list[index];
        final percent =
            (double.tryParse(task["percentage"].toString()) ?? 0) / 100;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
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
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                task["description"] ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Progress: ${task["percentage"] ?? 0}%",
                style: const TextStyle(color: Colors.white),
              ),
              if (task["start_date"] != null) ...[
                const SizedBox(height: 6),
                Text(
                  "Start: ${task["start_date"]}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              if (task["due_date"] != null) ...[
                const SizedBox(height: 6),
                Text(
                  "Due: ${task["due_date"]}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showSetDueDialog(task["id"]),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF6ECFF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Set Due"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===================== PROFILE CARD ======================
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff7EC9F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 38, color: Color(0xff2E3A87)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xff2E3A87),
                  ),
                ),
                Text(widget.nim),
                Text(widget.judulTugasAkhir),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
