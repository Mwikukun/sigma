-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 27 Nov 2025 pada 09.57
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
(3, 4342411024, '1764226611_Format Laporan New - 2025.docx', 'laporan', '34', 'KISAMAAAAAAAAAAAAAA', 'approved');

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
(7, 3, NULL, 'baguss sangat baguss');

-- --------------------------------------------------------

--
-- Struktur dari tabel `final_thesises`
--

CREATE TABLE `final_thesises` (
  `id` int(11) NOT NULL,
  `student_id` bigint(20) DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(14, 4342411005, 221345, 1, '2025-11-10 08:20:30'),
(15, 4342411006, 221345, 1, '2025-11-10 08:20:30'),
(16, 4342411030, 221345, 1, '2025-11-10 08:20:30'),
(17, 4342411001, 221345, 2, '2025-11-14 06:33:30');

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
  `title` varchar(100) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `datetime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `description` text DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `schedules`
--

INSERT INTO `schedules` (`id`, `student_id`, `lecture_id`, `title`, `session`, `datetime`, `description`, `location`, `status`) VALUES
(10, NULL, 221345, 'Bab1', 'online', '2025-11-12 07:44:00', 'Ini Manusia Tembus Pandang', 'https://youtu.be/xvFZjo5PgG0?si=yystUGPh6eon4Oco', 'approved'),
(11, NULL, 221345, 'Bab2', 'offline', '2025-11-13 07:50:00', 'Bab3', 'TA1', 'approved'),
(12, 4342411024, 221345, 'bab1', 'offline', '2025-11-19 05:12:24', 'bab1', 'ta1', 'approved');

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
(4, 10, 4342411024, 'absent', 'sakit');

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
(4342411001, 32, 'Mengalahkan Gojo'),
(4342411005, 33, 'Membantu GOJO mengalahkan Sukuna'),
(4342411006, 34, 'Membantu mengalahkan sukuna'),
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
(13, 'Nakano Yotsuba', 'lecturer', '081277337733', 'yotsuba@gmail.com', 'nakanoyotsuba', '123456'),
(30, 'Nauval', 'student', '081277442233', 'novalwidaya@gmail.com', 'nauval', '$2y$10$wtAb5xRh3UXqjwBetYrO6OB9pP3L.kKIKP/c.aiERDeCWTbkg7ckO'),
(31, 'Nauval Satoru', 'student', '22313124274', 'satoru@gmail.com', 'nauvalsatoru', '$2y$10$.ip7VvEgPtd.bHdrVtS7/ekTIclp5r.5j8uVlWjoURlM41NJBNS5S'),
(32, 'Sukuna', 'student', '342221233', 'sukuna@gmail.com', 'sukuna', '123456'),
(33, 'Megumi', 'student', '3421112323', 'megumi@gmail.com', 'megumi', '123456'),
(34, 'Kugisaki Nobara', 'student', '3473661743', 'kugisaki@gmail.com', 'kugisakinobara', '$2y$10$3AVAxGCy5iDdRf/RM4QyTu1D4O0PNOplcUkSfzxuYFap3dtBRY1.6'),
(40, 'keysya arghinaya', 'student', '081277221234', 'keysya@gmail.com', 'keysyaarghinaya', '123456');

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `document_feedbacks`
--
ALTER TABLE `document_feedbacks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `final_thesises`
--
ALTER TABLE `final_thesises`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `guidances`
--
ALTER TABLE `guidances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT untuk tabel `majors`
--
ALTER TABLE `majors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `schedules`
--
ALTER TABLE `schedules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT untuk tabel `schedule_attendances`
--
ALTER TABLE `schedule_attendances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `study_programs`
--
ALTER TABLE `study_programs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

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
