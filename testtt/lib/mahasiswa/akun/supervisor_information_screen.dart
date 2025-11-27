import 'package:flutter/material.dart';

class SupervisorInformationScreen extends StatelessWidget {
  const SupervisorInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xff2E3A87),
        title: const Text(
          "Informasi Dosen Pembimbing",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xffBFD8FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person_2_rounded,
                      size: 50,
                      color: Color(0xff2E3A87),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Dr. Ir. Andi Rahman, M.T.",
                          style: TextStyle(
                            color: Color(0xff2E3A87),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "NIP: 19781231 200501 1 001",
                          style: TextStyle(color: Colors.black54),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Bidang: Sistem Informasi & Database",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Kontak Dosen
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Kontak Dosen",
                    style: TextStyle(
                      color: Color(0xff2E3A87),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.email, color: Color(0xff2E3A87)),
                      SizedBox(width: 10),
                      Text("andi.rahman@univ.ac.id"),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Color(0xff2E3A87)),
                      SizedBox(width: 10),
                      Text("+62 812-3456-7890"),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xff2E3A87)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Ruang Dosen Fakultas Teknologi Informasi, Lantai 3",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
