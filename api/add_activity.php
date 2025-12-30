<?php
include 'cors.php';
include 'config_api.php';

$student_id  = $_POST['student_id'] ?? '';
$title       = $_POST['title'] ?? '';
$description = $_POST['description'] ?? '';
$section     = $_POST['section'] ?? 'to-do';
$percentage  = $_POST['percentage'] ?? 0;
$start_date  = $_POST['start_date'] ?? '';

if (!$student_id || !$title || !$start_date) {
    echo json_encode([
        "success" => false,
        "message" => "Data tidak lengkap"
    ]);
    exit;
}

$sql = "
INSERT INTO activities
(student_id, title, description, section, percentage, start_date)
VALUES (?, ?, ?, ?, ?, ?)
";

$stmt = $conn->prepare($sql);
$stmt->bind_param(
    "isssis",
    $student_id,
    $title,
    $description,
    $section,
    $percentage,
    $start_date
);

if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode([
        "success" => false,
        "message" => $stmt->error
    ]);
}
