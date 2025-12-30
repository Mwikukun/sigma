<?php
include 'cors.php';
require_once("config_api.php");

$data = json_decode(file_get_contents("php://input"), true);
$student_id = $data['student_id'] ?? '';

if (!$student_id) {
    echo json_encode(["success" => false]);
    exit;
}

$query = "SELECT is_enabled FROM notification_settings_students WHERE student_id = ? LIMIT 1";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $student_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        "success" => true,
        "is_enabled" => 1 // default ON
    ]);
    exit;
}

$row = $result->fetch_assoc();
echo json_encode([
    "success" => true,
    "is_enabled" => (int)$row['is_enabled']
]);
