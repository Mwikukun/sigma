<?php
include 'cors.php';
require_once("config_api.php");

$data = json_decode(file_get_contents("php://input"), true);
$lecturer_id = $data['lecturer_id'] ?? '';

if (!$lecturer_id) {
    echo json_encode(["success" => false]);
    exit;
}

$query = "SELECT is_enabled FROM notification_settings WHERE lecturer_id = ? LIMIT 1";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $lecturer_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    // default aktif
    echo json_encode([
        "success" => true,
        "is_enabled" => 1
    ]);
    exit;
}

$row = $result->fetch_assoc();
echo json_encode([
    "success" => true,
    "is_enabled" => (int)$row['is_enabled']
]);
