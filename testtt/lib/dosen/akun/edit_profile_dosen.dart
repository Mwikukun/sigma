import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:testtt/config.dart';

class EditProfileDosen extends StatefulWidget {
  const EditProfileDosen({super.key});

  @override
  State<EditProfileDosen> createState() => _EditProfileDosenState();
}

class _EditProfileDosenState extends State<EditProfileDosen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _programController = TextEditingController();
  final _expertiseController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final lecturerId = prefs.getInt('lecturer_id');

    final res = await http.post(
      Uri.parse('${Config.baseUrl}get_profile_dosen.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"lecturer_id": lecturerId.toString()}),
    );

    final data = jsonDecode(res.body);
    if (data['success'] == true) {
      final p = data['data'];
      _nameController.text = p['name'] ?? '';
      _nikController.text = p['employee_number'].toString();
      _programController.text = p['study_program'] ?? '';
      _expertiseController.text = p['expertise'] ?? '';
      _phoneController.text = p['phone_number'] ?? '';
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final lecturerId = prefs.getInt('lecturer_id');

    final body = {
      "lecturer_id": lecturerId.toString(),
      "name": _nameController.text,
      "phone_number": _phoneController.text,
      "expertise": _expertiseController.text,
    };

    // ✅ HANYA kirim password kalau diisi
    if (_passwordController.text.isNotEmpty) {
      body["password"] = _passwordController.text;
    }

    final res = await http.post(
      Uri.parse('${Config.baseUrl}update_profile_dosen.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);

    if (data['success'] == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui")),
      );
      Navigator.pop(context); // tutup popup
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7ED3F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _field("Nama", _nameController),
              _field("NIK", _nikController, readOnly: true),
              _field("Program Studi", _programController, readOnly: true),
              _field("Bidang Keahlian", _expertiseController),
              _field("No. Telpon", _phoneController),
              _field("Password Baru", _passwordController, obscure: true),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3A87),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveProfile();
                    }
                  },
                  child: const Text("Simpan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    bool obscure = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          obscureText: obscure,
          readOnly: readOnly,
          validator: (v) {
            if (label == "Password Baru") return null;
            return v == null || v.isEmpty ? '$label wajib diisi' : null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFAAE7FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
