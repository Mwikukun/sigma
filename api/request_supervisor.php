<?php
include 'cors.php';
include "config_api.php";

// 🔹 Ambil input dari Flutter
$student_id = $_POST['student_id'] ?? null;      // -> pakai student_number
$lecturer_id = $_POST['lecturer_id'] ?? null;    // -> pakai employee_number
$thesis_title = $_POST['thesis_title'] ?? null;

// 🔹 Validasi input
if (!$student_id || !$lecturer_id || !$thesis_title) {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap."]);
    exit;
}

// =============================================================
// 1️⃣ CEK APAKAH DOSEN ADA DI DATABASE
// =============================================================
$lecturerCheck = $conn->query("SELECT employee_number FROM lecturers WHERE employee_number = '$lecturer_id'");
if ($lecturerCheck->num_rows == 0) {
    echo json_encode([
        "success" => false,
        "message" => "Dosen dengan NIK $lecturer_id tidak ditemukan di database."
    ]);
    exit;
}

// =============================================================
// 2️⃣ CEK APAKAH MAHASISWA SUDAH PUNYA PENGAJUAN AKTIF
// =============================================================
$checkActive = $conn->query("
    SELECT * FROM guidances 
    WHERE student_id = '$student_id' 
    AND is_approved = 0
");
if ($checkActive->num_rows > 0) {
    echo json_encode([
        "success" => false,
        "message" => "Anda sudah memiliki pengajuan aktif. Harap tunggu konfirmasi dosen."
    ]);
    exit;
}

// =============================================================
// 3️⃣ CEK APAKAH DOSEN SUDAH PENUH
// =============================================================
$count = $conn->query("
    SELECT COUNT(*) AS total 
    FROM guidances 
    WHERE lecturer_id = '$lecturer_id' 
    AND is_approved = 1
")->fetch_assoc();

if ($count['total'] >= 10) {
    echo json_encode([
        "success" => false,
        "message" => "Slot dosen sudah penuh."
    ]);
    exit;
}

// =============================================================
// 4️⃣ SIMPAN PENGAJUAN BARU KE GUIDANCES
// =============================================================
$insert = $conn->query("
    INSERT INTO guidances (student_id, lecturer_id, is_approved)
    VALUES ('$student_id', '$lecturer_id', 0)
");

if (!$insert) {
    echo json_encode([
        "success" => false,
        "message" => "Gagal menyimpan pengajuan.",
        "debug" => $conn->error
    ]);
    exit;
}

// =============================================================
// 5️⃣ UPDATE JUDUL SKRIPSI DI TABEL STUDENTS
// =============================================================
$updateStudent = $conn->query("
    UPDATE students 
    SET thesis = '$thesis_title' 
    WHERE student_number = '$student_id'
");

if (!$updateStudent) {
    echo json_encode([
        "success" => true,
        "message" => "Pengajuan berhasil, tapi gagal memperbarui judul mahasiswa.",
        "debug" => $conn->error
    ]);
    exit;
}

// =============================================================
// ✅ SEMUA BERHASIL
// =============================================================
echo json_encode([
    "success" => true,
    "message" => "Pengajuan berhasil dikirim. Menunggu konfirmasi dosen."
]);
exit;
?>
