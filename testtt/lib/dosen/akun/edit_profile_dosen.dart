import 'package:flutter/material.dart';

class EditProfileDosen extends StatefulWidget {
  const EditProfileDosen({super.key});

  @override
  State<EditProfileDosen> createState() => _EditProfileDosenState();
}

class _EditProfileDosenState extends State<EditProfileDosen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController(
    text: "Nama Dosen",
  );
  final TextEditingController _nikController = TextEditingController(
    text: "1234567890",
  );
  final TextEditingController _programController = TextEditingController(
    text: "Program Studi",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "08123456789",
  );
  final TextEditingController _passwordController = TextEditingController(
    text: "",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff6CC8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xffA5DFFF),
              child: Icon(Icons.person, size: 70, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xff6CC8FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    const Divider(
                      color: Color(0xff2E3A87),
                      thickness: 2,
                      indent: 100,
                      endIndent: 100,
                    ),
                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                        color: Color(0xff2E3A87),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField("Nama Dosen", _nameController),
                    _buildTextField("NIK", _nikController),
                    _buildTextField("Program Studi", _programController),
                    _buildTextField("No. Telpon", _phoneController),
                    _buildTextField(
                      "Ubah Password",
                      _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2E3A87),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 40,
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profil dosen berhasil disimpan!"),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
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
      ),
    );
  }
}
