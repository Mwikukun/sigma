<?php
include 'cors.php';
require_once("config_api.php");

$data = json_decode(file_get_contents("php://input"), true);
$student_id = $data['student_id'] ?? '';
$is_enabled = $data['is_enabled'] ?? 1;

if (!$student_id) {
    echo json_encode(["success" => false]);
    exit;
}

$query = "
INSERT INTO notification_settings_students (student_id, is_enabled)
VALUES (?, ?)
ON DUPLICATE KEY UPDATE
is_enabled = VALUES(is_enabled)
";

$stmt = $conn->prepare($query);
$stmt->bind_param("si", $student_id, $is_enabled);
$stmt->execute();

echo json_encode(["success" => true]);
