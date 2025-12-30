<?php
include 'cors.php';
require_once("config_api.php");

$student_id = $_POST['student_id'] ?? '';

if (!$student_id) {
  echo json_encode([
    "success" => false,
    "message" => "student_id kosong"
  ]);
  exit;
}

$query = "
SELECT 
  u.name AS lecturer_name,
  l.employee_number AS nik,
  m.title AS major,
  sp.title AS study_program,
  l.expertise,
  u.phone_number
FROM guidances g
JOIN lecturers l ON g.lecturer_id = l.employee_number
JOIN users u ON l.user_id = u.id
JOIN study_programs sp ON l.study_program_id = sp.id
JOIN majors m ON sp.major_id = m.id
WHERE g.student_id = ?
  AND g.is_approved = 1
LIMIT 1
";

$stmt = $conn->prepare($query);
$stmt->bind_param("s", $student_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
  echo json_encode([
    "success" => false,
    "message" => "Dosen pembimbing belum ditentukan"
  ]);
  exit;
}

echo json_encode([
  "success" => true,
  "data" => $result->fetch_assoc()
]);
