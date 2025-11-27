<?php
include 'config_api.php';
include 'cors.php';

$data = json_decode(file_get_contents("php://input"), true);
$student_id = $data['student_id'] ?? null;
$schedule_id = $data['schedule_id'] ?? null;
$status = $data['status'] ?? 'unconfirmed';
$reason = $data['reason'] ?? null;

if (!$student_id || !$schedule_id) {
    echo json_encode([
        "status" => false,
        "message" => "student_id dan schedule_id wajib diisi"
    ]);
    exit;
}

// 🔹 Cek apakah sudah pernah konfirmasi
$check = $conn->prepare("
    SELECT id FROM schedule_attendances 
    WHERE student_id = ? AND schedule_id = ?
");
$check->bind_param("si", $student_id, $schedule_id);
$check->execute();
$result = $check->get_result();

if ($result->num_rows > 0) {
    echo json_encode([
        "status" => false,
        "message" => "Kamu sudah melakukan konfirmasi untuk jadwal ini."
    ]);
    exit;
}

// 🔹 Insert baru
$stmt = $conn->prepare("
    INSERT INTO schedule_attendances (schedule_id, student_id, status, reason)
    VALUES (?, ?, ?, ?)
");
$stmt->bind_param("iiss", $schedule_id, $student_id, $status, $reason);

if ($stmt->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Konfirmasi berhasil disimpan."
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Gagal menyimpan konfirmasi."
    ]);
}

$stmt->close();
$conn->close();
?>
