import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testtt/config.dart';
import 'package:flutter/foundation.dart';

class UploadFinalThesisPopup extends StatefulWidget {
  const UploadFinalThesisPopup({super.key});

  @override
  State<UploadFinalThesisPopup> createState() => _UploadFinalThesisPopupState();
}

class _UploadFinalThesisPopupState extends State<UploadFinalThesisPopup> {
  File? _file;
  Uint8List? _fileBytes;
  String? _fileName;
  bool _loading = false;

  final TextEditingController _titleController = TextEditingController();

  // ================= PICK FILE =================
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: kIsWeb);

    if (result != null) {
      final file = result.files.single;

      setState(() {
        _fileName = file.name;
        if (kIsWeb) {
          _fileBytes = file.bytes;
        } else {
          _file = File(file.path!);
        }
      });
    }
  }

  // ================= UPLOAD FINAL =================
  Future<void> _uploadFinal() async {
    if (_titleController.text.isEmpty ||
        (kIsWeb && _fileBytes == null) ||
        (!kIsWeb && _file == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File & nama dokumen wajib diisi")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getInt('student_number');

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("${Config.baseUrl}upload_document.php"),
      );

      request.fields['student_id'] = studentId.toString();
      request.fields['is_final'] = "true";
      request.fields['title'] = _titleController.text;

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _fileBytes!,
            filename: _fileName,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', _file!.path),
        );
      }

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);

      if (data['success'] == true) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Final thesis berhasil diupload")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Upload gagal")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF6ECFF6), // warna popup
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TITLE =====
            const Text(
              "Upload Final Tugas Akhir",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 16),

            // ===== FILE PICKER =====
            const Text("File", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),

            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFAAE7FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _fileName ?? "Masukan file",
                        style: TextStyle(
                          color: _fileName == null
                              ? Colors.black54
                              : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Choose File",
                      style: TextStyle(
                        color: Color(0xFF2E3A87),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ===== TITLE INPUT =====
            const Text(
              "Nama Dokumen",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),

            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Masukan judul dokumen",
                filled: true,
                fillColor: const Color(0xFFAAE7FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== UPLOAD BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E3A87),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _loading ? null : _uploadFinal,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Upload",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
