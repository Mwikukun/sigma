import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testtt/config.dart';
import 'logout_card_dosen.dart';
import 'edit_profile_dosen.dart';

class ProfileScreenDosen extends StatefulWidget {
  const ProfileScreenDosen({super.key});

  @override
  State<ProfileScreenDosen> createState() => _ProfileScreenDosenState();
}

class _ProfileScreenDosenState extends State<ProfileScreenDosen> {
  Map<String, dynamic>? profile;
  bool isNotificationEnabled = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_fetchProfile(), _loadNotificationSetting()]);
    setState(() => isLoading = false);
  }

  // ================= PROFILE DOSEN =================
  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final lecturerId = prefs.getInt('lecturer_id');
    if (lecturerId == null) return;

    final res = await http.post(
      Uri.parse('${Config.baseUrl}get_profile_dosen.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"lecturer_id": lecturerId.toString()}),
    );

    final data = jsonDecode(res.body);
    if (data['success'] == true) {
      profile = data['data'];
    }
  }

  // ================= NOTIFICATION SETTING =================
  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final lecturerId = prefs.getInt('lecturer_id');
    if (lecturerId == null) return;

    final res = await http.post(
      Uri.parse('${Config.baseUrl}get_notification_setting.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"lecturer_id": lecturerId.toString()}),
    );

    final data = jsonDecode(res.body);
    isNotificationEnabled = data['is_enabled'] == 1;
  }

  Future<void> _updateNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final lecturerId = prefs.getInt('lecturer_id');
    if (lecturerId == null) return;

    await http.post(
      Uri.parse('${Config.baseUrl}update_notification_setting.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "lecturer_id": lecturerId.toString(),
        "is_enabled": value ? 1 : 0,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff2E3A87),
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // ================= AVATAR =================
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(Icons.person, size: 60, color: Colors.blue),
          ),

          const SizedBox(height: 12),

          Text(
            profile?['name'] ?? '-',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),
          Text(profile?['employee_number']?.toString() ?? '-'),
          Text(profile?['study_program']?.toString() ?? '-'),
          Text(profile?['expertise']?.toString() ?? '-'),
          Text(profile?['phone_number']?.toString() ?? '-'),

          const SizedBox(height: 24),

          // ================= NOTIFICATION TOGGLE =================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E3A87),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Notifikasi',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Switch(
                  value: isNotificationEnabled,
                  activeColor: Colors.lightBlueAccent,
                  onChanged: (value) {
                    setState(() => isNotificationEnabled = value);
                    _updateNotificationSetting(value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ================= MANAJEMEN AKUN =================
          _menuButton(
            icon: Icons.settings,
            title: 'Manajemen Akun',
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                    child: EditProfileDosen(),
                  );
                },
              );
            },
          ),

          const LogoutCard(),
        ],
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2E3A87),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
