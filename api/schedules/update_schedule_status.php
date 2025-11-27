<?php
include '../config_api.php';
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json; charset=utf-8');


$id = $_POST['schedule_id'] ?? '';
$status = $_POST['status'] ?? '';

if (!$id || !$status) {
    echo json_encode(["success" => false, "message" => "Data incomplete"]);
    exit;
}

$query = "UPDATE schedules SET status=? WHERE id=?";
$stmt = $conn->prepare($query);
$stmt->bind_param("si", $status, $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => "Failed"]);
}
