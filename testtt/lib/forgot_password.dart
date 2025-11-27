import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _sendForgotPassword() async {
    final email = _emailController.text.trim();
    final newPassword = _passwordController.text.trim();

    try {
      var url = Uri.parse("http://127.0.0.1/SIGMA/api/forgot_password.php");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email, "new_password": newPassword}),
      );

      var data = json.decode(response.body);

      if (data['success'] == true) {
        _showPopup(
          context,
          icon: Icons.check_circle_outline,
          title: "Berhasil",
          message: "Password berhasil diubah. Silakan login kembali.",
          goToLogin: true,
        );
      } else {
        _showPopup(
          context,
          icon: Icons.error_outline,
          title: "Gagal",
          message: data['message'] ?? "Terjadi kesalahan.",
          goToLogin: false,
        );
      }
    } catch (e) {
      _showPopup(
        context,
        icon: Icons.error_outline,
        title: "Kesalahan",
        message: "Gagal menghubungi server. Pastikan koneksi aktif.",
        goToLogin: false,
      );
    }
  }

  void _showPopup(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required bool goToLogin,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 70, color: const Color(0xFF2E3A87)),
                const SizedBox(height: 15),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (goToLogin) {
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E3A87),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Oke',
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
      },
    );
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
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo_polibatam.png',
                          width: 120,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'SIGMA',
                          style: TextStyle(
                            color: const Color(0xFF2E3A87),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 25,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6F8),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              'Lupa Password?',
                              style: TextStyle(
                                color: const Color(0xFF2E3A87),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Masukkan email dan password baru Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 📨 Email Field (fixed)
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined),
                              hintText: 'Email',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email wajib diisi';
                              }
                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(value)) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // 🔒 Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              hintText: 'Password Baru',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password baru wajib diisi';
                              }
                              // ✅ Regex diperbaiki: minimal 8 karakter
                              final regex = RegExp(
                                r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$',
                              );
                              if (!regex.hasMatch(value)) {
                                return 'Password harus minimal 8 karakter, huruf besar & angka';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // 🔒 Konfirmasi Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_reset_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              hintText: 'Konfirmasi Password Baru',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi password wajib diisi';
                              }
                              if (value != _passwordController.text) {
                                return 'Password tidak sama';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _sendForgotPassword();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E3A87),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Kirim',
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
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Kembali ke login',
                      style: TextStyle(
                        color: Color(0xFF2E3A87),
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
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
}
