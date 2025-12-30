import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'forgot_password.dart';

// Mahasiswa
import 'mahasiswa/supervisor/request_supervisor_screen.dart';
import 'mahasiswa/supervisor/request_supervisor_pending.dart';
import 'mahasiswa/dashboard_mahasiswa_screen.dart';
import 'mahasiswa/jadwal/counselling_schedule_screen.dart';
import 'mahasiswa/dokumen/document_screen.dart';
import 'mahasiswa/kanban/kanban_screen.dart';
import 'mahasiswa/akun/profile_screen.dart';
import 'mahasiswa/notification/notification_page.dart';

// Dosen
import 'dosen/dashboard_dosen_screen.dart';
import 'dosen/jadwal/main_counselling.dart';
import 'dosen/list_mahasiswa/list_mahasiswa.dart';
import 'dosen/dokumen/document_screen_dosen.dart';
import 'dosen/notification/notification_page_dosen.dart';
// import 'dosen/dokumen/detail_document_screen.dart';
// import 'dosen/dokumen/kanban_screen_dosen.dart';
import 'dosen/akun/edit_profile_dosen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIGMA - Polibatam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 🎨 Warna utama aplikasi
        primaryColor: const Color(0xFF2E3A87),
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),

        // 🧩 Font global: Poppins
        fontFamily: 'Poppins',

        // 🔹 Gaya teks global
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Poppins'),
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
          titleLarge: TextStyle(fontFamily: 'Poppins'),
          titleMedium: TextStyle(fontFamily: 'Poppins'),
        ),

        // ✏️ Gaya Input (TextField)
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),

        // 🔘 Gaya Tombol
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E3A87),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),

      // ⏩ Halaman pertama saat aplikasi dijalankan
      initialRoute: '/',

      // 📄 Daftar semua halaman
      routes: {
        '/': (context) => const LoginPage(),
        '/forgot': (context) => const ForgotPasswordPage(),
        '/supervisor': (context) => const RequestSupervisorPage(),
        '/supervisor_pending': (context) =>
            const PendingSupervisorPage(selectedSupervisor: ''),
        '/dashboard': (context) => const DashboardMahasiswaScreen(),
        '/counselling_schedule': (context) => const CounsellingScheduleScreen(),
        '/document_screen': (context) => const DocumentPage(),
        '/kanban_screen': (context) => const KanbanScreen(),
        '/profile_screen': (context) => const ProfileScreen(),
        '/notification': (context) => const NotificationPage(),

        // Semua Halaman Dosen
        '/dashboard_dosen': (context) => const DashboardDosenScreen(),
        '/main_counselling': (context) => const MainCounsellingPage(),
        '/list_mahasiswa': (context) => const ListMahasiswaScreen(),
        '/document_screen_dosen': (context) => const DocumentScreen(),
        '/notification_dosen': (context) => const NotificationPageDosen(),
        // '/detail_document_screen': (context) => const DetailDocumentScreen(),
        // '/kanban_screen_dosen': (context) => const KanbanScreenDosen(),
        '/login': (context) => const LoginPage(),
        '/edit-profile-dosen': (context) => const EditProfileDosen(),
      },
    );
  }
}
