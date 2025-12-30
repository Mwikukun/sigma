import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:testtt/config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadFilePopup extends StatefulWidget {
  const UploadFilePopup({super.key});

  @override
  State<UploadFilePopup> createState() => _UploadFilePopupState();
}

class _UploadFilePopupState extends State<UploadFilePopup> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _babController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  String? _fileName;
  String? _pickedFilePath;
  Uint8List? _pickedBytes;

  void _chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;

        if (kIsWeb) {
          _pickedBytes = result.files.single.bytes;
        } else {
          _pickedFilePath = result.files.single.path;
        }
      });
    }
  }

  Future<void> _upload() async {
    if (_fileName == null ||
        _judulController.text.isEmpty ||
        _babController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lengkapi semua field sebelum upload."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('student_number') ?? 1; // fallback

    final uri = Uri.parse("${Config.baseUrl}upload_document.php");

    var request = http.MultipartRequest("POST", uri);

    request.fields['student_id'] = studentId.toString();
    request.fields['title'] = _judulController.text;
    request.fields['chapter'] = _babController.text;
    request.fields['note'] = _catatanController.text;

    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _pickedBytes!,
          filename: _fileName,
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath('file', _pickedFilePath!),
      );
    }

    final response = await request.send();

    if (!mounted) return;

    if (response.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berkas berhasil diupload!"),
          backgroundColor: Color(0xff2E3A87),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Upload gagal."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 24 : 100,
      ),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff64C9EE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 80,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.black,
                ),
                const Text(
                  "Upload File Berkas",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "File",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _fileName ?? "Masukkan File",
                          style: TextStyle(
                            color: _fileName == null
                                ? Colors.black54
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _chooseFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2E3A87),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      child: const Text("Choose File"),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Nama Dokumen",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _judulController,
                  decoration: InputDecoration(
                    hintText: "Masukkan Judul Dokumen",
                    filled: true,
                    fillColor: Colors.lightBlue.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "BAB",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _babController,
                  decoration: InputDecoration(
                    hintText: "Masukkan Bab",
                    filled: true,
                    fillColor: Colors.lightBlue.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Catatan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _catatanController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Tambahkan catatan (opsional)",
                    filled: true,
                    fillColor: Colors.lightBlue.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _upload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2E3A87),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Upload",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
