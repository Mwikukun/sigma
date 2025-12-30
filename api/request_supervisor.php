<?php
include 'cors.php';
include "config_api.php";

/* =========================
   HELPER ACTIVITY LOG
========================= */
function logActivity($conn, $lecturer_id, $student_id, $type, $desc) {
    $stmt = $conn->prepare("
        INSERT INTO activity_logs 
        (lecturer_id, student_id, activity_type, description)
        VALUES (?, ?, ?, ?)
    ");
    $stmt->bind_param("iiss", $lecturer_id, $student_id, $type, $desc);
    $stmt->execute();
}

/* =========================
   AMBIL DATA
========================= */
$student_id   = $_POST['student_id'] ?? null;
$lecturer_id  = $_POST['lecturer_id'] ?? null;
$thesis_title = $_POST['thesis_title'] ?? null;

if (!$student_id || !$lecturer_id || !$thesis_title) {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap."]);
    exit;
}

/* =========================
   CEK DOSEN
========================= */
$lecturerCheck = $conn->query("
    SELECT employee_number 
    FROM lecturers 
    WHERE employee_number = '$lecturer_id'
");
if ($lecturerCheck->num_rows == 0) {
    echo json_encode([
        "success" => false,
        "message" => "Dosen dengan NIK $lecturer_id tidak ditemukan."
    ]);
    exit;
}

/* =========================
   CEK PENGAJUAN AKTIF
========================= */
$checkActive = $conn->query("
    SELECT * 
    FROM guidances 
    WHERE student_id = '$student_id' 
    AND is_approved = 0
");
if ($checkActive->num_rows > 0) {
    echo json_encode([
        "success" => false,
        "message" => "Anda sudah memiliki pengajuan aktif."
    ]);
    exit;
}

/* =========================
   CEK SLOT DOSEN
========================= */
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

/* =========================
   INSERT GUIDANCE
========================= */
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

/* =========================
   AMBIL NAMA MAHASISWA
========================= */
$studentQuery = $conn->query("
    SELECT u.name 
    FROM students s 
    JOIN users u ON s.user_id = u.id 
    WHERE s.student_number = '$student_id'
");
$student_name = $studentQuery->fetch_assoc()['name'] ?? "Mahasiswa";

/* =========================
   NOTIFIKASI DOSEN
========================= */
$title = "Pengajuan Bimbingan Baru";
$desc  = "$student_name mengajukan bimbingan dengan judul: $thesis_title";

$notif = $conn->prepare("
    INSERT INTO notifications (student_id, lecturer_id, title, description)
    VALUES (?, ?, ?, ?)
");
$notif->bind_param("iiss", $student_id, $lecturer_id, $title, $desc);
$notif->execute();

/* =========================
   🆕 ACTIVITY LOG
========================= */
logActivity(
    $conn,
    $lecturer_id,
    $student_id,
    "guidance_request",
    $desc
);

/* =========================
   UPDATE JUDUL SKRIPSI
========================= */
$conn->query("
    UPDATE students 
    SET thesis = '$thesis_title' 
    WHERE student_number = '$student_id'
");

echo json_encode([
    "success" => true,
    "message" => "Pengajuan berhasil dikirim. Menunggu konfirmasi dosen."
]);
?>
