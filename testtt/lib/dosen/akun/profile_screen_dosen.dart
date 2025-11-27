import 'package:flutter/material.dart';
import 'edit_profile_dosen.dart';
import 'logout_card_dosen.dart';

class ProfileScreenDosen extends StatefulWidget {
  const ProfileScreenDosen({super.key});

  @override
  State<ProfileScreenDosen> createState() => _ProfileScreenDosenState();
}

class _ProfileScreenDosenState extends State<ProfileScreenDosen> {
  bool isNotificationOn = true;

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: 20,
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xffDDE7F7),
              child: Icon(Icons.person, size: 70, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              "Nama Dosen",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text("NIK", style: TextStyle(color: Colors.black54)),
            const Text(
              "Study Program",
              style: TextStyle(color: Colors.black54),
            ),
            const Text("No. Telepon", style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 25),

            // 🔔 Notifikasi
            _menuTile(
              icon: Icons.notifications,
              title: "Notifikasi",
              trailing: _customSwitch(),
            ),

            // ⚙️ Manajemen Akun
            _menuButton(
              icon: Icons.settings,
              title: "Manajemen Akun",
              onTap: () => _navigateTo(context, const EditProfileDosen()),
            ),

            // 🚪 Logout
            _menuButton(
              icon: Icons.logout,
              title: "Logout",
              onTap: () => _navigateTo(context, const LogoutCard()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customSwitch() {
    return GestureDetector(
      onTap: () {
        setState(() => isNotificationOn = !isNotificationOn);
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
