<?php
include 'cors.php';
include 'config_api.php';

$student_id = $_POST["student_id"];

$query = $conn->prepare("
    SELECT id, student_id, title, chapter, note, attachment,
        CONCAT('http://127.0.0.1/SIGMA/uploads/documents/', attachment) AS attachment_url,
        status
    FROM documents
    WHERE student_id = ?
    ORDER BY id DESC
");

$query->bind_param("i", $student_id);
$query->execute();

$result = $query->get_result();
$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode([
    "success" => true,
    "data" => $data
]);
