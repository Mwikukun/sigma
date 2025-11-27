<?php
include 'cors.php';
include "config_api.php";

$student_id = $_GET['student_id'] ?? null;

if (!$student_id) {
    echo json_encode([
        "status" => "error",
        "message" => "student_id parameter is required"
    ]);
    exit;
}

// Ambil semua jadwal pending milik mahasiswa ini
$stmt = $conn->prepare("
    SELECT id, title, session, datetime, description, location, status
    FROM schedules
    WHERE student_id = ?
      AND status = 'pending'
    ORDER BY datetime ASC
");

$stmt->bind_param("i", $student_id);
$stmt->execute();
$res = $stmt->get_result();

$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode([
    "status" => "success",
    "data" => $data
]);
?>
