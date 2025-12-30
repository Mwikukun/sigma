import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config.dart';

class NotificationPageDosen extends StatefulWidget {
  const NotificationPageDosen({super.key});

  @override
  State<NotificationPageDosen> createState() => _NotificationPageDosenState();
}

class _NotificationPageDosenState extends State<NotificationPageDosen> {
  List notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 🔵 Ambil lecturer_id dari SharedPreferences
      final lecturerId = prefs.getInt('lecturer_id') ?? 0;

      if (lecturerId == 0) {
        setState(() => loading = false);
        return;
      }

      final response = await http.post(
        Uri.parse("${Config.baseUrl}get_notifications_dosen.php"),
        body: {"lecturer_id": lecturerId.toString()},
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          notifications = data["data"];
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: Color(0xFF2E3A87),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2E3A87)),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E3A87)),
            )
          : notifications.isEmpty
          ? const Center(
              child: Text(
                "Tidak ada notifikasi",
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _notificationCard(
                  item["title"] ?? "-",
                  item["description"] ?? "",
                );
              },
            ),
    );
  }

  Widget _notificationCard(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notifications, color: Color(0xFF2E3A87), size: 30),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
