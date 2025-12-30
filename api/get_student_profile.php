<?php
include 'config_api.php';
include 'cors.php';

$student_id = $_POST['student_id'] ?? 0;

$query = "
  SELECT 
    u.name,
    s.student_number,
    sp.title AS study_program
  FROM students s
  JOIN users u ON u.id = s.user_id
  LEFT JOIN guidances g ON g.student_id = s.student_number
  LEFT JOIN lecturers l ON l.employee_number = g.lecturer_id
  LEFT JOIN study_programs sp ON sp.id = l.study_program_id
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
  echo json_encode(["success" => false]);
}
