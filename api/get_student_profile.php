<?php
include 'config_api.php';
include 'cors.php';

$student_id = $_POST['student_id'] ?? 0;

$query = "
  SELECT 
    u.name,
    s.student_number,
    s.thesis
  FROM students s
  JOIN users u ON u.id = s.user_id
  WHERE s.student_number = ?
  LIMIT 1
";

$stmt = $conn->prepare($query);
$stmt->bind_param("i", $student_id);
$stmt->execute();
$res = $stmt->get_result();

if ($res->num_rows > 0) {
  echo json_encode([
    "success" => true,
    "data" => $res->fetch_assoc()
  ]);
} else {
  echo json_encode([
    "success" => false,
    "message" => "Data mahasiswa tidak ditemukan"
  ]);
}
