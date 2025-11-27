<?php
include 'cors.php';

require_once("config_api.php");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

$student_id = $_POST['student_id'] ?? null;
$lecture_id = $_POST['lecture_id'] ?? null;
$title      = $_POST['title'] ?? null;
$session    = strtolower($_POST['session'] ?? null); // FIX ENUM LOWERCASE
$datetime   = $_POST['datetime'] ?? null;
$location   = $_POST['location'] ?? null;
$description= $_POST['description'] ?? null;

if (!$student_id || !$lecture_id || !$title || !$session || !$datetime) {
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
    exit;
}

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

if ($stmt->execute()) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $stmt->error]);
}
?>
