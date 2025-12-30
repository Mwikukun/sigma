<?php
include 'cors.php';
include 'config_api.php';

$task_id  = $_POST['task_id'] ?? '';
$due_date = $_POST['due_date'] ?? '';

if (!$task_id || !$due_date) {
    echo json_encode(["success" => false]);
    exit;
}

$sql = "UPDATE activities SET due_date = ? WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $due_date, $task_id);
$stmt->execute();

echo json_encode(["success" => true]);
