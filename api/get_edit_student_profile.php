<?php
include 'cors.php';
require_once("config_api.php");

$student_number = $_POST['student_number'] ?? '';

if (!$student_number) {
  echo json_encode([
    "success" => false,
    "message" => "student_number kosong"
  ]);
  exit;
}

$query = "
SELECT 
  u.name,
  u.email,
  u.phone_number,
  s.student_number
FROM students s
JOIN users u ON s.user_id = u.id
WHERE s.student_number = ?
LIMIT 1
";

$stmt = $conn->prepare($query);
$stmt->bind_param("s", $student_number);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
  echo json_encode([
    "success" => false,
    "message" => "Data tidak ditemukan"
  ]);
  exit;
}

echo json_encode([
  "success" => true,
  "data" => $result->fetch_assoc()
]);
