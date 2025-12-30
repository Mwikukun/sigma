import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testtt/config.dart';

import 'edit_profile_screen.dart';
import 'supervisor_information_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isNotificationOn = true;

  String name = "-";
  String nim = "-";
  String email = "-";
  String phone = "-";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadNotificationSetting();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentNumber = prefs.getInt('student_number');

      if (studentNumber == null) {
        debugPrint("❌ student_number tidak ditemukan");
        setState(() => isLoading = false);
        return;
      }

      final res = await http.post(
        Uri.parse("${Config.baseUrl}get_profile_student.php"),
        body: {"student_number": studentNumber.toString()},
      );

      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        setState(() {
          name = data['data']['name'];
          nim = data['data']['student_number'].toString();
          email = data['data']['email'] ?? "-";
          phone = data['data']['phone'] ?? "-";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Load profile error: $e");
      setState(() => isLoading = false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(
            color: Color(0xff2E3A87),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xff2E3A87)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2E3A87),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final studentNumber = prefs.getInt('student_number');

    if (studentNumber == null) return;

    final res = await http.post(
      Uri.parse("${Config.baseUrl}get_notification_setting_student.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"student_id": studentNumber}),
    );

    final data = jsonDecode(res.body);

    if (data['success'] == true) {
      setState(() {
        isNotificationOn = data['is_enabled'] == 1;
      });
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "PROFILE",
          style: TextStyle(
            color: Color(0xff2E3A87),
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: 20,
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xffBFD8FF),
                    child: Icon(Icons.person, size: 70, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(nim, style: const TextStyle(color: Colors.black54)),
                  Text(email, style: const TextStyle(color: Colors.black54)),
                  Text(phone, style: const TextStyle(color: Colors.black54)),

                  const SizedBox(height: 25),

                  _menuTile(
                    icon: Icons.notifications,
                    title: "Notifikasi",
                    trailing: _customSwitch(),
                  ),

                  _menuButton(
                    icon: Icons.person_search,
                    title: "Informasi Dosen Pembimbing",
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => const SupervisorInformationScreen(),
                      );
                    },
                  ),

                  _menuButton(
                    icon: Icons.settings,
                    title: "Manajemen Akun",
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => const EditProfileScreen(),
                      );
                    },
                  ),

                  _menuButton(
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
    );
  }

  // ================= WIDGET BAWAH TETAP =================

  Widget _customSwitch() {
    return GestureDetector(
      onTap: () async {
        setState(() => isNotificationOn = !isNotificationOn);

        final prefs = await SharedPreferences.getInstance();
        final studentNumber = prefs.getInt('student_number');

        if (studentNumber == null) return;

        await http.post(
          Uri.parse("${Config.baseUrl}update_notification_setting_student.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "student_id": studentNumber,
            "is_enabled": isNotificationOn ? 1 : 0,
          }),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          color: isNotificationOn
              ? const Color(0xff6CC8FF)
              : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isNotificationOn
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xff2E3A87),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white)),
            ],
          ),
          trailing ?? const SizedBox(),
        ],
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _menuTile(icon: icon, title: title),
    );
  }
}
