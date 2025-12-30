<?php
include 'config_api.php';
include 'cors.php';

$lecturer_id = $_GET['lecturer_id'] ?? '';

if (!$lecturer_id) {
  echo json_encode(["success"=>false]);
  exit;
}

$query = "
  SELECT description, created_at
  FROM activity_logs
  WHERE lecturer_id = ?
  ORDER BY created_at DESC
  LIMIT 5
";

$stmt = $conn->prepare($query);
$stmt->bind_param("i", $lecturer_id);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
  $data[] = $row;
}

echo json_encode([
  "success" => true,
  "data" => $data
]);
