<?php
include 'config_api.php';
include 'cors.php';

$lecturer_id = $_GET['lecturer_id'] ?? null;

if (!$lecturer_id) {
  echo json_encode(["success" => false]);
  exit;
}

$query = "
  SELECT 
    u.name,
    l.employee_number AS nip,
    sp.title AS study_program
  FROM lecturers l
  JOIN users u ON u.id = l.user_id
  JOIN study_programs sp ON sp.id = l.study_program_id
  WHERE l.employee_number = ?
";

$stmt = $conn->prepare($query);
$stmt->bind_param("i", $lecturer_id);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
  echo json_encode([
    "success" => true,
    "data" => [
      "name" => $row['name'],
      "nip" => $row['nip'],
      "study_program" => $row['study_program']
    ]
  ]);
} else {
  echo json_encode(["success" => false]);
}
