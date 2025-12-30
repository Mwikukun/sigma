import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testtt/config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ================= LOAD PROFILE =================
  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentNumber = prefs.getInt('student_number');

      if (studentNumber == null) {
        setState(() => isLoading = false);
        return;
      }

      final res = await http.post(
        Uri.parse("${Config.baseUrl}get_edit_student_profile.php"),
        body: {"student_number": studentNumber.toString()},
      );

      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        final d = data['data'];

        setState(() {
          _nameController.text = d['name'] ?? "";
          _nimController.text = d['student_number'].toString();
          _emailController.text = d['email'] ?? "";
          _phoneController.text = d['phone_number'] ?? "";
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    } catch (e) {
      debugPrint("ERROR LOAD PROFILE: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= UPDATE PROFILE =================
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final studentNumber = prefs.getInt('student_number');

    if (studentNumber == null) return;

    final res = await http.post(
      Uri.parse("${Config.baseUrl}update_student_profile.php"),
      body: {
        "student_number": studentNumber.toString(),
        "name": _nameController.text,
        "email": _emailController.text,
        "phone_number": _phoneController.text,
      },
    );

    final data = jsonDecode(res.body);

    if (data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? "Gagal update profil")),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF6ECFF6), // 🔵 WARNA POPUP
          borderRadius: BorderRadius.circular(20),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2E3A87),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField("Nama Lengkap", _nameController),
                    _buildTextField("NIM", _nimController, enabled: false),
                    _buildTextField("Email", _emailController),
                    _buildTextField("No. Telepon", _phoneController),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2E3A87),
                        ),
                        onPressed: _updateProfile,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xff2E3A87), // 🟣 LABEL
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFAAE7FF), // 🟦 FIELD
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? "Harap isi $label" : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
