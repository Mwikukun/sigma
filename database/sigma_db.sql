-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 30 Des 2025 pada 19.47
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sigma_db`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `activities`
--

CREATE TABLE `activities` (
  `id` int(11) NOT NULL,
  `student_id` bigint(20) DEFAULT NULL,
  `section` enum('to-do','in-progress','done') DEFAULT 'to-do',
  `title` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `start_date` date NOT NULL,
  `due_date` date DEFAULT NULL,
  `percentage` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `activities`
--

INSERT INTO `activities` (`id`, `student_id`, `section`, `title`, `description`, `start_date`, `due_date`, `percentage`) VALUES
(14, 4342411024, 'in-progress', 'Bab1', 'Ya begini la', '0000-00-00', '2025-12-20', 50),
(15, 4342411024, 'to-do', 'Bab 2', 'YAA', '0000-00-00', '2025-12-27', 0),
(16, 4342411024, 'to-do', 'Bab 3', 'WUUUU', '0000-00-00', '2025-12-31', 0),
(17, 4342411024, 'to-do', 'Bab 4', 'TTT', '0000-00-00', '2026-01-10', 0),
(18, 4342411024, 'to-do', 'Bab 5', 'aaa', '0000-00-00', '2026-01-17', 0),
(19, 4342411024, 'to-do', 'Bab 6', 'wwwwwwwwwww', '0000-00-00', '2026-01-31', 0),
(20, 4342411024, 'to-do', 'Bab 7', 'hhhh', '0000-00-00', '2026-02-20', 0),
(21, 4342411024, 'to-do', 'Bab 8', 'WWWWADAFSADA', '0000-00-00', '2026-02-28', 0);

-- --------------------------------------------------------

--
-- Struktur dari tabel `activity_logs`
--

CREATE TABLE `activity_logs` (
  `id` int(11) NOT NULL,
  `lecturer_id` bigint(20) DEFAULT NULL,
  `student_id` bigint(20) DEFAULT NULL,
  `activity_type` varchar(50) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `activity_logs`
--

INSERT INTO `activity_logs` (`id`, `lecturer_id`, `student_id`, `activity_type`, `description`, `created_at`) VALUES
(1, 221345, 4342411030, 'final_thesis', 'keysya arghinaya mengupload FINAL Tugas Akhir', '2025-12-21 14:08:18'),
(2, 221345, 4342411010, 'guidance_request', 'ABI mengajukan bimbingan dengan judul: test', '2025-12-21 19:34:48'),
(3, 221345, 4342411024, 'schedule_request', 'Nauval mengajukan jadwal bimbingan.', '2025-12-21 20:35:08'),
(4, 221345, 4342411010, 'guidance_request', 'ABI mengajukan bimbingan dengan judul: wee', '2025-12-27 13:48:28'),
(5, 221345, 4342411010, 'guidance_request', 'ABI mengajukan bimbingan dengan judul: Dota 13', '2025-12-28 16:10:49'),
(6, 221345, 4342411010, 'guidance_request', 'ABI mengajukan bimbingan dengan judul: Dota 13', '2025-12-30 23:22:23'),
(7, 221345, 4342411010, 'guidance_request', 'ABI mengajukan bimbingan dengan judul: Dota 13', '2025-12-30 23:50:29');

-- --------------------------------------------------------

--
-- Struktur dari tabel `announcements`
--

CREATE TABLE `announcements` (
  `id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `description` text DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `announcements`
--

INSERT INTO `announcements` (`id`, `title`, `start_date`, `end_date`, `description`, `link`, `created_at`) VALUES
(21, 'ssss', '2025-12-11', '2025-12-13', 'testt', '1765432733_Laporan IMK Minggu 3 PBL-301.pdf', '2025-12-11 05:58:53'),
(22, 'asadasdaasd', '2025-12-19', '2025-12-20', 'asadasda', '', '2025-12-19 08:15:52');

-- --------------------------------------------------------

--
-- Struktur dari tabel `documents`
--

