<?php
include 'config_api.php';
include 'cors.php';

date_default_timezone_set('Asia/Jakarta');


$student_id = $_POST['student_id'];

$query = "
  SELECT title, session, datetime, location
  FROM schedules
  WHERE student_id = ?
    AND status = 'approved'
    AND datetime >= NOW()
  ORDER BY datetime ASC
  LIMIT 2
";

$stmt = $conn->prepare($query);
$stmt->bind_param("i", $student_id);
$stmt->execute();
$res = $stmt->get_result();

$data = [];
while ($row = $res->fetch_assoc()) {
  $data[] = $row;
}

echo json_encode([
  "success" => true,
  "data" => $data
]);
