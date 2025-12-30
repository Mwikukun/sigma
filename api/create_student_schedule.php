<?php
include 'cors.php';
include "config_api.php";

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

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
$student_id  = $_POST['student_id'] ?? null;
$lecture_id  = $_POST['lecture_id'] ?? null; // lecturer_id
$title       = $_POST['title'] ?? null;
$session     = strtolower($_POST['session'] ?? null);
$datetime    = $_POST['datetime'] ?? null;
$location    = $_POST['location'] ?? null;
$description = $_POST['description'] ?? null;

if (!$student_id || !$lecture_id || !$title || !$session || !$datetime) {
    echo json_encode([
        "status" => "error",
        "message" => "Data tidak lengkap"
    ]);
    exit;
}

/* =========================
   1. INSERT SCHEDULE
========================= */
$stmt = $conn->prepare("
    INSERT INTO schedules
    (student_id, lecture_id, title, session, datetime, location, description, status)
    VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')
");

$stmt->bind_param(
    "iisssss",
    $student_id,
    $lecture_id,
    $title,
    $session,
    $datetime,
    $location,
    $description
);

$success = $stmt->execute();

/* =========================
   2. NOTIFIKASI + ACTIVITY LOG
========================= */
if ($success) {

    // 🔹 Ambil nama mahasiswa
    $sn = $conn->query("
        SELECT u.name
        FROM students s
        JOIN users u ON s.user_id = u.id
        WHERE s.student_number = '$student_id'
    ");
    $student_name = $sn->fetch_assoc()['name'] ?? "Mahasiswa";

    // 🔹 Notifikasi
    $n_title = "Pengajuan Jadwal Baru";
    $n_desc  = "$student_name mengajukan jadwal bimbingan.";

    $notif = $conn->prepare("
        INSERT INTO notifications (student_id, lecturer_id, title, description)
        VALUES (?, ?, ?, ?)
    ");
    $notif->bind_param("iiss", $student_id, $lecture_id, $n_title, $n_desc);
    $notif->execute();

    // 🆕 ACTIVITY LOG (INI YANG KAMU BUTUH)
    logActivity(
        $conn,
        $lecture_id,
        $student_id,
        "schedule_request",
        $n_desc
    );

    echo json_encode(["status" => "success"]);
} 
else {
    echo json_encode([
        "status" => "error",
        "message" => $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