CREATE TABLE `documents` (
  `id` int(11) NOT NULL,
  `student_id` bigint(20) DEFAULT NULL,
  `attachment` varchar(255) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `chapter` varchar(100) DEFAULT NULL,
  `note` text DEFAULT NULL,
  `status` enum('pending','approved','revision') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `documents`
--

INSERT INTO `documents` (`id`, `student_id`, `attachment`, `title`, `chapter`, `note`, `status`) VALUES
(1, 4342411024, '1764055045_Format SKPPL (2025).docx.pdf', 'Skripsi', 'BAB1', 'Ini Manusia Tembus Pandang', 'revision'),
(2, 4342411024, '1764224671_Laporan Akhir TRPL-224.pdf', 'Laporan bab 1.1', '1.1', 'PRESIDEN GOVLWEKOK', 'revision'),
(3, 4342411024, '1764226611_Format Laporan New - 2025.docx', 'laporan', '34', 'KISAMAAAAAAAAAAAAAA', 'approved'),
(4, 4342411024, '1764608894_111 Pengumuman daftar ulang Ganjil TA 2025_2026_r.pdf', 'Laporan Akhir', 'Bab 1', 'Ini Laporan Saya Pak', 'pending'),
(5, 4342411024, '1764827623_Diskusi-PBL301-4342411024.pdf', 'Notif Test', 'Test 1', 'woi', 'revision'),
(6, 4342411024, '1764828180_Format SKPPL (2025).docx.pdf', 'www', 'www', 'www', 'pending'),
(7, 4342411024, '1764917946_RPL318 - Tugas 01.pdf', 'Dokumen TA', 'BAB 2', 'Ini pak', 'pending'),
(8, 4342411024, '1764918626_3A_Malam_4342411024_Tugas_KeamananBasisData.pdf', 'Dokumen TA', 'BAB 3', 'Ini Pak', 'revision'),
(13, 4342411024, '1764925566_Lembar Aktivitas Tugas 3.docx.pdf', 'Laporan TA1', 'BAB 1', 'Ini Pak', 'pending'),
(14, 4342411024, '1764925679_Kuis04-Malam-4342411024 -Nauval Putra Widaya.pdf', 'TESTT', 'TESTT', 'TESTT', 'pending'),
(15, 4342411024, '1764925895_Lembar Aktivitas Tugas TRPL-PBl 301.pdf', 'WOWOWOOWO', 'WOWOWOWO', 'OWOWOWOW', 'pending'),
(16, 4342411005, '1764927063_Diskusi-PBL301-4342411024.pdf', 'Laporan TA2', 'Bab 2', 'Ini Pak', 'revision'),
(17, 4342411005, '1765250440_Praktikum M8.pdf', 'TESTT', 'TESTT', 'TESTT', 'pending'),
(18, 4342411005, '1765250667_Kuis04-Malam-4342411024 -Nauval Putra Widaya.pdf', 'WW', 'WW', 'WWW', 'pending'),
(19, 4342411000, '1765284264_Kuis01-Malam-4342411024.pdf', 'TESTTT1', 'BAB 1', 'WEEEEE', 'revision'),
(20, 4342411000, '1765867189_CV. Nauval Putra Widaya.pdf', 'Laporan 13', NULL, NULL, 'pending');

-- --------------------------------------------------------

--
-- Struktur dari tabel `document_feedbacks`
--

CREATE TABLE `document_feedbacks` (
  `id` int(11) NOT NULL,
  `document_id` int(11) NOT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `comment` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `document_feedbacks`
--

INSERT INTO `document_feedbacks` (`id`, `document_id`, `attachment`, `comment`) VALUES
(5, 1, NULL, 'Sbar ini masih di toilet'),
(6, 2, '1764224719_fb_2.pdf', 'nih liat file nya gw males komen disini'),
(7, 3, NULL, 'baguss sangat baguss'),
(8, 5, NULL, 'WOi ini jelek bgt'),
(9, 8, '1764918668_Diskusi-PBL301-4342411024 pt2.pdf', 'Ini Salah Woi Lu Yang Bener LAA, lu liat baik baik file gw'),
(11, 16, NULL, 'can yu spek englishha?  fgwak yau!'),
(12, 19, '1765284308_Format SKPPL (2025).docx.pdf', 'testtttt');

-- --------------------------------------------------------

--
-- Struktur dari tabel `final_thesises`
--

CREATE TABLE `final_thesises` (
  `id` int(11) NOT NULL,
  `student_id` bigint(20) DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `final_thesises`
--

INSERT INTO `final_thesises` (`id`, `student_id`, `file`, `created_at`) VALUES
(1, 4342411000, '1766299639_111 Pengumuman daftar ulang Ganjil TA 2025_2026_r.pdf', '2025-12-21 06:47:19'),
(2, 4342411030, '1766300898_Lembar Aktivitas Tugas 4 (1).pdf', '2025-12-21 07:08:18');

-- --------------------------------------------------------

--
-- Struktur dari tabel `guidances`
--

CREATE TABLE `guidances` (
  `id` int(11) NOT NULL,
  `student_id` bigint(20) NOT NULL,
  `lecturer_id` bigint(20) DEFAULT NULL,
  `is_approved` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `guidances`
--

INSERT INTO `guidances` (`id`, `student_id`, `lecturer_id`, `is_approved`, `created_at`) VALUES
(10, 4342411024, 221345, 1, '2025-11-10 08:20:30'),
(11, 4342411023, 221345, 2, '2025-11-10 08:20:30'),
(12, 434241100, 221345, 2, '2025-11-10 08:20:30'),
(13, 4342411001, 221345, 2, '2025-11-10 08:20:30'),
(14, 4342411005, 221345, 3, '2025-11-10 08:20:30'),
(15, 4342411006, 221345, 1, '2025-11-10 08:20:30'),
(16, 4342411030, 221345, 3, '2025-11-10 08:20:30'),
(17, 4342411001, 221345, 2, '2025-11-14 06:33:30'),
(18, 4342411001, 221345, 2, '2025-12-05 07:05:59'),
(19, 4342411001, 221345, 2, '2025-12-05 09:12:13'),
(20, 4342411001, 221345, 2, '2025-12-05 09:14:41'),
(21, 4342411001, 221345, 2, '2025-12-05 09:20:42'),
(22, 4342411001, 221345, 2, '2025-12-05 09:28:33'),
(23, 4342411000, 221345, 3, '2025-12-09 12:40:08'),
(24, 4342411001, 221345, 2, '2025-12-15 17:05:35'),
(25, 4342411000, 221345, 3, '2025-12-16 04:34:11'),
(26, 4342411000, 221345, 3, '2025-12-16 06:13:33'),
(27, 4342411010, 221345, 2, '2025-12-21 12:34:48'),
(28, 4342411010, 221345, 2, '2025-12-27 06:48:28'),
(29, 4342411010, 221345, 2, '2025-12-28 09:10:49'),
(30, 4342411010, 221345, 2, '2025-12-30 16:22:23'),
(31, 4342411010, 221345, 0, '2025-12-30 16:50:29');

-- --------------------------------------------------------

--
-- Struktur dari tabel `lecturers`
--

CREATE TABLE `lecturers` (
  `employee_number` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `study_program_id` int(11) NOT NULL,
  `expertise` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `lecturers`
--

INSERT INTO `lecturers` (`employee_number`, `user_id`, `study_program_id`, `expertise`) VALUES
(221345, 13, 3, 'Main Bola');

-- --------------------------------------------------------

--
-- Struktur dari tabel `majors`
--

CREATE TABLE `majors` (
  `id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `majors`
--

INSERT INTO `majors` (`id`, `title`) VALUES
(1, 'Teknik Informatika');

-- --------------------------------------------------------

--
-- Struktur dari tabel `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `student_id` bigint(20) DEFAULT NULL,
  `lecturer_id` bigint(20) DEFAULT NULL,
  `title` varchar(100) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `notifications`
--

INSERT INTO `notifications` (`id`, `student_id`, `lecturer_id`, `title`, `description`) VALUES
(13, 4342411001, 221345, 'Pengajuan Bimbingan Baru', 'Sukuna mengajukan bimbingan dengan judul: Dota 13'),
(14, 4342411005, 221345, 'Dokumen Baru', 'Mahasiswa mengupload dokumen Bab 2.'),
(15, 4342411005, NULL, 'Feedback Dokumen', 'Dosen memberikan komentar pada dokumen Anda.'),
(16, 4342411005, 221345, 'Dokumen Baru', ' mengupload dokumen TESTT.'),
(17, 4342411005, 221345, 'Dokumen Baru', 'Megumi mengupload dokumen WW.'),
(19, 4342411000, 221345, 'Dokumen Baru', 'testtt mengupload dokumen BAB 1.'),
(20, 4342411000, NULL, 'Feedback Dokumen', 'Dosen memberikan komentar pada dokumen Anda.'),
(21, 4342411000, 221345, 'Pengajuan Jadwal Baru', 'testtt mengajukan jadwal bimbingan.'),
(22, 4342411001, 221345, 'Pengajuan Bimbingan Baru', 'Sukuna mengajukan bimbingan dengan judul: Dota12'),
(23, 4342411000, 221345, 'Pengajuan Bimbingan Baru', 'testtt mengajukan bimbingan dengan judul: WOI!'),
(24, 4342411000, 221345, 'Pengajuan Bimbingan Baru', 'testtt mengajukan bimbingan dengan judul: TESWWW'),
(25, 4342411024, 221345, 'Pengajuan Jadwal Baru', 'Nauval mengajukan jadwal bimbingan.'),
(26, 4342411030, 221345, 'Final Thesis', 'keysya arghinaya mengupload FINAL Tugas Akhir.'),
(27, 4342411010, 221345, 'Pengajuan Bimbingan Baru', 'ABI mengajukan bimbingan dengan judul: test'),
(28, 4342411024, 221345, 'Pengajuan Jadwal Baru', 'Nauval mengajukan jadwal bimbingan.'),
(29, 4342411010, 221345, 'Pengajuan Bimbingan Baru', 'ABI mengajukan bimbingan dengan judul: wee'),
(30, 4342411010, 221345, 'Pengajuan Bimbingan Baru', 'ABI mengajukan bimbingan dengan judul: Dota 13'),
(31, 4342411010, 221345, 'Pengajuan Bimbingan Baru', 'ABI mengajukan bimbingan dengan judul: Dota 13'),
(32, 4342411010, 221345, 'Pengajuan Bimbingan Baru', 'ABI mengajukan bimbingan dengan judul: Dota 13');

-- --------------------------------------------------------

--
-- Struktur dari tabel `notification_settings`
--

CREATE TABLE `notification_settings` (
  `id` int(11) NOT NULL,
  `lecturer_id` bigint(20) NOT NULL,
  `is_enabled` tinyint(1) DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `notification_settings`
--

INSERT INTO `notification_settings` (`id`, `lecturer_id`, `is_enabled`, `updated_at`) VALUES
(1, 221345, 0, '2025-12-22 05:29:53');

-- --------------------------------------------------------

--
-- Struktur dari tabel `notification_settings_students`
--

CREATE TABLE `notification_settings_students` (
  `id` int(11) NOT NULL,
  `student_id` bigint(20) NOT NULL,
  `is_enabled` tinyint(1) DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `notification_settings_students`
--

INSERT INTO `notification_settings_students` (`id`, `student_id`, `is_enabled`, `updated_at`) VALUES
(1, 4342411024, 1, '2025-12-24 08:29:13');

-- --------------------------------------------------------

--
-- Struktur dari tabel `schedules`
--

CREATE TABLE `schedules` (
  `id` int(11) NOT NULL,
  `student_id` bigint(20) DEFAULT NULL,
  `lecture_id` bigint(20) DEFAULT NULL,
  `title` varchar(100) NOT NULL,
  `session` enum('online','offline') NOT NULL,
  `datetime` datetime NOT NULL,
  `description` text DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `schedules`
--

INSERT INTO `schedules` (`id`, `student_id`, `lecture_id`, `title`, `session`, `datetime`, `description`, `location`, `status`, `updated_at`) VALUES
(10, NULL, 221345, 'Bab1', 'online', '2025-11-12 14:44:00', 'Ini Manusia Tembus Pandang', 'https://youtu.be/xvFZjo5PgG0?si=yystUGPh6eon4Oco', 'approved', '2025-12-18 01:14:53'),
(11, NULL, 221345, 'Bab2', 'offline', '2025-11-13 14:50:00', 'Bab3', 'TA1', 'approved', '2025-12-18 01:14:53'),
(12, 4342411024, 221345, 'bab1', 'offline', '2025-11-19 12:12:24', 'bab1', 'ta1', 'approved', '2025-12-18 01:14:53'),
(13, 4342411024, 221345, 'Bab 1 TA', 'offline', '2025-12-05 14:31:52', 'INI PAK', 'NAGOYA', 'rejected', '2025-12-18 01:14:53'),
(14, NULL, 221345, 'test', 'offline', '2025-12-05 17:22:00', 'test', 'tets', 'approved', '2025-12-18 01:14:53'),
(15, 4342411000, 221345, 'BAB 2', 'offline', '2025-12-09 19:46:36', 'Zoom Perdana', 'Tanjoeng Oemang', 'approved', '2025-12-18 01:14:53'),
(16, 4342411024, 221345, 'test', 'offline', '2025-12-20 06:16:00', 'TSEET', 'TESTT', 'approved', '2025-12-18 01:16:34'),
(17, 4342411024, 221345, 'ssss', 'offline', '2025-12-31 20:34:00', 'ssss', 'sadasdads', 'pending', '2025-12-21 13:35:08');

-- --------------------------------------------------------

--
-- Struktur dari tabel `schedule_attendances`
--

CREATE TABLE `schedule_attendances` (
  `id` int(11) NOT NULL,
  `schedule_id` int(11) NOT NULL,
  `student_id` bigint(20) DEFAULT NULL,
  `status` enum('attend','absent','unconfirmed') DEFAULT 'unconfirmed',
  `reason` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `schedule_attendances`
--

INSERT INTO `schedule_attendances` (`id`, `schedule_id`, `student_id`, `status`, `reason`) VALUES
(3, 11, 4342411024, 'attend', 'hadir'),
(4, 10, 4342411024, 'absent', 'sakit'),
(5, 15, 4342411024, 'absent', 'Sakit');

-- --------------------------------------------------------

--
-- Struktur dari tabel `students`
--

CREATE TABLE `students` (
  `student_number` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `thesis` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `students`
--

INSERT INTO `students` (`student_number`, `user_id`, `thesis`) VALUES
(434241100, 31, 'Cara Membunuh Sukuna'),
(4342411000, 41, 'TESWWW'),
(4342411001, 32, 'Dota12'),
(4342411005, 33, 'Membantu GOJO mengalahkan Sukuna'),
(4342411006, 34, 'Membantu mengalahkan sukuna'),
(4342411010, 44, 'Dota 13'),
(4342411023, 12, 'Aplikasi SIK'),
(4342411024, 30, 'Aplikasi DigiTA'),
(4342411030, 40, 'Membuat Aplikasi DIGITAL');

-- --------------------------------------------------------

--
-- Struktur dari tabel `study_programs`
--

CREATE TABLE `study_programs` (
  `id` int(11) NOT NULL,
  `major_id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `study_programs`
--

INSERT INTO `study_programs` (`id`, `major_id`, `title`) VALUES
(1, 1, 'Teknologi Rekayasa Perangkat Lunak'),
(2, 1, 'Multimedia'),
(3, 1, 'Cyber'),
(4, 1, 'Informatika');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `user_type` enum('student','lecturer','admin') NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `name`, `user_type`, `phone_number`, `email`, `username`, `password`) VALUES
(1, 'admin', 'admin', '081274231123', 'admin@gmail.com', 'admin', 'admin123'),
(2, 'admin2', 'admin', '082344212331', 'nauvalwidaya@gmail.com', 'admin2', 'admin1234'),
(12, 'Nakano Nino', 'student', '23212222123', 'nino@gmail.com', 'nakanonino', '123456'),
(13, 'Nakano Yotsubaaaa', 'lecturer', '081277337733', 'yotsuba@gmail.com', 'nakanoyotsuba', '123456'),
(30, 'Nauvalll', 'student', '081277442233', 'novalwidaya@gmail.com', 'nauval', '$2y$10$wtAb5xRh3UXqjwBetYrO6OB9pP3L.kKIKP/c.aiERDeCWTbkg7ckO'),
(31, 'Nauval Satoru', 'student', '22313124274', 'satoru@gmail.com', 'nauvalsatoru', '$2y$10$.ip7VvEgPtd.bHdrVtS7/ekTIclp5r.5j8uVlWjoURlM41NJBNS5S'),
(32, 'Sukuna', 'student', '342221233', 'sukuna@gmail.com', 'sukuna', '123456'),
(33, 'Megumi', 'student', '3421112323', 'megumi@gmail.com', 'megumi', '123456'),
(34, 'Kugisaki Nobara', 'student', '3473661743', 'kugisaki@gmail.com', 'kugisakinobara', '$2y$10$3AVAxGCy5iDdRf/RM4QyTu1D4O0PNOplcUkSfzxuYFap3dtBRY1.6'),
(40, 'keysya arghinaya', 'student', '081277221234', 'keysya@gmail.com', 'keysyaarghinaya', '123456'),
(41, 'testtt', 'student', '08236134323', 'testt@gmail.com', 'testtt', '123456'),
(42, 'Keykeyi', 'admin', '2313214244', 'keykeyi@gmail.com', 'keykeyi', '$2y$10$wtOJs/d4ECP8ui.v/4/j3uSPTk0T.7kGyD9lg8odIheYqX..A5zqW'),
(44, 'ABI', 'student', '773773733', 'abi@gmail.com', 'abi', '123456');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `activities`
--
ALTER TABLE `activities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `activities_ibfk_1` (`student_id`);

--
-- Indeks untuk tabel `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `documents_ibfk_1` (`student_id`);

--
-- Indeks untuk tabel `document_feedbacks`
--
ALTER TABLE `document_feedbacks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `document_id` (`document_id`);

--
-- Indeks untuk tabel `final_thesises`
--
ALTER TABLE `final_thesises`
  ADD PRIMARY KEY (`id`),
  ADD KEY `final_thesises_ibfk_1` (`student_id`);

--
-- Indeks untuk tabel `guidances`
--
ALTER TABLE `guidances`
  ADD PRIMARY KEY (`id`),
  ADD KEY `guidances_ibfk_2` (`lecturer_id`),
  ADD KEY `fk_guidances_students` (`student_id`);

--
-- Indeks untuk tabel `lecturers`
--
ALTER TABLE `lecturers`
  ADD PRIMARY KEY (`employee_number`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `study_program_id` (`study_program_id`);

--
-- Indeks untuk tabel `majors`
--
ALTER TABLE `majors`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_ibfk_1` (`student_id`);

--
-- Indeks untuk tabel `notification_settings`
--
ALTER TABLE `notification_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `lecturer_id` (`lecturer_id`);

--
-- Indeks untuk tabel `notification_settings_students`
--
ALTER TABLE `notification_settings_students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_id` (`student_id`);

--
-- Indeks untuk tabel `schedules`
--
ALTER TABLE `schedules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `schedules_ibfk_1` (`student_id`),
  ADD KEY `schedules_ibfk_2` (`lecture_id`);

--
-- Indeks untuk tabel `schedule_attendances`
--
ALTER TABLE `schedule_attendances`
  ADD PRIMARY KEY (`id`),
  ADD KEY `schedule_id` (`schedule_id`),
  ADD KEY `schedule_attendances_ibfk_2` (`student_id`);

--
-- Indeks untuk tabel `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`student_number`),
  ADD UNIQUE KEY `student_number` (`student_number`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `study_programs`
--
ALTER TABLE `study_programs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `major_id` (`major_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `activities`
--
ALTER TABLE `activities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT untuk tabel `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT untuk tabel `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT untuk tabel `document_feedbacks`
--
ALTER TABLE `document_feedbacks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT untuk tabel `final_thesises`
--
ALTER TABLE `final_thesises`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `guidances`
--
ALTER TABLE `guidances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT untuk tabel `majors`
--
ALTER TABLE `majors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT untuk tabel `notification_settings`
--
ALTER TABLE `notification_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `notification_settings_students`
--
ALTER TABLE `notification_settings_students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `schedules`
--
ALTER TABLE `schedules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT untuk tabel `schedule_attendances`
--
ALTER TABLE `schedule_attendances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `study_programs`
--
ALTER TABLE `study_programs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `activities`
--
ALTER TABLE `activities`
  ADD CONSTRAINT `activities_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_number`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_number`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `document_feedbacks`
--
ALTER TABLE `document_feedbacks`
  ADD CONSTRAINT `document_feedbacks_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `documents` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `final_thesises`
--
ALTER TABLE `final_thesises`
  ADD CONSTRAINT `final_thesises_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_number`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `guidances`
--
ALTER TABLE `guidances`
  ADD CONSTRAINT `fk_guidances_students` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_number`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `guidances_ibfk_2` FOREIGN KEY (`lecturer_id`) REFERENCES `lecturers` (`employee_number`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `lecturers`
--
ALTER TABLE `lecturers`
  ADD CONSTRAINT `lecturers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `lecturers_ibfk_2` FOREIGN KEY (`study_program_id`) REFERENCES `study_programs` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_number`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `schedules`
--
ALTER TABLE `schedules`
  ADD CONSTRAINT `schedules_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_number`) ON DELETE CASCADE,
  ADD CONSTRAINT `schedules_ibfk_2` FOREIGN KEY (`lecture_id`) REFERENCES `lecturers` (`employee_number`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `schedule_attendances`
--
ALTER TABLE `schedule_attendances`
  ADD CONSTRAINT `schedule_attendances_ibfk_1` FOREIGN KEY (`schedule_id`) REFERENCES `schedules` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `schedule_attendances_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_number`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `students_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `study_programs`
--
ALTER TABLE `study_programs`
  ADD CONSTRAINT `study_programs_ibfk_1` FOREIGN KEY (`major_id`) REFERENCES `majors` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
