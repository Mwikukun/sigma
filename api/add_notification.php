<?php
include 'cors.php';
include 'config_api.php';

$student_id = $_POST["student_id"] ?? null;
$title = $_POST["title"] ?? "";
$description = $_POST["description"] ?? "";

if (!$student_id || empty($title)) {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap"]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO notifications (student_id, title, description) VALUES (?, ?, ?)");
$stmt->bind_param("iss", $student_id, $title, $description);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Notifikasi tersimpan"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal menyimpan notifikasi"]);
}
?>
