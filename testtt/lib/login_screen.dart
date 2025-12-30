import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:testtt/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testtt/mahasiswa/supervisor/request_supervisor_pending.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      final url = Uri.parse('${Config.baseUrl}login.php');

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"username": username, "password": password}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          debugPrint("Login Response: ${response.body}");

          if (data['success'] == true) {
            final userType = data['user_type'];
            final userName = data['name'] ?? 'Pengguna';
            final prefs = await SharedPreferences.getInstance();

            await prefs.setString('user_type', userType);
            await prefs.setString('user_name', userName);

            if (userType == 'student') {
              final studentNumber = data['student_number'];
              await prefs.setInt('student_number', studentNumber);
              await _checkGuidanceStatus(context, studentNumber);
              return;
            } else if (userType == 'lecturer') {
              final lecturerId =
                  data['lecturer_id']; // employee_number dari API

              if (lecturerId != null) {
                await prefs.setInt('lecturer_id', lecturerId);
                debugPrint(
                  "🎉 lecturer_id (employee_number) disimpan = $lecturerId",
                );
              } else {
                debugPrint("⚠️ employee_number (lecturer_id) tidak ditemukan");
              }

              Navigator.pushReplacementNamed(context, '/dashboard_dosen');
            } else if (userType == 'admin') {
              Navigator.pushReplacementNamed(context, '/dashboard_admin');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Role pengguna tidak dikenali'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Login gagal'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal terhubung ke server'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkGuidanceStatus(BuildContext context, int studentId) async {
    try {
      final res = await http.post(
        Uri.parse("${Config.baseUrl}get_guidance_status.php"),
        body: {"student_id": studentId.toString()},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        debugPrint("Guidance Check: ${res.body}");

        if (data["success"] == true) {
          final info = data["data"];

          if (info == null) {
            Navigator.pushReplacementNamed(context, '/supervisor');
          } else {
            final status = info["is_approved"];
            final lecturerName = info["lecturer_name"] ?? "-";

            if (status == "0" || status == 0) {
              // pending supervisor
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PendingSupervisorPage(selectedSupervisor: lecturerName),
                ),
              );
            } else if (status == "1" || status == 1) {
              // bimbingan aktif
              Navigator.pushReplacementNamed(context, '/dashboard');
            } else if (status == "3" || status == 3) {
              // ✅ BIMBINGAN SELESAI
              Navigator.pushReplacementNamed(context, '/dashboard');
            } else {
              // reject / unknown
              Navigator.pushReplacementNamed(context, '/supervisor');
            }
          }
        } else {
          Navigator.pushReplacementNamed(context, '/supervisor');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/supervisor');
      }
    } catch (e) {
      debugPrint("❌ checkGuidanceStatus error: $e");
      Navigator.pushReplacementNamed(context, '/supervisor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_polibatam.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: const Color.fromARGB(45, 110, 208, 246)),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Image.asset('assets/images/logo_polibatam.png', width: 120),
                  const SizedBox(height: 12),
                  const Text(
                    'SIGMA',
                    style: TextStyle(
                      color: Color(0xFF2E3A87),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sistem Informasi Guidance\nfor Mahasiswa Akhir',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 50),
                  _buildLoginForm(),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/forgot');
                    },
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(
                        color: Color(0xFF2E3A87),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline),
                hintText: 'NIM / NIK',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'NIM / NIK wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                hintText: 'Password',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Password wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E3A87),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Log in',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
