import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(
    text: "Nama Mahasiswa",
  );
  final TextEditingController _nimController = TextEditingController(
    text: "123456789",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "mahasiswa@example.com",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "08123456789",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xff2E3A87),
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xffBFD8FF),
                      child: Icon(Icons.person, size: 70, color: Colors.grey),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xff2E3A87),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Form Fields
              _buildTextField("Nama Lengkap", _nameController),
              _buildTextField("NIM", _nimController),
              _buildTextField("Email", _emailController),
              _buildTextField("No. Telepon", _phoneController),

              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2E3A87),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profil berhasil diperbarui!"),
                        backgroundColor: Color(0xff2E3A87),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Simpan",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Harap isi $label" : null,
      ),
    );
  }
}
